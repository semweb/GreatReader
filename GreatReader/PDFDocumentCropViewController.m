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
#import "PDFDocumentCropOverlayView.h"
#import "PDFPage.h"
#import "PDFPageCropViewController.h"
#import "PDFPageViewController.h"

NSString * const PDFDocumentCropViewControllerSegueExit = @"PDFDocumentCropViewControllerSegueExit";

@interface PDFDocumentCropViewController () <UIPageViewControllerDelegate,
                                             UIPageViewControllerDataSource,
                                             UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) IBOutlet PDFDocumentCropOverlayView *overlayView;
@property (nonatomic, assign) BOOL fullScreen;
@property (nonatomic, strong) UIButton *modeButton;
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

    self.pageViewController =
            [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                            navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                          options:@{UIPageViewControllerOptionInterPageSpacingKey:
                                                                    @(24)}];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    self.pageViewController.view.frame = self.view.bounds;

    [self goAtIndex:self.crop.document.currentPage
           animated:NO];

    UITapGestureRecognizer *tapRec =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(singleTapped:)];
    tapRec.delegate = self;
    [self.overlayView addGestureRecognizer:tapRec];
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

- (void)goAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    PDFPageViewController *pdfPageViewController = [self pageViewControllerAtIndex:index];
    [self.pageViewController setViewControllers:@[pdfPageViewController]
                                      direction:direction
                                       animated:animated
                                     completion:NULL];

    self.overlayView.targetRect = pdfPageViewController.contentFrame;
    CGRect cropRect = [self.crop cropRectAtPage:self.crop.document.currentPage];
    if (!CGRectEqualToRect(cropRect, CGRectZero)) {
        self.overlayView.cropRect = cropRect;
    }
    [self.view bringSubviewToFront:self.overlayView];
}

#pragma mark -

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    PDFPageViewController *current = (PDFPageViewController *)viewController;
    if (current.page.index == 1) {
        return nil;
    }

    return [self pageViewControllerAtIndex:current.page.index - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    PDFPageViewController *current = (PDFPageViewController *)viewController;
    return [self pageViewControllerAtIndex:current.page.index + 1];
}

#pragma mark - Init PDFPageViewController

- (PDFPageViewController *)pageViewControllerAtIndex:(NSUInteger)index
{
    PDFPage *page = [self.crop.document pageAtIndex:index];
    PDFPageViewController *vc =
            [[PDFPageCropViewController alloc] initWithPage:page];      
    return vc;
}

#pragma mark -

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIView *hit = [self.overlayView hitTest:[touch locationInView:self.overlayView]
                                  withEvent:nil];
    return (self.overlayView == hit);
}

- (void)singleTapped:(UITapGestureRecognizer *)recognizer
{
    [self toggleFullScreen];
}

#pragma mark -

- (BOOL)prefersStatusBarHidden
{
    return self.fullScreen;
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
    return self.crop.document.currentPage % 2 != 0;
}

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:PDFDocumentCropViewControllerSegueExit]) {
        if (self.crop.mode == PDFDocumentCropModeSame) {
            self.crop.oddCropRect = self.overlayView.cropRect;
            self.crop.evenCropRect = self.overlayView.cropRect;
        } else if (self.crop.mode == PDFDocumentCropModeDifferent) {
            if (self.isOddPage) {
                self.crop.oddCropRect = self.overlayView.cropRect;
            } else {
                self.crop.evenCropRect = self.overlayView.cropRect;
            }
        }
    }
}

#pragma mark -

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)
interfaceOrientation duration:(NSTimeInterval)duration
{
    PDFPageCropViewController *vc = self.pageViewController.viewControllers.firstObject;
    self.overlayView.targetRect = vc.contentFrame;
    self.overlayView.hidden = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.overlayView.hidden = NO;
}

@end
