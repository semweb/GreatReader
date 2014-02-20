//
//  PDFPageCropViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/21.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFPageCropViewController.h"

@interface PDFPageCropViewController ()
@end

@implementation PDFPageCropViewController

- (CGRect)frameThatFits
{
    CGRect f = [super frameThatFits];
    CGFloat ratio = (f.size.width - 80) / f.size.width;
    f.size.width = roundf(f.size.width * ratio);
    f.size.height = roundf(f.size.height * ratio);
    return f;
}

- (void)loadView
{
    [super loadView];

    UIScrollView *scrollView = (UIScrollView *)self.view;
    scrollView.minimumZoomScale = 0.1;
    scrollView.maximumZoomScale = 0.1;
    [scrollView setZoomScale:0.1 animated:NO];
}

@end
