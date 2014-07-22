//
//  PDFPageCropViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/21.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFPageCropViewController.h"

#import "Device.h"
#import "PDFDocument.h"
#import "PDFDocumentCrop.h"
#import "PDFDocumentCropOverlayView.h"
#import "PDFPage.h"
#import "PDFPageContentView.h"

@interface PDFPageCropView : UIScrollView
@end

@implementation PDFPageCropView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return YES;
}

@end

@interface PDFPageCropViewController ()
@property (nonatomic, strong) PDFDocumentCropOverlayView *overlayView;
@property (nonatomic, assign) BOOL first;
@end

@implementation PDFPageCropViewController

- (void)loadView
{
    PDFPageCropView *scrollView =
            [[PDFPageCropView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    scrollView.canCancelContentTouches = NO;
    scrollView.clipsToBounds = NO;
    scrollView.minimumZoomScale = 1.0;
    scrollView.maximumZoomScale = 1.0;
    [scrollView setZoomScale:1.0 animated:NO];

    self.view = scrollView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.overlayView = [[PDFDocumentCropOverlayView alloc] initWithFrame:self.contentView.bounds];
    [self.view addSubview:self.overlayView];

    self.first = YES;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.overlayView.frame = self.contentView.frame;
    if (self.first) {
        self.first = NO;
        CGRect cropRect = [self.crop cropRectAtPage:self.page.index];
        self.overlayView.cropRect = cropRect;
    }
}

- (CGRect)cropRect
{
    return self.overlayView.cropRect;
}

@end
