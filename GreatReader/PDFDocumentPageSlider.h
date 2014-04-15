//
//  PDFDocumentPageSlider.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/15.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFDocumentPageSlider;
@class PDFDocumentPageSliderDataSource;

@protocol PDFDocumentPageSliderDelegate <NSObject>
@optional
- (void)pageSlider:(PDFDocumentPageSlider *)slider didSelectAtIndex:(NSUInteger)index;
@end

@interface PDFDocumentPageSlider : UIView
@property (nonatomic, weak) id<PDFDocumentPageSliderDelegate> delegate;
@property (nonatomic, strong) PDFDocumentPageSliderDataSource *dataSource;
@property (nonatomic, assign) NSUInteger currentIndex;
@property (nonatomic, assign, readonly) NSUInteger numberOfPages;
- (void)reloadData;
@end
