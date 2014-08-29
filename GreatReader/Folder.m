//
//  Folder.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/17.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "Folder.h"

#import "File.h"
#import "NSArray+GreatReaderAdditions.h"
#import "PDFDocument.h"
#import "PDFDocumentStore.h"

NSString * const FolderFileRemovedNotification = @"FolderFileRemovedNotification";

@interface Folder ()
@property (nonatomic, weak, readwrite) PDFDocumentStore *store;
@end

@implementation Folder

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithPath:(NSString *)path
                       store:(PDFDocumentStore *)store
{
    self = [super initWithPath:path];
    if (self) {
        _store = store;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(documentDeleted:)
                                                     name:PDFDocumentDeletedNotification
                                                   object:nil];
    }
    return self;
}

- (void)load
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSArray *contents = [fm contentsOfDirectoryAtPath:self.path
                                                error:NULL];
    self.files = [contents grt_map:^(NSString *p) {
        NSString *absPath = [NSString stringWithFormat:@"%@/%@", self.path, p];
        BOOL isDirectory;
        [fm fileExistsAtPath:absPath isDirectory:&isDirectory];
        File *file = nil;
        if (isDirectory) {
            return (File *)nil;
        } else {
            file = [self.store documentAtPath:absPath];
        }
        return file.fileNotExist ? nil : file;
    }];
}

- (UIImage *)iconImage
{
    return [UIImage imageNamed:@"Folder.png"];
}

- (BOOL)removeItemAtIndex:(NSUInteger)index error:(NSError **)error
{
    NSFileManager *fileManager = [NSFileManager new];
    File *file = self.files[index];
    if ([fileManager removeItemAtPath:file.path error:error]) {
        NSMutableArray *mFiles = self.files.mutableCopy;
        [mFiles removeObject:file];
        self.files = mFiles.copy;
        [NSNotificationCenter.defaultCenter
            postNotificationName:FolderFileRemovedNotification
                          object:self
                        userInfo:@{
                                     @"Files": @[file]
                                  }];
        return YES;
    }
    return NO;
}

#pragma mark - PDFDocumentDeletedNotification

- (void)documentDeleted:(NSNotification *)notification
{
    PDFDocument *deletedDocument = notification.object;
    for (PDFDocument *doc in [self.files copy]) {
        if (deletedDocument == doc) {
            NSMutableArray *mFiles = self.files.mutableCopy;
            [mFiles removeObject:doc];
            self.files = mFiles.copy;
        }
    }
}

@end
