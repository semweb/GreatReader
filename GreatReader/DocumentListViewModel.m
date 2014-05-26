//
//  DocumentListViewModel.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "DocumentListViewModel.h"

@interface DocumentListViewModel ()
@end

@implementation DocumentListViewModel

- (instancetype)initWithDocumentList:(PDFRecentDocumentList *)documentList
{
    self = [super init];
    if (self) {
        _documentList = documentList;
    }
    return self;
}

- (NSString *)title { return nil; }
- (NSUInteger)count { return 0; }
- (PDFDocument *)documentAtIndex:(NSUInteger)index { return nil; }

@end
