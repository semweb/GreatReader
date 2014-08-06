//
//  GRTModalViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/2/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "GRTModalViewController.h"

@interface GRTModalViewController ()
@property (nonatomic, strong, readwrite) IBOutlet UIView *dimView;
@property (nonatomic, strong, readwrite) IBOutlet UIView *sheetView;
@property (nonatomic, strong, readwrite) IBOutlet NSLayoutConstraint *heightConstraint;
@end

@implementation GRTModalViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (IBAction)dismiss:(id)sender
{
    [self.view removeFromSuperview];
}

- (void)show
{
    self.dimView.alpha = 0.1;
    
    UIView *parent = self.view.superview;
    self.view.frame = parent.bounds;

    UIViewController *child = self.childViewControllers[0];
    self.sheetView.frame = ({
        CGRect f = child.view.bounds;
        f.size.width = CGRectGetWidth(self.view.frame);
        f.origin.y -= CGRectGetHeight(self.view.frame);
        f;
    });

    self.sheetView.backgroundColor = [UIColor redColor];

    [UIView animateWithDuration:0.4
                     animations:^{
        CGRect f = self.sheetView.frame;
        f.origin.y = 0;
        self.sheetView.frame = f;
    self.dimView.frame = self.view.bounds;            
    }];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.view.frame = ({
        CGRect f = self.view.frame;
        f.size.width = self.view.superview.frame.size.height;
        f;
    });
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
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

@implementation UIViewController (GRTModalViewController)

- (void)grt_presentSheetModal:(UIViewController *)vc
                contentHeight:(CGFloat)height
{
    GRTModalViewController *modal =
            [self.storyboard instantiateViewControllerWithIdentifier:@"GRTModalViewController"];
    [modal addChildViewController:vc];
    [modal.sheetView addSubview:vc.view];    
    [self.view addSubview:modal.view];
    modal.heightConstraint.constant = height;    
    [modal show];
}

@end
