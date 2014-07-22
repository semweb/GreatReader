//
//  PDFDocumentCropViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/21.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentCropViewController.h"

#import "PDFDocument.h"
#import "PDFDocumentCrop.h"
#import "PDFPage.h"
#import "PDFPageContentView.h"
#import "PDFPageCropViewController.h"
#import "PDFPageViewController.h"

NSString * const PDFDocumentCropViewControllerSegueExit = @"PDFDocumentCropViewControllerSegueExit";

@interface PDFDocumentCropViewController () <UIGestureRecognizerDelegate>
@property (nonatomic, strong) PDFPageCropViewController *pdfPageViewController;
@property (nonatomic, assign) BOOL fullScreen;
@property (nonatomic, strong) UIButton *modeButton;
@property (nonatomic, strong) IBOutlet PDFDocumentCropLayoutView *layoutView;
@end

@implementation PDFDocumentCropViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor grayColor];

    self.modeButton = ({
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.titleLabel.font = [UIFont systemFontOfSize:12];
        button.titleEdgeInsets = UIEdgeInsetsMake(2, 8, 0, 0);
        button.imageEdgeInsets = UIEdgeInsetsMake(2, 0, 0, 0);
        [button setTitleColor:self.navigationController.navigationBar.tintColor
                     forState:UIControlStateNormal];
        [button setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.4]
                     forState:UIControlStateHighlighted];            
        button.titleLabel.numberOfLines = 2;
        [button addTarget:self
                   action:@selector(changeMode:)
         forControlEvents:UIControlEventTouchUpInside];        
        button;
    });
    [self updateModeButton];

    PDFPage *page = [self.document pageAtIndex:self.document.currentPage];
    self.pdfPageViewController =
            [[PDFPageCropViewController alloc] initWithPage:page];
    self.pdfPageViewController.crop = self.crop;    
    [self.layoutView addSubview:self.pdfPageViewController.view];
    self.pdfPageViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleHeight;
    self.pdfPageViewController.view.frame = self.layoutView.bounds;

    UITapGestureRecognizer *tapRec =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(singleTapped:)];
    tapRec.delegate = self;
    [self.pdfPageViewController.view addGestureRecognizer:tapRec];
}

- (void)changeMode:(id)sender
{
    self.crop.mode += 1;
    if (self.crop.mode == 3) {
        self.crop.mode = 0;
    }
    [self updateModeButton];
}

- (void)updateModeButton
{
    NSString *imageName = nil;
    NSString *title = nil;

    if (self.crop.mode == PDFDocumentCropModeSame) {
        imageName = @"CropBoth";
        title = @"Same Crops\nOdd and Even";
    } else if (self.crop.mode == PDFDocumentCropModeDifferent) {
        if (self.isOddPage) {
            imageName = @"CropOdd";
        } else {
            imageName = @"CropEven";
        }
        title = @"Different Crops\nOdd and Even";        
    } else {
        title = @"No Crops";
        imageName = @"CropNone";
    }
    [self.modeButton setImage:[[UIImage imageNamed:imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
                     forState:UIControlStateNormal];
    [self.modeButton setTitle:title forState:UIControlStateNormal];
    [self.modeButton sizeToFit];
    self.modeButton.frame = ({
        CGRect r = self.modeButton.frame;
        r.size.height = 44;
        r.size.width += 8.0;
        r;
    });

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.modeButton];
    self.navigationItem.leftBarButtonItem = item;    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)singleTapped:(UITapGestureRecognizer *)recognizer
{
    [self toggleFullScreen];
}

#pragma mark -

- (BOOL)prefersStatusBarHidden
{
    return self.fullScreen;
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

#pragma mark -

- (void)toggleFullScreen
{
    self.fullScreen = !self.fullScreen;

    CGFloat alpha = self.fullScreen ? 0.0 : 1.0;
    CGRect barFrame = self.navigationController.navigationBar.frame;
    barFrame.origin.y = 20;
    self.navigationController.navigationBar.frame = barFrame;    
    if (!self.fullScreen) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        self.navigationController.navigationBar.alpha = 0.0;                    
    }
    
    [UIView animateWithDuration:0.125
                     animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
        self.navigationController.navigationBar.alpha = alpha;
    } completion:^(BOOL finished) {
        [self.navigationController setNavigationBarHidden:self.fullScreen animated:NO];            
    }];

    self.navigationController.navigationBar.frame = CGRectZero;
    self.navigationController.navigationBar.frame = barFrame;
}

#pragma mark -

- (BOOL)isOddPage
{
    return self.document.currentPage % 2 != 0;
}

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:PDFDocumentCropViewControllerSegueExit]) {
        if (self.crop.mode == PDFDocumentCropModeSame) {
            self.crop.oddCropRect = self.pdfPageViewController.cropRect;
            self.crop.evenCropRect = self.pdfPageViewController.cropRect;
        } else if (self.crop.mode == PDFDocumentCropModeDifferent) {
            if (self.isOddPage) {
                self.crop.oddCropRect = self.pdfPageViewController.cropRect;
            } else {
                self.crop.evenCropRect = self.pdfPageViewController.cropRect;
            }
        }
    }
}

@end


@implementation PDFDocumentCropLayoutView : UIView

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return YES;
}

@end
