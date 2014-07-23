//
//  GRTNavigationController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/21/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "GRTNavigationController.h"

#import "PDFDocumentBrightnessViewController.h"

@interface DismissUnwindSegue : UIStoryboardSegue
@end

@implementation DismissUnwindSegue

- (void)perform
{
    [[self destinationViewController] dismissViewControllerAnimated:YES
                                                         completion:NULL];
}

@end


@interface GRTNavigationController ()

@end

@implementation GRTNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier
{
    BOOL isPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    if (isPhone) {
        return [[DismissUnwindSegue alloc]
                   initWithIdentifier:identifier
                               source:fromViewController
                          destination:toViewController];
    }
    return [super segueForUnwindingToViewController:toViewController
                                 fromViewController:fromViewController
                                         identifier:identifier];
}

@end
