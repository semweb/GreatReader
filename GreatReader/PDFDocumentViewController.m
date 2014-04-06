//
//  PDFDocumentViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2013/12/17.
//  Copyright (c) 2013 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentViewController.h"

#import "PDFDocument.h"
#import "PDFDocumentBookmarkList.h"
#import "PDFDocumentBookmarkListViewController.h"
#import "PDFDocumentCrop.h"
#import "PDFDocumentCropViewController.h"
#import "PDFDocumentInfo.h"
#import "PDFDocumentInfoView.h"
#import "PDFDocumentSettingViewController.h"
#import "PDFDocumentOutline.h"
#import "PDFDocumentOutlineViewController.h"
#import "PDFPage.h"
#import "PDFPageViewController.h"
#import "PDFRecentDocumentList.h"
#import "PDFRecentDocumentListViewController.h"

NSString * const PDFDocumentViewControllerSegueOutline = @"PDFDocumentViewControllerSegueOutline";
NSString * const PDFDocumentViewControllerSegueCropOdd = @"PDFDocumentViewControllerSegueCropOdd";
NSString * const PDFDocumentViewControllerSegueCropEven = @"PDFDocumentViewControllerSegueCropEven";
NSString * const PDFDocumentViewControllerSegueBookmark = @"PDFDocumentViewControllerSegueBookmark";
NSString * const PDFDocumentViewControllerSegueSetting = @"PDFDocumentViewControllerSegueSetting";

@interface PDFDocumentViewController () <UIPageViewControllerDataSource,
                              UIPageViewControllerDelegate>
@property (nonatomic, strong) UIPageViewController *pageViewController;
@property (nonatomic, assign) BOOL fullScreen;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *settingItem;
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
    [self removeObserver:self
              forKeyPath:@"document.brightness"];
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
        self.slider.currentIndex = self.document.currentPage - 1;
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
}

- (void)pageViewController:(UIPageViewController *)pageViewController
        didFinishAnimating:(BOOL)finished
   previousViewControllers:(NSArray *)previousViewControllers
       transitionCompleted:(BOOL)completed
{
    PDFPageViewController *vc = pageViewController.viewControllers.firstObject;
    self.document.currentPage = vc.page.index;
    self.slider.currentIndex = vc.page.index - 1;
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
    self.slider.dataSource = self;
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
                        self.settingItem, s,
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
    [UIView animateWithDuration:0.125
                 animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
        self.toolbar.alpha = alpha;
        self.navigationController.navigationBar.alpha = alpha;
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
        PDFDocumentOutlineViewController *vc =
                (PDFDocumentOutlineViewController *)navi.topViewController;
        vc.currentPage = self.document.currentPage;
        vc.outline = [[PDFDocumentOutline alloc] initWithCGPDFDocument:self.document.CGPDFDocument];
    } else if ([segue.identifier isEqualToString:PDFDocumentViewControllerSegueBookmark]) {
        UINavigationController *navi =
                (UINavigationController *)segue.destinationViewController;
        PDFDocumentBookmarkListViewController *vc =
                (PDFDocumentBookmarkListViewController *)navi.topViewController;
        vc.bookmarkList = self.document.bookmarkList;
    } else if ([segue.identifier isEqualToString:PDFDocumentViewControllerSegueSetting]) {
        PDFDocumentSettingViewController *vc =
                (PDFDocumentSettingViewController *)segue.destinationViewController;
        vc.document = self.document;
        self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    } else if ([segue.identifier isEqualToString:PDFDocumentViewControllerSegueCropOdd]) {
        UINavigationController *navi =
                (UINavigationController *)segue.destinationViewController;
        PDFDocumentCropViewController *vc =
                (PDFDocumentCropViewController *)navi.topViewController;
        vc.crop = self.document.crop;        
        vc.even = NO;
    } else if ([segue.identifier isEqualToString:PDFDocumentViewControllerSegueCropEven]) {
        UINavigationController *navi =
                (UINavigationController *)segue.destinationViewController;
        PDFDocumentCropViewController *vc =
                (PDFDocumentCropViewController *)navi.topViewController;
        vc.crop = self.document.crop;        
        vc.even = YES;
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

- (IBAction)exitSetting:(UIStoryboardSegue *)segue {}

- (IBAction)exitOutline:(UIStoryboardSegue *)segue {}

- (IBAction)exitBookmark:(UIStoryboardSegue *)segue {}

#pragma mark - PDFDocumentPageSlider Delegate, DataSouce

- (void)pageSlider:(PDFDocumentPageSlider *)slider didSelectAtIndex:(NSUInteger)index
{
    [self goAtIndex:index + 1 animated:NO];
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

@end
