//
//  PDFDocumentBookmarkList.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2/24/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentBookmarkList.h"

#import "PDFDocument.h"
#import "PDFDocumentOutline.h"

@interface PDFDocumentBookmarkList ()
@property (nonatomic, strong) NSMutableArray *bookmarks;
@property (nonatomic, strong, readwrite) NSArray *bookmarkedSectionList;
@end

@implementation PDFDocumentBookmarkList

- (instancetype)init
{
    self = [super init];
    if (self) {
        _bookmarks = [NSMutableArray array];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        NSArray *saved = [decoder decodeObjectForKey:@"bookmarks"];
        if (saved) {
            [_bookmarks addObjectsFromArray:saved];
            [self updateBookmarkedSectionList];
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.bookmarks forKey:@"bookmarks"];
}

- (void)bookmarkAtPage:(NSUInteger)page
{
    NSNumber *num = @(page);
    if (![self.bookmarks containsObject:num]) {
        [self.bookmarks addObject:num];
    }
    [self updateBookmarkedSectionList];    
}

- (void)unbookmarkAtPage:(NSUInteger)page
{
    NSNumber *num = @(page);
    if ([self.bookmarks containsObject:num]) {
        [self.bookmarks removeObject:num];
    }
    [self updateBookmarkedSectionList];    
}

- (void)toggleBookmarkAtPage:(NSUInteger)page
{
    if ([self bookmarkedAtPage:page]) {
        [self unbookmarkAtPage:page];
    } else {
        [self bookmarkAtPage:page];
    }
}

- (BOOL)bookmarkedAtPage:(NSUInteger)page
{
    NSNumber *num = @(page);
    return [self.bookmarks containsObject:num];
}

#pragma -

- (void)updateBookmarkedSectionList
{
    NSArray *list = [self.bookmarks sortedArrayUsingSelector:@selector(compare:)];
    NSString *currentSection = nil;
    NSMutableArray *currentList = nil;
    NSMutableArray *sections = [NSMutableArray array];
    for (NSNumber *bookmark in list) {
        NSString *section = [self.document.outline sectionTitleAtIndex:[bookmark integerValue]];
        if ([currentSection isEqualToString:section] || (!currentSection && !section && currentList)) {
            [currentList addObject:bookmark];
        } else {
            currentList = [NSMutableArray arrayWithObject:bookmark];
            [sections addObject:@{
                @"section": section ?: @"",
                @"bookmarks": currentList
            }];            
        }
        currentSection = section;
    }
    self.bookmarkedSectionList = sections;
}

- (NSArray *)bookmarkList
{
    return self.bookmarks.copy;
}

@end
