//
//  DocumentListViewModel.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "DocumentListViewModel.h"

@implementation DocumentListViewModel
- (NSString *)title { return nil; }
- (NSUInteger)count { return 0; }
- (PDFDocument *)documentAtIndex:(NSUInteger)index { return nil; }
- (void)reload {}
- (void)deleteDocuments:(NSArray *)documents {}
- (void)removeDocumentHistories:(NSArray *)documents {}
- (Folder *)createFolderInCurrentFolderWithName:(NSString *)folderName error:(NSError **)error { return NO; }
- (BOOL)moveDocuments:(NSArray *)documents toFolder:(Folder *)folder error:(NSError **)error { return NO; }
- (BOOL)createFolderInCurrentFolderWithName:(NSString *)folderName andMoveDocuments:(NSArray *)documents error:(NSError **)error { return NO; };
@end
