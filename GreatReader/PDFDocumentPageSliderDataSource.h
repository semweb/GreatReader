//
//  PDFDocumentPageSliderDataSource.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/15.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFDocumentOutline;
@class PDFDocumentBookmarkList;

@interface PDFDocumentPageSliderDataSource : NSObject
- (instancetype)initWithOutline:(PDFDocumentOutline *)outline
                   bookmarkList:(PDFDocumentBookmarkList *)bookmarkList
                  numberOfPages:(NSUInteger)numberOfPages;
@property (nonatomic, strong, readonly) NSArray *items;
@property (nonatomic, assign, readonly) NSUInteger numberOfPages;
@end
