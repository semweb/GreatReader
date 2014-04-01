//
//  PDFRecentDocumentList.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/06.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFRecentDocumentList.h"

#import "NSArray+GreatReaderAdditions.h"
#import "NSFileManager+GreatReaderAdditions.h"
#import "PDFDocument.h"

@interface PDFRecentDocumentList ()
@property (nonatomic, strong) NSMutableArray *histories;
@end

@implementation PDFRecentDocumentList

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSArray *list = [self load];
        _histories = [NSMutableArray array];
        [_histories addObjectsFromArray:list];
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
    [NSKeyedArchiver archiveRootObject:self.histories toFile:self.path];
}

- (NSArray *)load
{
    NSArray *list = [NSKeyedUnarchiver unarchiveObjectWithFile:self.path];
    return [list grt_filter:^(PDFDocument *document) {
        return (BOOL)!document.fileNotExist;
    }];
}

#pragma mark -

- (PDFDocument *)open:(PDFDocument *)document
{
    PDFDocument *doc = [self findDocumentInHistory:document];
    if (doc) {
        [self.histories removeObject:doc];
    } else {
        doc = document;
    }
    [self.histories insertObject:doc atIndex:0];
    [self save];
    
    return doc;
}

- (PDFDocument *)findDocumentInHistory:(PDFDocument *)document
{
    if ([self.histories containsObject:document]) {
        NSUInteger index = [self.histories indexOfObject:document];
        return self.histories[index];
    }
    return nil;
}

- (NSUInteger)count
{
    return self.histories.count;
}

- (PDFDocument *)documentAtIndex:(NSUInteger)index
{
    return self.histories[index];
}

@end
