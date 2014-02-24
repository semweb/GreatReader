//
//  PDFDocumentBookmarkList.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2/24/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentBookmarkList.h"

@interface PDFDocumentBookmarkList ()
@property (nonatomic, strong) NSMutableArray *bookmarks;
@end

@implementation PDFDocumentBookmarkList

- (id)init
{
    self = [super init];
    if (self) {
        _bookmarks = [NSMutableArray array];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self) {
        NSArray *saved = [decoder decodeObjectForKey:@"bookmarks"];
        if (saved) {
            [_bookmarks addObjectsFromArray:saved];
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
}

- (void)unbookmarkAtPage:(NSUInteger)page
{
    NSNumber *num = @(page);
    if ([self.bookmarks containsObject:num]) {
        [self.bookmarks removeObject:num];
    }
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

#pragma mark -

- (NSArray *)bookmarkList
{
    return [self.bookmarks sortedArrayUsingSelector:@selector(compare:)];
}

@end
