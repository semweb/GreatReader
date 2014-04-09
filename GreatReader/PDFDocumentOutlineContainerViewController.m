//
//  PDFDocumentOutlineContainerViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 4/7/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentOutlineContainerViewController.h"

#import "PDFDocumentOutlineViewController.h"
#import "PDFDocumentBookmarkListViewController.h"

@interface PDFDocumentOutlineContainerViewController ()
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl;
@end

@implementation PDFDocumentOutlineContainerViewController

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

- (void)setCurrentViewController:(UIViewController *)currentViewController
{
    if (_currentViewController) {
        [_currentViewController removeFromParentViewController];
        [_currentViewController.view removeFromSuperview];
    }
    _currentViewController = currentViewController;
    [self addChildViewController:currentViewController];
    [self.view addSubview:currentViewController.view];
}

- (PDFDocumentOutlineViewController *)outlineViewController
{
    if (!_outlineViewController) {
        self.outlineViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PDFDocumentOutlineViewController"];
    }
    return _outlineViewController;
}

- (PDFDocumentBookmarkListViewController *)bookmarkListViewController
{
    if (!_bookmarkListViewController) {
        self.bookmarkListViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"PDFDocumentBookmarkListViewController"];
    }
    return _bookmarkListViewController;
}

- (IBAction)segmentChanged:(id)sender
{
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0:
            if (self.currentViewController == self.bookmarkListViewController) {
                self.currentViewController = self.outlineViewController;
            }
            return;
        case 1:
            if (self.currentViewController == self.outlineViewController) {
                self.currentViewController = self.bookmarkListViewController;
            }
            return;            
        default:
            return;
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
