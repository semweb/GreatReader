//
//  ViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2013/12/17.
//  Copyright (c) 2013年 semwebapp. All rights reserved.
//

#import "ViewController.h"

#import "PDFDocument.h"
#import "PDFPage.h"
#import "PDFPageViewController.h"

@interface ViewController () <UIPageViewControllerDataSource,
                              UIPageViewControllerDelegate>
@property (nonatomic, strong) PDFDocument *document;
@property (nonatomic, strong) UIPageViewController *pageViewController;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    NSString *file = [[NSBundle mainBundle] pathForResource:@"Land_of_Lisp_ja"
                                                     ofType:@"pdf"];
    self.document = [[PDFDocument alloc] initWithFile:file];
    // PDFPage *page = [doc pageAtIndex:1];
    // self.pageViewController =
    //         [[PDFPageViewController alloc] initWithPage:page];
    self.pageViewController =
            [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                                            navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                                                          options:@{UIPageViewControllerOptionInterPageSpacingKey:
                                                                    @(24)}];
    PDFPage *page = [self.document pageAtIndex:1];    
    [self.pageViewController setViewControllers:@[[[PDFPageViewController alloc] initWithPage:page]]
                                      direction:UIPageViewControllerNavigationDirectionForward
                                       animated:NO
                                     completion:NULL];
    self.pageViewController.dataSource = self;
    // self.pageViewController.delegate = self;
    [self addChildViewController:self.pageViewController];
    [self.view addSubview:self.pageViewController.view];
    self.pageViewController.view.frame = self.view.bounds;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerBeforeViewController:(UIViewController *)viewController
{
    PDFPageViewController *current = (PDFPageViewController *)viewController;
    if (current.page.index == 1) {
        return nil;
    }
    
    PDFPage *page = [self.document pageAtIndex:current.page.index - 1];
    return [[PDFPageViewController alloc] initWithPage:page];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController
       viewControllerAfterViewController:(UIViewController *)viewController
{
    PDFPageViewController *current = (PDFPageViewController *)viewController;
    PDFPage *page = [self.document pageAtIndex:current.page.index + 1];
    return [[PDFPageViewController alloc] initWithPage:page];
}

@end
