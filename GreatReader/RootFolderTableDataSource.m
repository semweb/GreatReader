//
//  RootFolderTableDataSource.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/19.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RootFolderTableDataSource.h"

#import "File.h"
#import "Folder.h"
#import "PDFDocument.h"
#import "PDFRecentDocumentList.h"

@interface RootFolderTableDataSource ()
@property (nonatomic, strong) PDFRecentDocumentList *documentList;
@end

@implementation RootFolderTableDataSource

- (instancetype)initWithDocumentList:(PDFRecentDocumentList *)documentList
{
    self = [super initWithFolder:[Folder rootFolder]];
    if (self) {
        _documentList = documentList;
    }
    return self;
}

- (NSUInteger)numberOfSections
{
    return 2;
}

- (NSUInteger)numberOfFilesInSection:(NSInteger)section
{
    if (section == 0) {
        return MIN(3, self.documentList.count);
    } else {
        return [super numberOfFilesInSection:section];
    }
}

- (File *)fileAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [self.documentList documentAtIndex:indexPath.row];
    } else {
        return [super fileAtIndexPath:indexPath];
    }
}

- (NSString *)titleInSection:(NSUInteger)section
{
    if (section == 0) {
        return @"Recent";
    } else {
        return @"Documents";
    }
}

- (NSString *)title
{
    return @"Great Reader";
}

@end
