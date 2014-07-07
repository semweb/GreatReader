//
//  PDFDocumentSearchViewModel.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/9/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentSearchViewModel.h"

#import "PDFDocumentSearch.h"

@interface PDFDocumentSearchViewModel () <PDFDocumentSearchDelegate>
@property (nonatomic, strong) PDFDocumentSearch *search;
@property (nonatomic, strong, readwrite) NSArray *results;
@end

@implementation PDFDocumentSearchViewModel

- (instancetype)initWithSearch:(PDFDocumentSearch *)search
{
    self = [super init];
    if (self) {
        self.search = search;
        self.search.delegate = self;
        self.results = @[];
    }
    return self;
}

- (NSMutableArray *)resultsProxy
{
    return [self mutableArrayValueForKey:@"results"];
}

- (void)startSearchWithKeyword:(NSString *)keyword
{
    [self.resultsProxy removeAllObjects];
    [self.search searchWithString:keyword];
}

- (void)search:(PDFDocumentSearch *)search
 didFindString:(PDFDocumentSearchResult *)result
{
    [self.resultsProxy addObject:result];
}

@end
