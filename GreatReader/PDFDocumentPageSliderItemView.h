//
//  PDFDocumentPageSliderItemView.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 4/14/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFDocumentPageSliderItem;

@interface PDFDocumentPageSliderItemView : UIView
- (instancetype)initWithItem:(PDFDocumentPageSliderItem *)item;
@property (nonatomic, strong) PDFDocumentPageSliderItem *item;
@property (nonatomic, assign) BOOL flag;
@end
