//
//  RecentDocumentListViewModel.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RecentDocumentListViewModel.h"

#import "PDFDocument.h"
#import "PDFRecentDocumentList.h"

@implementation RecentDocumentListViewModel

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

@end
