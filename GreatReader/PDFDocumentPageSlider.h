//
//  PDFDocumentPageSlider.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/15.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFDocumentPageSlider;

@protocol PDFDocumentPageSliderDelegate <NSObject>
@optional
- (void)pageSlider:(PDFDocumentPageSlider *)slider didSelectAtIndex:(NSUInteger)index;
@end

@protocol PDFDocumentPageSliderDataSource <NSObject>
- (void)pageSlider:(PDFDocumentPageSlider *)slider
pageThumbnailAtIndex:(NSUInteger)index
          callback:(void (^)(UIImage *, NSUInteger))callback;
- (NSUInteger)numberOfPagesInPageSlider:(PDFDocumentPageSlider *)slider;
@end

@interface PDFDocumentPageSlider : UIView
@property (nonatomic, weak) id<PDFDocumentPageSliderDelegate> delegate;
@property (nonatomic, weak) id<PDFDocumentPageSliderDataSource> dataSource;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign, readonly) NSUInteger numberOfPages;
- (void)reloadData;
@end
