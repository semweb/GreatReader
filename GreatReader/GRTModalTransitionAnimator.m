//
//  GRTModalTransitionAnimator.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/2/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "GRTModalTransitionAnimator.h"

@implementation GRTModalTransitionAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.25f;
}

- (UIButton *)dimButton
{
    static dispatch_once_t onceToken;
    static UIButton *button = nil;
    dispatch_once(&onceToken, ^{
        button = [GRTModalDismissButton buttonWithType:UIButtonTypeCustom];
    });
    return button;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    UIButton *button = self.dimButton;
    button.frame = fromViewController.view.frame;

    if (self.presenting) {
        fromViewController.view.userInteractionEnabled = NO;

        button.alpha = 0.0;
        [transitionContext.containerView addSubview:button];
        
        [transitionContext.containerView addSubview:toViewController.view];
        toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth
              | UIViewAutoresizingFlexibleBottomMargin;
        toViewController.view.frame = fromViewController.view.frame;
        CGRect endFrame = ({
            CGRect f = toViewController.view.frame;
            f.size = [self sizeForViewController:toViewController];
            f;
        });
        toViewController.view.frame = [self hideFrameForViewController:toViewController];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext]
                         animations:^{
            fromViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
            button.alpha = 0.1;
            toViewController.view.frame = endFrame;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
    else {
        toViewController.view.userInteractionEnabled = YES;

        button.alpha = 0.1;
        [transitionContext.containerView insertSubview:button
                                          belowSubview:fromViewController.view];
        
        [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
            button.alpha = 0.0;
            fromViewController.view.frame =
                [self hideFrameForViewController:fromViewController];
            toViewController.view.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

- (CGRect)hideFrameForViewController:(UIViewController *)viewController
{
    CGRect f = viewController.view.frame;
    switch (viewController.interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            f.origin.x -= self.presentedContentHeight;
            break;
        case UIInterfaceOrientationLandscapeRight:
            f.origin.x += self.presentedContentHeight;
            break;
        default:
            f.origin.y -= self.presentedContentHeight;
            break;
    }
    f.size = [self sizeForViewController:viewController];
    return f;
}

- (CGSize)sizeForViewController:(UIViewController *)viewController
{
    CGSize size = viewController.view.frame.size;
    switch (viewController.interfaceOrientation) {
        case UIInterfaceOrientationLandscapeLeft:
            size.width = self.presentedContentHeight;
            break;
        case UIInterfaceOrientationLandscapeRight:
            size.width = self.presentedContentHeight;            
            break;
        default:
            size.height = self.presentedContentHeight;            
            break;
    }
    return size;
}

@end


@implementation GRTModalDismissButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        [self addTarget:self
                 action:@selector(dismiss:)
       forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)dismiss:(id)sender
{
    [self.window.rootViewController dismissViewControllerAnimated:YES
                                                       completion:NULL];
}

@end
