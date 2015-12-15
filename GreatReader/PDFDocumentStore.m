//
//  PDFDocumentStore.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/29/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentStore.h"

#import "Folder.h"
#import "RootFolder.h"
#import "PDFDocument.h"
#import "PDFRecentDocumentList.h"

@interface PDFDocumentStore ()
@property (nonatomic, strong, readwrite) PDFRecentDocumentList *documentList;
@property (nonatomic, strong, readwrite) RootFolder *rootFolder;
@end

@implementation PDFDocumentStore

- (instancetype)init
{
    self = [super init];
    if (self) {
        _documentList = [[PDFRecentDocumentList alloc] initWithStore:self];
    }
    return self;
}

- (PDFDocument *)documentAtPath:(NSString *)path
{
    PDFDocument *document = [self.documentList findDocumentAtPath:path];
    if (!document) {
        document = [[PDFDocument alloc] initWithPath:path];
    }
    document.store = self;    
    return document;
}

- (RootFolder *)rootFolder
{
    if (!_rootFolder) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask,
                                                             YES);        
        _rootFolder = [[RootFolder alloc] initWithPath:paths.firstObject
                                                 store:self];
    }
    return _rootFolder;
}

- (void)addHistory:(PDFDocument *)document
{
    [self.documentList addHistory:document];
}

- (BOOL)deleteDocuments:(NSArray *)documents error:(NSError **)error
{
    __block BOOL deletedAllDocuments = YES;
    
    [documents enumerateObjectsUsingBlock:^(PDFDocument *document,
                                            NSUInteger idx,
                                            BOOL *stop) {
        if (![self deleteDocument:document error:error]) {
            *stop = YES;
            deletedAllDocuments = NO;
            return;
        }
    }];
    
    return deletedAllDocuments;
}

- (BOOL)deleteDocument:(PDFDocument *)document error:(NSError **)error
{
    return [document deleteWithPossibleError:error];
}

- (BOOL)moveDocuments:(NSArray *)documents toFolder:(Folder *)folder error:(NSError **)error
{
    __block BOOL movedAllDocuments = YES;
    
    [documents enumerateObjectsUsingBlock:^(PDFDocument *document,
                                            NSUInteger idx,
                                            BOOL *stop) {
        if (![self moveDocument:document toFolder:folder error:error]) {
            *stop = YES;
            movedAllDocuments = NO;
            return;
        }
    }];
    
    return movedAllDocuments;
}

- (BOOL)moveDocument:(PDFDocument *)document toFolder:(Folder *)folder error:(NSError **)error
{
    return [document moveToDirectory:folder.path error:error];
}

@end
