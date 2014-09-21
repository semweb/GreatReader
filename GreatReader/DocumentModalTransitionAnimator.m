//
//  DocumentModalTransitionAnimator.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/19/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "DocumentModalTransitionAnimator.h"

#import "DocumentCell.h"
#import "DocumentListViewController.h"
#import "PDFDocumentViewController.h"
#import "PDFDocument.h"
#import "PDFPageViewController.h"

@implementation DocumentModalTransitionAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25f;
}

- (DocumentListViewController *)documentListViewControllerFromContainer:(UIViewController *)container
{
    UITabBarController *tabbar = (UITabBarController *)container;
    UINavigationController *navi = (UINavigationController *)[tabbar selectedViewController];
    return (DocumentListViewController *)[navi topViewController];
}

- (PDFDocumentViewController *)documentViewControllerFromContainer:(UIViewController *)container
{
    UINavigationController *navi = (UINavigationController *)container;
    return (PDFDocumentViewController *)[navi topViewController];
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIViewController *documentListContainer =
            self.presenting ? fromViewController : toViewController;
    UIViewController *documentContainer =
            self.presenting ? toViewController : fromViewController;

    toViewController.view.frame = fromViewController.view.frame;
    if (self.presenting) {
        [transitionContext.containerView addSubview:toViewController.view];
        toViewController.view.hidden = YES;
    } else {
        fromViewController.view.hidden = YES;
    }

    DocumentListViewController *documentListViewController =
            [self documentListViewControllerFromContainer:documentListContainer];
    PDFDocumentViewController *documentViewController =
            [self documentViewControllerFromContainer:documentContainer];
    if (!self.presenting) {
        [documentListViewController reload];
    }

    // Even if device is landscape, view frame is not rotated.
    // Need to layout here.
    [toViewController.view layoutIfNeeded];

    id<DocumentCell> documentCell = self.presenting
            ? [documentListViewController selectedDocumentCell]
            : [documentListViewController documentCellForDocument:documentViewController.document];
    UIImageView *imageView = documentCell.imageView;
    UIImage *image = imageView.image;
    CGRect frameInDocumentList = [imageView convertRect:imageView.bounds
                                                 toView:documentListContainer.view];
    UIView *backgroundView = [[UIView alloc] initWithFrame:fromViewController.view.bounds];
    backgroundView.alpha = self.presenting ? 0 : 1;
    backgroundView.backgroundColor = [UIColor grayColor];
    [documentListContainer.view addSubview:backgroundView];
    UIImageView *animationView = [[UIImageView alloc] initWithImage:image];
    animationView.layer.borderWidth = 1.0 / [[UIScreen mainScreen] scale];
    animationView.layer.borderColor = [UIColor blackColor].CGColor;
    [documentListContainer.view addSubview:animationView];

    CGRect frameInDocument = [documentViewController.view convertRect:[[documentViewController currentPageViewController] contentFrame]
                                                               toView:documentContainer.view];

    CGRect fromRect = self.presenting ? frameInDocumentList : frameInDocument;
    CGRect toRect = self.presenting ? frameInDocument : frameInDocumentList;
    animationView.frame = fromRect;

    [UIView performSystemAnimation:0
                           onViews:@[]
                           options:0
                        animations:^{
        animationView.frame = toRect;
        backgroundView.alpha = self.presenting ? 1 : 0;
    } completion:^(BOOL finished) {
        toViewController.view.hidden = NO;
        [backgroundView removeFromSuperview];
        [animationView removeFromSuperview];
        [transitionContext completeTransition:YES];
    }];
}

@end
