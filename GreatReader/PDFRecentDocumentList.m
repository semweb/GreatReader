//
//  PDFRecentDocumentList.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/06.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFRecentDocumentList.h"

#import "Folder.h"
#import "NSArray+GreatReaderAdditions.h"
#import "NSFileManager+GreatReaderAdditions.h"
#import "PDFDocument.h"
#import "PDFDocumentStore.h"

@interface PDFRecentDocumentList ()
@property (nonatomic, strong, readwrite) NSArray *documents;
@property (nonatomic, assign) UIBackgroundTaskIdentifier bgTask;
@property (nonatomic, weak, readwrite) PDFDocumentStore *store;
@end

@implementation PDFRecentDocumentList

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)initWithStore:(PDFDocumentStore *)store
{
    self = [super init];
    if (self) {
        _store = store;
        NSArray *list = [self load];
        _documents = list;
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(documentDeleted:)
                                                   name:PDFDocumentDeletedNotification
                                                 object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(didEnterBackground:)
                                                   name:UIApplicationDidEnterBackgroundNotification
                                                 object:nil];
    }
    return self;
}

#pragma mark - Save, Load

- (NSString *)path
{
    NSString * const name = @"PDFRecentDocumentList";
    return [NSString stringWithFormat:@"%@/%@",
                     [NSFileManager grt_privateDocumentsPath],
                     name];
}

- (void)save
{
    NSString *dirPath = [NSFileManager grt_privateDocumentsPath];
    NSFileManager *fm = [NSFileManager new];
    if (![fm fileExistsAtPath:dirPath]) {
        [fm grt_createPrivateDocumentsDirectory];
    }
    [NSKeyedArchiver archiveRootObject:self.documents
                                toFile:self.path];
}

- (void)saveLater
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(save)
                                               object:nil];
    [self performSelector:@selector(save) withObject:nil afterDelay:0.0];
}

- (NSArray *)load
{
    NSArray *list = [NSKeyedUnarchiver unarchiveObjectWithFile:self.path]
            ?: @[];
    return [list grt_filter:^(PDFDocument *document) {
        return (BOOL)!document.fileNotExist;
    }];
}

#pragma mark -

- (NSMutableArray *)documentsProxy
{
    return [self mutableArrayValueForKey:@"documents"];
}

#pragma mark -

- (void)addHistory:(PDFDocument *)document
{
    [self.documentsProxy removeObject:document];
    [self.documentsProxy insertObject:document atIndex:0];
    [self save];
}

- (void)removeHistories:(NSArray *)histories
{
    [self.documentsProxy removeObjectsInArray:histories];
    [self save];
}

- (PDFDocument *)findDocumentAtPath:(NSString *)path
{
    NSString *rPath = [PDFDocument relativePathWithAbsolutePath:path];
    for (PDFDocument *doc in self.documents) {
        NSString *docrPath = [PDFDocument relativePathWithAbsolutePath:doc.path];
        if ([rPath isEqual:docrPath]) {
            return doc;
        }
    }
    return nil;
}

- (NSUInteger)count
{
    return self.documentsProxy.count;
}

- (PDFDocument *)documentAtIndex:(NSUInteger)index
{
    return [self.documentsProxy objectAtIndex:index];
}

#pragma mark - Notifications

- (void)documentDeleted:(NSNotification *)notification
{
    PDFDocument *deletedDocument = notification.object;
    for (PDFDocument *doc in [self.documents copy]) {
        if (deletedDocument == doc) {
            [self.documentsProxy removeObject:doc];
        }
    }    

    [self saveLater];
}

#pragma mark - Did Enter Background

- (void)didEnterBackground:(NSNotification *)notification
{
    self.bgTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
        self.bgTask = UIBackgroundTaskInvalid;
    }];
    [self save];
    [[UIApplication sharedApplication] endBackgroundTask:self.bgTask];
    self.bgTask = UIBackgroundTaskInvalid;
}

@end
