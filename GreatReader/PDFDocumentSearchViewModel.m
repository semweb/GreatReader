//
//  PDFDocumentSearchViewModel.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/9/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentSearchViewModel.h"

#import "PDFDocumentOutline.h"
#import "PDFDocumentSearch.h"
#import "PDFDocumentSearchResult.h"


@interface PDFDocumentSearchViewSection ()
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, strong, readwrite) NSArray *results;
@end

@implementation PDFDocumentSearchViewSection
@end


@interface PDFDocumentSearchViewModel () <PDFDocumentSearchDelegate>
@property (nonatomic, strong) PDFDocumentSearch *search;
@property (nonatomic, strong) PDFDocumentOutline *outline;
@property (nonatomic, strong, readwrite) NSArray *sections;
@end

@implementation PDFDocumentSearchViewModel

- (instancetype)initWithSearch:(PDFDocumentSearch *)search
                       outline:(PDFDocumentOutline *)outline
{
    self = [super init];
    if (self) {
        _search = search;
        _search.delegate = self;
        _outline = outline;
        _sections = @[];
    }
    return self;
}

- (NSMutableArray *)sectionsProxy
{
    return [self mutableArrayValueForKey:@"sections"];
}

- (void)startSearchWithKeyword:(NSString *)keyword
{
    [self.sectionsProxy removeAllObjects];
    [self.search searchWithString:keyword];
}

- (void)stopSearch
{
    [self.search cancelSearch];
}

- (void)search:(PDFDocumentSearch *)search
 didFindString:(PDFDocumentSearchResult *)result
{
    PDFDocumentSearchViewSection *lastSection = [self.sections lastObject];
    NSString *lastSectionTitle = lastSection.title ?: @"";
    NSMutableArray *results = [lastSection.results mutableCopy];
    NSString *sectionTitle = [self.outline sectionTitleAtIndex:result.page] ?: @"";
    PDFDocumentSearchViewSection *section = PDFDocumentSearchViewSection.new;
    section.title = sectionTitle;
    if ([lastSectionTitle isEqual:sectionTitle] && self.sections.count > 0) {
        [results addObject:result];
        section.results = [results copy];
        [self.sectionsProxy replaceObjectAtIndex:self.sections.count - 1
                                      withObject:section];
    } else {
        section.results = @[result];
        [self.sectionsProxy addObject:section];
    }
}

- (BOOL)searching
{
    return NO;
}

- (NSString *)progressDescription
{
    return @"";
}

- (PDFDocumentSearchResult *)resultAtIndexPath:(NSIndexPath *)indexPath
{
    PDFDocumentSearchViewSection *section = self.sections[indexPath.section];
    return section.results[indexPath.row];
}

@end
