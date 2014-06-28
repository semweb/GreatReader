//
//  RecentDocumentListViewModel.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RecentDocumentListViewModel.h"

#import "PDFDocument.h"
#import "PDFDocumentStore.h"
#import "PDFRecentDocumentList.h"

@interface RecentDocumentListViewModel ()
@property (nonatomic, strong) PDFRecentDocumentList *documentList;
@end

@implementation RecentDocumentListViewModel

- (instancetype)initWithDocumentList:(PDFRecentDocumentList *)documentList
{
    self = [super init];
    if (self) {
        _documentList = documentList;
    }
    return self;
}

- (NSString *)title
{
    return @"Recently";
}

- (NSUInteger)count
{
    return self.documentList.count;
}

- (PDFDocument *)documentAtIndex:(NSUInteger)index
{
    return [self.documentList documentAtIndex:index];
}

- (void)deleteDocuments:(NSArray *)documents
{
    [self.documentList.store deleteDocuments:documents];
}

@end
