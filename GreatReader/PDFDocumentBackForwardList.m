//
//  PDFDocumentBackForwardList.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/11/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentBackForwardList.h"

@interface PDFDocumentBackForwardList ()
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, strong) NSArray *items;
@end

@implementation PDFDocumentBackForwardList

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"currentPage"]) {
        return [NSSet setWithObjects:@"currentIndex", @"items", nil];
    } else if ([key isEqualToString:@"canGoBack"]) {
        return [NSSet setWithObjects:@"currentIndex", nil];
    } else if ([key isEqualToString:@"canGoForward"]) {
        return [NSSet setWithObjects:@"currentIndex", nil];
    }        
    return NSSet.set;
}

- (instancetype)initWithCurrentPage:(NSUInteger)currentPage
{
    self = [super init];
    if (self) {
        _currentIndex = 0;
        _items = [NSArray arrayWithObject:@(currentPage)];
    }
    return self;
}

- (BOOL)canGoBack
{
    return self.currentIndex > 0;
}

- (BOOL)canGoForward
{
    return self.items.count - 1 > self.currentIndex;
}

- (NSUInteger)currentPage
{
    return [[self.items objectAtIndex:self.currentIndex] unsignedIntegerValue];
}

#pragma mark -

- (void)goBack
{
    if (self.canGoBack) {
        self.currentIndex--;
    }
}

- (void)goForward
{
    if (self.canGoForward) {
        self.currentIndex++;
    }
}

- (void)goTo:(NSUInteger)page
  addHistory:(BOOL)addHistory
{
    if (addHistory) {
        self.items = [[self.items subarrayWithRange:NSMakeRange(0, self.currentIndex + 1)] mutableCopy];
        [self.itemsProxy addObject:@(page)];
        self.currentIndex++;
    } else {
        [self.itemsProxy replaceObjectAtIndex:self.items.count - 1
                                   withObject:@(page)];
    }
}

#pragma mark -

- (NSMutableArray *)itemsProxy
{
    return [self mutableArrayValueForKey:@"items"];
}

@end
