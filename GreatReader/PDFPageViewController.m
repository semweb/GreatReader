//
//  PDFPageViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/12.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFPageViewController.h"

#import "Device.h"
#import "PDFDocumentOutlineItem.h"
#import "PDFDocumentViewController.h"
#import "PDFPage.h"
#import "PDFPageContentView.h"
#import "PDFPageLink.h"
#import "PDFPageLinkList.h"
#import "PDFPageScanner.h"
#import "PDFPageSelectionKnob.h"

@interface PDFPageScrollView : UIScrollView
@end

@implementation PDFPageScrollView
@end

@interface PDFPageViewController () <UIScrollViewDelegate,
                                     UIGestureRecognizerDelegate,
                                     PDFPageContentViewDelegate>
@property (nonatomic, strong, readwrite) PDFPage *page;
@property (nonatomic, strong, readwrite) PDFPageContentView *contentView;
@property (nonatomic, strong) UIImageView *lowResolutionView;
@property (nonatomic, strong) UIPopoverController *popover;
@end

@implementation PDFPageViewController

- (instancetype)initWithPage:(PDFPage *)page
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _page = page;

        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, ^{
            PDFPageScanner *scanner = [[PDFPageScanner alloc] initWithCGPDFPage:page.CGPDFPage];
            NSArray *characters = [scanner scanStringContents];
            dispatch_async(dispatch_get_main_queue(), ^{
                page.characters = characters;
            });
        });
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
    scrollView.clipsToBounds = NO;
    self.view = scrollView;
}

- (PDFPageScrollView *)scrollView
{
    return (PDFPageScrollView *)self.view;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.contentView = [[PDFPageContentView alloc] initWithFrame:self.frameThatFits];
    self.contentView.delegate = self;
    self.contentView.page = self.page;
    [self.view addSubview:self.contentView];
    [self.scrollView setContentSize:self.contentView.frame.size];

    [self.contentView addGestureRecognizer:({
        UITapGestureRecognizer *tapGestureRecognizer =
                [[UITapGestureRecognizer alloc] initWithTarget:self
                                                        action:@selector(doubleTapped:)];
        tapGestureRecognizer.delegate = self;
        tapGestureRecognizer.numberOfTapsRequired = 2;
        tapGestureRecognizer;
    })];
    [self.contentView addGestureRecognizer:({
        UITapGestureRecognizer *tapGestureRecognizer =
                [[UITapGestureRecognizer alloc] initWithTarget:self
                                                        action:@selector(singleTapped:)];
        tapGestureRecognizer.delegate = self;        
        tapGestureRecognizer.numberOfTapsRequired = 1;
        tapGestureRecognizer;
    })];    

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
    CGRect frame = self.contentView.frame;

    CGRect pageRect = self.page.croppedRect;
    CGFloat pageRatio = pageRect.size.height / pageRect.size.width;
    CGFloat viewRatio = boundsSize.height / boundsSize.width;

    frame.size = ({
        CGSize size = frame.size;
        if (CGAffineTransformEqualToTransform(self.contentView.transform,
                                              CGAffineTransformIdentity)) {
            if (viewRatio > 1.0) {
                if (pageRatio > viewRatio) {
                    size.height = boundsSize.height;
                    size.width = size.height / pageRatio;
                } else {
                    size.width = boundsSize.width;
                    size.height = size.width * pageRatio;
                }
            } else {
                size.width = boundsSize.width;
                size.height = size.width * pageRatio;
            }
        }
        size;
    });

    frame.origin = ({
        CGPoint origin = frame.origin;
        if (frame.size.width <= boundsSize.width) {
            origin.x = (boundsSize.width - frame.size.width) / 2;
        } else {
            origin.x = 0;
        }

        if (frame.size.height < boundsSize.height) {
            origin.y = (boundsSize.height - frame.size.height) / 2;
        } else {
            origin.y = 0;
        }
        origin;
    });

    return frame;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];

    self.contentView.frame = self.contentFrame;
    self.lowResolutionView.frame = self.contentFrame;
    self.scrollView.contentSize = self.contentView.frame.size;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.contentView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if (self.lowResolutionView) {
        [self.lowResolutionView removeFromSuperview];
        self.lowResolutionView = nil;
    }
    [self.contentView zoomStarted];
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    [self.contentView zoomFinished];
}

#pragma mark - Tapped

- (void)singleTapped:(UITapGestureRecognizer *)recognizer
{
    CGFloat scale = self.contentView.scale;
    CGPoint point = [recognizer locationInView:self.contentView];
    PDFPageLink *link = [self.page linkAtPoint:CGPointMake(point.x / scale,
                                                           point.y / scale)];
    if (link) {
        [self.documentViewController goAtIndex:link.pageNumber
                                      animated:YES];
    } else if (self.tapAction) {
        self.tapAction();
    }
}

- (void)doubleTapped:(UITapGestureRecognizer *)recognizer
{
    if (self.scrollView.zoomScale == 1.0) {
        const CGFloat zoom = 2.0;
        CGPoint point = [recognizer locationInView:self.contentView];
        CGFloat width = CGRectGetWidth(self.view.frame) / zoom;
        CGFloat height = width * (CGRectGetHeight(self.view.frame) / CGRectGetWidth(self.view.frame));
        CGFloat x = MAX(1.0, point.x - width / 2.0);
        CGFloat y = MAX(1.0, point.y - height / 2.0);
        [self.scrollView zoomToRect:CGRectMake(x, y, width, height)
                           animated:YES];
    } else {
        [self.scrollView setZoomScale:1.0 animated:YES];
    }
}

#pragma mark -

- (CGFloat)scale
{
    return self.scrollView.zoomScale;
}

- (void)setScale:(CGFloat)scale
{
    self.scrollView.zoomScale = scale;
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 10, 10)
                                animated:NO];
}

#pragma mark -

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.page unselectCharacters];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.contentView redraw];
}

#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return self.page.selectedCharacters.count == 0;
}

#pragma mark -

- (UIMenuController *)selectionMenuForContentView:(PDFPageContentView *)contentView
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
    return menuController;
}

- (void)contentView:(PDFPageContentView *)contentView
   copyMenuSelected:(NSString *)selectedString
{
    UIPasteboard *pb = [UIPasteboard generalPasteboard];
    [pb setString:selectedString];
}

- (void)contentView:(PDFPageContentView *)contentView
 lookupMenuSelected:(NSString *)selectedString
{
    UIReferenceLibraryViewController *vc = [[UIReferenceLibraryViewController alloc]
                                               initWithTerm:selectedString];
    if (IsPad()) {
        self.popover = [[UIPopoverController alloc] initWithContentViewController:vc];
        [self.popover presentPopoverFromRect:contentView.selectionFrame
                                      inView:contentView
                    permittedArrowDirections:UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown
                                    animated:YES];
    } else {
        [self presentViewController:vc
                           animated:YES
                         completion:nil];        
    }
}

- (UIView *)loopeContainerViewForContentView:(PDFPageContentView *)contentView
{
    return self.navigationController.view;
}

@end
