//
//  GRTNavigationController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 9/1/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "GRTNavigationController.h"

@implementation GRTNavigationController

- (UIViewController *)childViewControllerForStatusBarStyle
{
    if (self.presentedViewController) {
        return self.presentedViewController;
    }
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.visibleViewController;
}

@end
