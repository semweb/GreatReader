//
//  PDFDocumentPageSliderItem.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 4/14/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFDocumentPageSliderItem : NSObject
@property (nonatomic, assign) CGFloat position;
@property (nonatomic, assign) NSUInteger pageNumber;
@end

@interface PDFDocumentPageSliderOutlineItem : PDFDocumentPageSliderItem
@end

@interface PDFDocumentPageSliderBookmarkItem : PDFDocumentPageSliderItem
@end
