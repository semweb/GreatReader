//
//  PDFDocumentViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2013/12/17.
//  Copyright (c) 2013 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentViewController.h"

#import "GRTModalTransitionAnimator.h"
#import "PDFDocument.h"
#import "PDFDocumentBookmarkList.h"
#import "PDFDocumentBookmarkListViewController.h"
#import "PDFDocumentCrop.h"
#import "PDFDocumentCropViewController.h"
#import "PDFDocumentInfo.h"
#import "PDFDocumentInfoView.h"
#import "PDFDocumentBrightnessViewController.h"
#import "PDFDocumentOutline.h"
#import "PDFDocumentOutlineContainerViewController.h"
#import "PDFDocumentOutlineViewController.h"
#import "PDFDocumentPageSliderDataSource.h"
#import "PDFDocumentStore.h"
#import "PDFPage.h"
#import "PDFPageViewController.h"
#import "PDFRecentDocumentList.h"
#import "PDFRecentDocumentListViewModel.h"
#import "PDFRecentDocumentListViewController.h"

NSString * const PDFDocumentViewControllerSegueOutline = @"PDFDocumentViewControllerSegueOutline";
NSString * const PDFDocumentViewControllerSegueCrop = @"PDFDocumentViewControllerSegueCrop";
NSString * const PDFDocumentViewControllerSegueBrightness = @"PDFDocumentViewControllerSegueBrightness";
NSString * const PDFDocumentViewControllerSegueHistory = @"PDFDocumentViewControllerSegueHistory";

@interface PDFDocumentViewController () <UIPageViewControllerDataSource,
                                         UIPageViewControllerDelegate,
                                         UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, assign) BOOL fullScreen;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *cropItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *brightnessItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *searchItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *outlineItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *ribbonOffItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *ribbonOnItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *historyItem;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *findItem;
@property (nonatomic, strong) IBOutlet UIToolbar *toolbar;
@property (nonatomic, strong) IBOutlet PDFDocumentPageSlider *slider;
@property (nonatomic, strong) IBOutlet UIView *dimView;
@property (nonatomic, strong) PDFDocumentInfoView *infoView;
@end

@implementation PDFDocumentViewController

- (void)dealloc
{
    if (self.isViewLoaded) {
        [self removeObserver:self
                  forKeyPath:@"document.brightness"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor grayColor];
    [self prepareNavigationBar];

    self.pageViewController =
            [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                            navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                          options:@{UIPageViewControllerOptionInterPageSpacingKey:
                                                                    @(24)}];
    self.pageViewController.dataSource = self;
    self.pageViewController.delegate = self;
    [self addChildViewController:self.pageViewController];
    [self.view insertSubview:self.pageViewController.view
                belowSubview:self.dimView];
    self.pageViewController.view.frame = self.view.bounds;

    [self openDocument:self.document];
    self.dimView.alpha = (1 - self.document.brightness);
    
    [self addObserver:self
           forKeyPath:@"document.brightness"
              options:0
              context:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self addObserver:self
           forKeyPath:@"document.currentPageBookmarked"
              options:0
              context:NULL];
    [self addObserver:self
           forKeyPath:@"document.currentPage"
              options:0
              context:NULL];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self removeObserver:self forKeyPath:@"document.currentPageBookmarked"];
    [self removeObserver:self forKeyPath:@"document.currentPage"];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"document.currentPageBookmarked"]) {
        [self prepareNavigationBar];
    } else if ([keyPath isEqualToString:@"document.currentPage"]) {
        self.slider.currentIndex = self.document.currentPage;
    } else if ([keyPath isEqualToString:@"document.brightness"]) {
        self.dimView.alpha = (1 - self.document.brightness);
    }
}

#pragma mark - Open

- (void)openDocument:(PDFDocument *)document
{
    if (self.document != document) {
        self.document = document;
    }

    [self prepareToolbar];    
    [self prepareInfoView];
    [self goAtIndex:self.document.currentPage animated:NO];
}

#pragma mark -

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    if (self.document.currentPage == 1) {
        return nil;
    }

    return [self pageViewControllerAtIndex:self.document.currentPage - 1];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    return [self pageViewControllerAtIndex:self.document.currentPage + 1];
}

#pragma mark -

- (void)pageViewController:(UIPageViewController *)pageViewController
willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    if (!self.fullScreen) {
        self.fullScreen = !self.fullScreen;
    }
    for (PDFPageViewController *vc in pendingViewControllers) {
        if (self.currentPageViewController.scale && vc.scale != self.currentPageViewController.scale) {
            vc.scale = self.currentPageViewController.scale;
        }
    }
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    PDFPageViewController *vc = pageViewController.viewControllers.firstObject;
    self.document.currentPage = vc.page.index;
    self.slider.currentIndex = vc.page.index;
}

#pragma mark -

- (PDFPageViewController *)currentPageViewController
{
    PDFPageViewController *vc = self.pageViewController.viewControllers.firstObject;
    return vc;
}

#pragma mark - Init PDFPageViewController

- (PDFPageViewController *)pageViewControllerAtIndex:(NSUInteger)index
{
    PDFPage *page = [self.document pageAtIndex:index];
    if (!page) {
        return nil;
    }
    page.crop = self.document.crop;    
    PDFPageViewController *vc =
            [[PDFPageViewController alloc] initWithPage:page];
    UITapGestureRecognizer *doubleRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(doubleTapped:)];
    doubleRecognizer.numberOfTapsRequired = 2;
    [vc.view addGestureRecognizer:doubleRecognizer];
    UITapGestureRecognizer *singleRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(singleTapped:)];
    [singleRecognizer requireGestureRecognizerToFail:doubleRecognizer];
    [vc.view addGestureRecognizer:singleRecognizer];

    return vc;
}

#pragma mark -

- (void)prepareToolbar
{
    self.slider.delegate = self;
    PDFDocumentPageSliderDataSource *dataSource =
            [[PDFDocumentPageSliderDataSource alloc] initWithOutline:self.document.outline
                                                        bookmarkList:self.document.bookmarkList
                                                       numberOfPages:self.document.numberOfPages];
    self.slider.dataSource = dataSource;
    self.slider.currentIndex = self.document.currentPage;    
    [self.slider reloadData];
}

- (void)prepareNavigationBar
{
    UIBarButtonItem *ribbon = self.document.currentPageBookmarked
            ? self.ribbonOnItem : self.ribbonOffItem;

    UIView *base = ({
        UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 230, 44)];
        bar.clipsToBounds = YES;
        [bar setBackgroundImage:[UIImage new]
              forToolbarPosition:UIBarPositionAny
                      barMetrics:UIBarMetricsDefault];
        [bar setShadowImage:[UIImage new]
          forToolbarPosition:UIToolbarPositionAny];
        UIBarButtonItem *s = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil];
        [bar setItems:@[self.historyItem, s,
                        self.outlineItem, s,
                        self.cropItem, s,
                        self.brightnessItem, s,                        
                        self.findItem, s,
                        ribbon]
             animated:NO];
        bar;
    });
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                                                           target:nil
                                                                           action:nil];
    space.width = -20;
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:base];
    self.navigationItem.rightBarButtonItems = @[space, rightItem];

    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self
                                                                              action:@selector(done:)];
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (void)prepareInfoView
{
    PDFDocumentInfo *info = [[PDFDocumentInfo alloc] initWithDocument:self.document];    
    if (!self.infoView) {
        self.infoView = [[PDFDocumentInfoView alloc] initWithFrame:self.view.bounds];
        self.infoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.infoView];
    }
    self.infoView.info = info;
}

#pragma mark -

- (void)goAtIndex:(NSUInteger)index animated:(BOOL)animated
{
    UIPageViewControllerNavigationDirection direction = UIPageViewControllerNavigationDirectionForward;
    [self.pageViewController setViewControllers:@[[self pageViewControllerAtIndex:index]]
                                      direction:direction
                                       animated:animated
                                     completion:NULL];
    self.document.currentPage = index;
    [self.infoView show];
}

#pragma mark -

- (void)sliderChanged:(UISlider *)slider
{
    NSUInteger index = (NSUInteger)(slider.value * self.document.numberOfPages);
    [self goAtIndex:index animated:NO];
}

#pragma mark - Set FullScreen

- (void)setFullScreen:(BOOL)fullScreen
{
    _fullScreen = fullScreen;
    
    CGFloat alpha = self.fullScreen ? 0.0 : 1.0;
    CGRect barFrame = self.navigationController.navigationBar.frame;
    barFrame.origin.y = 20;
    self.navigationController.navigationBar.frame = barFrame;    
    if (!fullScreen) {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        self.navigationController.navigationBar.alpha = 0.0;                    
    }
    
    [UIView animateWithDuration:0.125
                     animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
        self.toolbar.alpha = alpha;
        self.navigationController.navigationBar.alpha = alpha;
    } completion:^(BOOL finished) {
        [self.navigationController setNavigationBarHidden:fullScreen animated:NO];            
    }];

    self.navigationController.navigationBar.frame = CGRectZero;
    self.navigationController.navigationBar.frame = barFrame;

    if (self.fullScreen) {
        [self.infoView hide];
    } else {
        [self.infoView show];
    }
}

#pragma mark - Tap

- (void)singleTapped:(id)sender
{
    self.fullScreen = !self.fullScreen;
}

- (void)doubleTapped:(id)sender
{

}

#pragma mark -

- (BOOL)prefersStatusBarHidden
{
    return self.fullScreen;
}

#pragma mark - UIBarButtonItem Action

- (void)done:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)showSearch:(id)sender
{

}

- (void)showSetting:(id)sender
{
    // [self performSegueWithIdentifier:PDFDocumentViewControllerSegueCrop
    //                           sender:sender];
}

- (void)showOutline:(id)sender
{
    [self performSegueWithIdentifier:PDFDocumentViewControllerSegueOutline
                              sender:sender];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{   
    if ([segue.identifier isEqualToString:PDFDocumentViewControllerSegueOutline]) {
        UINavigationController *navi =
                (UINavigationController *)segue.destinationViewController;
        PDFDocumentOutlineContainerViewController *vc =
                (PDFDocumentOutlineContainerViewController *)navi.topViewController;
        vc.outlineViewController.currentPage = self.document.currentPage;
        vc.outlineViewController.outline = [[PDFDocumentOutline alloc] initWithCGPDFDocument:self.document.CGPDFDocument];
        vc.bookmarkListViewController.bookmarkList = self.document.bookmarkList;
        vc.currentViewController = vc.outlineViewController;
    } else if ([segue.identifier isEqualToString:PDFDocumentViewControllerSegueCrop]) {
        UINavigationController *navi =
                (UINavigationController *)segue.destinationViewController;
        PDFDocumentCropViewController *vc =
                (PDFDocumentCropViewController *)navi.topViewController;
        vc.crop = self.document.crop;        
    } else if ([segue.identifier isEqualToString:PDFDocumentViewControllerSegueBrightness]) {
        PDFDocumentBrightnessViewController *vc =
                (PDFDocumentBrightnessViewController *)segue.destinationViewController;
        vc.document = self.document;
        vc.modalPresentationStyle = UIModalPresentationCustom;
        vc.transitioningDelegate = self;
    } else if ([segue.identifier isEqualToString:PDFDocumentViewControllerSegueHistory]) {
        PDFRecentDocumentListViewController *vc = (PDFRecentDocumentListViewController *)segue.destinationViewController;
        PDFRecentDocumentListViewModel *model = [[PDFRecentDocumentListViewModel alloc]
                                                    initWithDocumentList:self.document.store.documentList
                                                           withoutActive:YES];
        vc.model = model;
        vc.modalPresentationStyle = UIModalPresentationCustom;
        vc.transitioningDelegate = self;
    }

    if ([segue isKindOfClass:UIStoryboardPopoverSegue.class]) {
        UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
        UIPopoverController *popoverController = popoverSegue.popoverController;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            popoverController.passthroughViews = @[];
        });
    }
}

#pragma mark - Ribbon Action

- (IBAction)toggleRibbon:(id)sender
{
    [self.document toggleRibbon];
}

#pragma mark - Exit

- (IBAction)exitCrop:(UIStoryboardSegue *)segue
{
    [self goAtIndex:self.document.currentPage animated:NO];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // なぜかdimissされないので
        [self dismissViewControllerAnimated:YES
                                 completion:NULL];
    }
}

- (IBAction)exitBrightness:(UIStoryboardSegue *)segue {}

- (IBAction)exitOutline:(UIStoryboardSegue *)segue {}

- (IBAction)exitBookmark:(UIStoryboardSegue *)segue {}

- (IBAction)exitHistory:(UIStoryboardSegue *)segue {}

#pragma mark - PDFDocumentPageSlider Delegate, DataSouce

- (void)pageSlider:(PDFDocumentPageSlider *)slider didSelectAtIndex:(NSUInteger)index
{
    [self goAtIndex:index animated:NO];
}

- (void)pageSlider:(PDFDocumentPageSlider *)slider
pageThumbnailAtIndex:(NSUInteger)index
          callback:(void (^)(UIImage *, NSUInteger))callback
{
    PDFPage *page = [self.document pageAtIndex:index + 1];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [page thumbnailImageWithSize:CGSizeMake(30, 40) cropping:NO];            
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(image, index);
        });
    });
}

- (NSUInteger)numberOfPagesInPageSlider:(PDFDocumentPageSlider *)slider
{
    return self.document.numberOfPages;
}

#pragma mark -

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    GRTModalTransitionAnimator *animator = [GRTModalTransitionAnimator new];
    animator.presentedContentHeight = [self heightForViewController:presented];
    animator.presenting = YES;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    GRTModalTransitionAnimator *animator = [GRTModalTransitionAnimator new];
    animator.presentedContentHeight = [self heightForViewController:dismissed];
    return animator;
}

#pragma mark -

- (CGFloat)heightForViewController:(UIViewController *)viewController
{
    if ([viewController isKindOfClass:PDFDocumentBrightnessViewController.class]) {
        return 108;
    } else if ([viewController isKindOfClass:PDFRecentDocumentListViewController.class]) {
        return 180;
    } else {
        return 0;
    }
}


@end
