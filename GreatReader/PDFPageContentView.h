//
//  PDFPageContentView.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/12.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFPage;

@interface PDFPageContentView : UIView
@property (nonatomic, strong) PDFPage *page;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGRect selectionFrame;
@end
