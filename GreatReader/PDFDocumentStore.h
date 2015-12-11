//
//  PDFDocumentStore.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/29/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFDocument;
@class PDFRecentDocumentList;
@class RootFolder;
@class Folder;

@interface PDFDocumentStore : NSObject
@property (nonatomic, strong, readonly) PDFRecentDocumentList *documentList;
@property (nonatomic, strong, readonly) RootFolder *rootFolder;
- (PDFDocument *)documentAtPath:(NSString *)path;
- (void)addHistory:(PDFDocument *)document;
- (void)deleteDocuments:(NSArray *)documents;
- (void)deleteDocument:(PDFDocument *)document;
- (BOOL)moveDocuments:(NSArray *)documents toFolder:(Folder *)folder error:(NSError **)error;
- (BOOL)moveDocument:(PDFDocument *)document toFolder:(Folder *)folder error:(NSError **)error;
@end
