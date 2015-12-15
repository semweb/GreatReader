//
//  DocumentListViewModel.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Folder;
@class PDFDocument;
@class PDFRecentDocumentList;

@interface DocumentListViewModel : NSObject
- (NSString *)title;
- (NSUInteger)count;
- (PDFDocument *)documentAtIndex:(NSUInteger)index;
- (void)reload;
- (BOOL)deleteDocuments:(NSArray *)documents error:(NSError **)error;
- (void)removeDocumentHistories:(NSArray *)documents;
- (Folder *)createFolderInCurrentFolderWithName:(NSString *)folderName error:(NSError **)error;
- (BOOL)moveDocuments:(NSArray *)documents toFolder:(Folder *)folder error:(NSError **)error;
- (BOOL)findSuperFolderAndMoveDocuments:(NSArray *)documents error:(NSError **)error;
- (BOOL)createFolderInCurrentFolderWithName:(NSString *)folderName andMoveDocuments:(NSArray *)documents error:(NSError **)error;
- (BOOL)checkIfCurrentFolderIsRootFolder;
- (BOOL)checkIfHasFolderInDocuments:(NSArray *)documents;
@end
