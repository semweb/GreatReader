//
//  GRTNavigationController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/21/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "GRTNavigationController.h"

#import "PDFDocumentSettingViewController.h"

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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier
{
    NSDictionary *map = @{
        PDFDocumentSettingSegueCropOdd: PDFDocumentCropOddSegue.class,
        PDFDocumentSettingSegueCropEven: PDFDocumentCropOddSegue.class,
        PDFDocumentSettingSegueExit: PDFDocumentExitSettingSegue.class
    };
    BOOL isPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    if (isPhone && [map.allKeys containsObject:identifier]) {
        Class cls = [map objectForKey:identifier];
        return [[cls alloc] initWithIdentifier:identifier
                                        source:fromViewController
                                   destination:toViewController];
    }
    return [super segueForUnwindingToViewController:toViewController
                                 fromViewController:fromViewController
                                         identifier:identifier];
}

@end
