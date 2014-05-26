//
//  FolderDocumentListViewModel.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "FolderDocumentListViewModel.h"

#import "Folder.h"
#import "PDFDocument.h"
#import "PDFRecentDocumentList.h"

@interface FolderDocumentListViewModel ()
@end

@implementation FolderDocumentListViewModel

- (NSString *)title
{
    return @"Documents";
}

- (NSUInteger)count
{
    return self.folder.files.count;
}

- (PDFDocument *)documentAtIndex:(NSUInteger)index
{
    return self.folder.files[index];
}

@end
