//
//  RootFolderTableDataSource.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/19.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "FolderTableDataSource.h"

@class PDFRecentDocumentList;

@interface RootFolderTableDataSource : FolderTableDataSource
- (instancetype)initWithDocumentList:(PDFRecentDocumentList *)documentList;
@end
