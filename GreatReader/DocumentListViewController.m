//
//  DocumentListViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/22/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "DocumentListViewController.h"

#import "Device.h"
#import "DocumentListViewModel.h"
#import "DocumentModalTransitionAnimator.h"
#import "NSArray+GreatReaderAdditions.h"
#import "PDFDocument.h"
#import "PDFDocumentStore.h"
#import "PDFRecentDocumentList.h"
#import "PDFDocumentViewController.h"
#import "UIColor+GreatReaderAdditions.h"

NSString * const DocumentListViewControllerCellIdentifier = @"DocumentListViewControllerCellIdentifier";
NSString * const DocumentListViewControllerSeguePDFDocument = @"DocumentListViewControllerSeguePDFDocument";

@interface DocumentListViewController () <UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) UIBarButtonItem *actionItem;
@property (nonatomic, strong) UIBarButtonItem *deleteItem;
@property (nonatomic, strong) UIDocumentInteractionController *interactionController;
@end

@implementation DocumentListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = self.viewModel.title;
    self.title = self.viewModel.title;    

    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    [self registerNibForCell];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self reloadView];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    if (self.editing) {
        [self setEditing:NO animated:NO];
    }
}

#pragma mark -

- (void)setViewModel:(DocumentListViewModel *)viewModel
{
    _viewModel = viewModel;
    self.navigationItem.title = self.viewModel.title;
    self.title = self.viewModel.title;
}

#pragma mark -

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    [self setBarEditing:editing];

    if (editing) {
        self.deleteItem =
                [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@"Delete")
                                                 style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(delete:)];
        self.deleteItem.enabled = NO;
        self.actionItem =
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                              target:self
                                                              action:@selector(performAction:)];
        self.actionItem.enabled = NO;
        [self.navigationItem setLeftBarButtonItems:@[self.deleteItem, self.actionItem]
                                          animated:animated];
    } else {
        self.deleteItem = nil;
        self.actionItem = nil;
        [self.navigationItem setLeftBarButtonItems:@[] animated:animated];

        [self deselectAll:animated];
    }
}

- (void)setBarEditing:(BOOL)editing
{
    UIColor *barTintColor = editing ? [UIColor grt_defaultTintColor] : nil;
    UIColor *tintColor = editing ? [UIColor whiteColor] : [UIColor grt_defaultTintColor];
    UIColor *titleColor = editing ? [UIColor whiteColor] : [UIColor blackColor];
    self.navigationController.navigationBar.barTintColor = barTintColor;
    self.navigationController.navigationBar.tintColor = tintColor;
    [self.navigationController.navigationBar setTitleTextAttributes:
                                   @{ NSForegroundColorAttributeName: titleColor }];
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark -

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.editing ? UIStatusBarStyleLightContent : UIStatusBarStyleDefault;
}

#pragma mark - Edit Action

- (void)delete:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:LocalizedString(@"Cancel")
                                         destructiveButtonTitle:LocalizedString(@"Delete")
                                              otherButtonTitles:nil];
    if (IsPad()) {
        [sheet showFromBarButtonItem:sender animated:YES];
    } else {
        [sheet showInView:self.view];
    }
}

- (void)performAction:(id)sender
{
    PDFDocument *doc = [self.selectedDocuments firstObject];
    NSURL *URL = [NSURL fileURLWithPath:doc.path];
    self.interactionController =
            [UIDocumentInteractionController interactionControllerWithURL:URL];
    [self.interactionController presentOpenInMenuFromBarButtonItem:sender animated:YES];
}

- (void)updateButtonsEnabled
{
    self.deleteItem.enabled = self.selectedIndexPaths.count > 0;
    self.actionItem.enabled = self.selectedIndexPaths.count == 1;
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.destructiveButtonIndex == buttonIndex) {
        [self.viewModel deleteDocuments:self.selectedDocuments];
        [self deleteCellsAtIndexPaths:self.selectedIndexPaths];
        [self updateButtonsEnabled];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:DocumentListViewControllerSeguePDFDocument]) {
        UINavigationController *navi =
                (UINavigationController *)segue.destinationViewController;
        PDFDocumentViewController *vc =
                (PDFDocumentViewController *)navi.topViewController;
        vc.hidesBottomBarWhenPushed = YES;
        PDFDocument *document = [self.selectedDocuments firstObject];
        vc.document = document;
        [document.store addHistory:document];
        navi.modalPresentationStyle = UIModalPresentationCustom;
        navi.transitioningDelegate = self;
    }
}

#pragma mark -

- (NSArray *)selectedDocuments
{
    return [self.selectedIndexPaths grt_map:^(NSIndexPath *indexPath) {
        return [self.viewModel documentAtIndex:indexPath.item];
    }];    
}

#pragma mark - UIViewControllerTransitioningDelegate Methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented
                                                                   presentingController:(UIViewController *)presenting
                                                                       sourceController:(UIViewController *)source
{
    DocumentModalTransitionAnimator *animator = [DocumentModalTransitionAnimator new];
    animator.presenting = YES;
    return animator;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    DocumentModalTransitionAnimator *animator = [DocumentModalTransitionAnimator new];
    return animator;
}

#pragma mark -

- (void)reload
{
    [self.viewModel reload];
    [self reloadView];
}

- (void)deselectAll:(BOOL)animated {}
- (void)registerNibForCell {}
- (void)reloadView {}
- (NSArray *)selectedIndexPaths { return nil; }
- (void)openDocumentsAtURL:(NSURL *)URL {}
- (void)deleteCellsAtIndexPaths:(NSArray *)indexPaths {}
- (id<DocumentCell>)selectedDocumentCell { return nil; }
- (id<DocumentCell>)documentCellForDocument:(PDFDocument *)document { return nil; }

@end
