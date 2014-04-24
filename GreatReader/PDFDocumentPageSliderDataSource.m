//
//  PDFDocumentPageSliderDataSource.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/15.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentPageSliderDataSource.h"

#import "PDFDocumentOutline.h"
#import "PDFDocumentOutlineItem.h"
#import "PDFDocumentBookmarkList.h"
#import "PDFDocumentPageSliderItem.h"

@interface PDFDocumentPageSliderDataSource ()
@property (nonatomic, strong, readwrite) NSArray *positions;
@property (nonatomic, assign, readwrite) NSUInteger numberOfPages;
@end

@implementation PDFDocumentPageSliderDataSource

- (instancetype)initWithOutline:(PDFDocumentOutline *)outline
                   bookmarkList:(PDFDocumentBookmarkList *)bookmarkList
                  numberOfPages:(NSUInteger)numberOfPages
{
    self = [super init];
    if (self) {
        _numberOfPages = numberOfPages;
        // NSArray *outlineItems = [self itemsForOutline:outline
        //                                     numberOfPages:numberOfPages];
        NSArray *bookmarkItems = [self itemsForBookmarkList:bookmarkList
                                                  numberOfPages:numberOfPages];
        // NSArray *startAndEnd = [self itemsForStartAndEnd:numberOfPages];
        NSMutableArray *items = [NSMutableArray array];
        // [items addObjectsFromArray:outlineItems];
        [items addObjectsFromArray:bookmarkItems];
        // [items addObjectsFromArray:startAndEnd];
        NSSortDescriptor *descriptor =
                [NSSortDescriptor sortDescriptorWithKey:@"position"
                                              ascending:YES];
        [items sortUsingDescriptors:@[descriptor]];
        _items = items.copy;
    }
    return self;
}

- (NSArray *)itemsForStartAndEnd:(NSUInteger)numberOfPages;
{
    PDFDocumentPageSliderItem *start = PDFDocumentPageSliderItem.new;
    start.position = 0.0;
    start.pageNumber = 1;
    PDFDocumentPageSliderItem *end = PDFDocumentPageSliderItem.new;
    end.position = 1.0;
    end.pageNumber = numberOfPages;
    return @[start, end];
}

- (NSArray *)itemsForOutline:(PDFDocumentOutline *)outline
               numberOfPages:(NSUInteger)numberOfPages
{
    NSMutableArray *items = NSMutableArray.array;
    [outline.items enumerateObjectsUsingBlock:^(PDFDocumentOutlineItem *outlineItem,
                                                NSUInteger idx,
                                                BOOL *stop) {
        PDFDocumentPageSliderOutlineItem *item = PDFDocumentPageSliderOutlineItem.new;
        item.pageNumber = outlineItem.pageNumber;
        item.position = (CGFloat)item.pageNumber / numberOfPages;
        [items addObject:item];
    }];
    return items;
}

- (NSArray *)itemsForBookmarkList:(PDFDocumentBookmarkList *)bookmarkList
                    numberOfPages:(NSUInteger)numberOfPages
{
    NSMutableArray *items = NSMutableArray.array;
    NSArray *list = bookmarkList.bookmarkList;
    [list enumerateObjectsUsingBlock:^(NSNumber *bookmark,
                                       NSUInteger idx,
                                       BOOL *stop) {
        PDFDocumentPageSliderBookmarkItem *item = PDFDocumentPageSliderBookmarkItem.new;
        item.pageNumber = bookmark.unsignedIntegerValue;
        item.position = (CGFloat)item.pageNumber / numberOfPages;
        [items addObject:item];
    }];
    return items;    
}

@end
