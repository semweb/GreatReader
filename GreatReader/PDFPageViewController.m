//
//  PDFPageViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/12.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFPageViewController.h"

#import "PDFPage.h"
#import "PDFPageContentView.h"
#import "PDFPageScanner.h"

@interface PDFPageScrollView : UIScrollView
@end

@implementation PDFPageScrollView
@end

@interface PDFPageViewController () <UIScrollViewDelegate>
@property (nonatomic, strong, readwrite) PDFPage *page;
@property (nonatomic, strong) PDFPageContentView *contentView;
@property (nonatomic, strong) UIImageView *lowResolutionView;
@property (nonatomic, strong) UIPopoverController *popover;
@end

@implementation PDFPageViewController

- (instancetype)initWithPage:(PDFPage *)page
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _page = page;

        PDFPageScanner *scanner = [[PDFPageScanner alloc] initWithCGPDFPage:page.CGPDFPage];
        page.characters = [scanner scanStringContents];
    }
    return self;
}

- (void)loadView
{
    PDFPageScrollView *scrollView =
            [[PDFPageScrollView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    scrollView.minimumZoomScale = 1.0f;
    scrollView.maximumZoomScale = 4.0f;
    scrollView.delegate = self;
    self.view = scrollView;
}

- (PDFPageScrollView *)scrollView
{
    return (PDFPageScrollView *)self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    self.contentView = [[PDFPageContentView alloc] initWithFrame:[self frameThatFits]];
    self.contentView.page = self.page;
    [self.view addSubview:self.contentView];
    [self.scrollView setContentSize:self.contentView.frame.size];

    UITapGestureRecognizer *tapGestureRecognizer =
            [[UITapGestureRecognizer alloc] initWithTarget:self
                                                    action:@selector(doubleTapped:)];
    tapGestureRecognizer.numberOfTapsRequired = 2;
    [self.contentView addGestureRecognizer:tapGestureRecognizer];

    UILongPressGestureRecognizer *longPressGestureRecognizer =
            [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(longPressed:)];
    [self.contentView addGestureRecognizer:longPressGestureRecognizer];

    // CATiledLayerの描画が始まるまで、低画質で描画しておく
    UIImage *lowResolutionImage = [self.page thumbnailImageWithSize:self.contentView.frame.size
                                                           cropping:YES];
    self.lowResolutionView = [[UIImageView alloc] initWithImage:lowResolutionImage];
    self.lowResolutionView.frame = self.contentView.frame;
    [self.view insertSubview:self.lowResolutionView atIndex:0];
}

- (CGRect)frameThatFits
{
    CGRect pageRect = self.page.croppedRect;
    CGFloat pageRatio = pageRect.size.height / pageRect.size.width;
    CGFloat viewRatio = self.view.frame.size.height / self.view.frame.size.width;
    if (pageRatio > viewRatio) {
        pageRect.size.height = self.view.frame.size.height;
        pageRect.size.width = pageRect.size.height / pageRatio;        
    }
    else {
        pageRect.size.width = self.view.frame.size.width;
        pageRect.size.height = pageRect.size.width * pageRatio;
    }
    return pageRect;
}

- (CGRect)contentFrame
{
    CGSize boundsSize = self.view.bounds.size;
    CGRect frameToCenter = self.contentView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    } else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    } else {
        frameToCenter.origin.y = 0;
    }
    return frameToCenter;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    self.contentView.frame = self.contentFrame;
    self.lowResolutionView.frame = self.contentFrame;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.contentView;
}

#pragma mark - Double Tapped

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer
{
    if (self.scrollView.zoomScale == 1.0) {
        const CGFloat zoom = 2.0;
        CGPoint point = [recognizer locationInView:self.contentView];
        CGFloat width = CGRectGetWidth(self.contentView.frame) / zoom;
        CGFloat height = width * (CGRectGetHeight(self.contentView.frame) / CGRectGetWidth(self.contentView.frame));
        CGFloat x = MAX(1.0, point.x - width / 2.0);
        CGFloat y = MAX(1.0, point.y - height / 2.0);
        [self.scrollView zoomToRect:CGRectMake(x, y, width, height)
                           animated:YES];
    } else {
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
}

- (void)longPressed:(UILongPressGestureRecognizer *)recognizer
{
    CGPoint point = [recognizer locationInView:self.contentView];
    CGFloat scale = self.contentView.scale;
    PDFRenderingCharacter *c = [self.page characterAtPoint:CGPointMake(point.x / scale,
                                                                       point.y / scale)];
    if (c) {
        [self.page selectWordForCharacter:c];
    }

    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self showSelectionMenuFromRect:self.contentView.selectionFrame
                                 inView:self.contentView];
    }
}

- (void)showSelectionMenuFromRect:(CGRect)rect
                           inView:(UIView *)view
{
    UIMenuController *menuController = [UIMenuController sharedMenuController];
    NSMutableArray* menuItems = [NSMutableArray array];
    [menuItems addObject:
                   [[UIMenuItem alloc] initWithTitle:@"Copy"
                                              action:@selector(copySelectedString:)]];
    [menuItems addObject:
                   [[UIMenuItem alloc] initWithTitle:@"Define"
                                              action:@selector(lookupSelectedString:)]];    
    menuController.menuItems = menuItems;
    menuController.arrowDirection = UIMenuControllerArrowDefault;
    [menuController setTargetRect:rect
                           inView:view];
    [self becomeFirstResponder];
    [menuController setMenuVisible:YES animated:YES];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(lookupSelectedString:)) ||
            (action == @selector(copySelectedString:));
}

- (void)lookupSelectedString:(id)sender
{
    NSString *term = self.page.selectedString;
    UIReferenceLibraryViewController *vc = [[UIReferenceLibraryViewController alloc]
                                               initWithTerm:term];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:vc];
        [self.popover presentPopoverFromRect:self.contentView.selectionFrame
                                      inView:self.contentView
                    permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
                                    animated:YES];
    } else {
        [self presentViewController:vc
                           animated:YES
                         completion:NULL];        
    }
}

- (void)copySelectedString:(id)sender
{
    NSString *term = self.page.selectedString;    
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:term];
}

@end
