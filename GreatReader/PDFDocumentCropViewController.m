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

@interface PDFDocumentCropViewController () <UIPageViewControllerDelegate, UIPageViewControllerDataSource>
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, strong) IBOutlet PDFDocumentCropOverlayView *overlayView;
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

    [self goAtIndex:self.crop.document.currentPage animated:NO];
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
    if (!CGRectEqualToRect(self.crop.cropRect, CGRectZero)) {
        self.overlayView.cropRect = self.crop.cropRect;
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:PDFDocumentCropViewControllerSegueExit]) {
        self.crop.cropRect = self.overlayView.cropRect;
    }
}

@end
