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
#import "Folder.h"
#import "FolderDocumentListViewModel.h"
#import "PDFDocumentStore.h"
#import "PDFRecentDocumentList.h"
#import "PDFDocumentViewController.h"
#import "UIColor+GreatReaderAdditions.h"

#define DELETE_SHEET_TAG 1
#define   MOVE_SHEET_TAG 2

NSString * const DocumentListViewControllerCellIdentifier = @"DocumentListViewControllerCellIdentifier";
NSString * const DocumentListViewControllerSeguePDFDocument = @"DocumentListViewControllerSeguePDFDocument";
NSString * const DocumentListViewControllerSegueFolder = @"DocumentListViewControllerSegueFolder";

@interface DocumentListViewController () <UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) UIBarButtonItem *actionItem;
@property (nonatomic, strong) UIBarButtonItem *deleteItem;
@property (nonatomic, strong) UIBarButtonItem *moveToItem;
@property (nonatomic, strong) UIDocumentInteractionController *interactionController;
@end

@implementation DocumentListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

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
                [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@".delete")
                                                 style:UIBarButtonItemStylePlain
                                                target:self
                                                action:@selector(delete:)];
        self.deleteItem.enabled = NO;
        self.actionItem =
                [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                              target:self
                                                              action:@selector(performAction:)];
        self.actionItem.enabled = NO;
        NSArray *barButtonItems = @[self.deleteItem, self.actionItem];
        if ([self isMoveToBarButtonItemNeeded]) {
            self.moveToItem =
                    [[UIBarButtonItem alloc] initWithTitle:LocalizedString(@".move-to")
                                                     style:UIBarButtonItemStylePlain
                                                    target:self
                                                    action:@selector(move:)];
            self.moveToItem.enabled = NO;
            barButtonItems = [barButtonItems arrayByAddingObject:self.moveToItem];
        }
        [self.navigationItem setLeftBarButtonItems:barButtonItems
                                          animated:animated];
    } else {
        self.deleteItem = nil;
        self.actionItem = nil;
        if ([self isMoveToBarButtonItemNeeded]) {
            self.moveToItem = nil;
        }
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

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - Edit Action

- (void)delete:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:LocalizedString(@".cancel")
                                         destructiveButtonTitle:LocalizedString(@".delete")
                                              otherButtonTitles:nil];
    sheet.tag = DELETE_SHEET_TAG;
    [self showActionSheet:sheet forSender:sender];
}

- (void)move:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:LocalizedString(@".cancel")
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:LocalizedString(@".new-folder"), nil];
    sheet.tag = MOVE_SHEET_TAG;
    [self showActionSheet:sheet forSender:sender];
}

- (void)showActionSheet:(UIActionSheet *)sheet forSender:(id)sender
{
    if (IsPad()) {
        [sheet showFromBarButtonItem:sender animated:YES];
    } else {
        [sheet showInView:self.view];
    }
}

- (void)showCreateFolderAlertView
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:LocalizedString(@".create-folder-alert-title")
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:LocalizedString(@".cancel")
                                              otherButtonTitles:LocalizedString(@".ok"), nil] ;
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
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
    self.actionItem.enabled = (self.selectedIndexPaths.count == 1) && ![self.viewModel checkIfHasFolderInDocuments:self.selectedDocuments];
    if ([self isMoveToBarButtonItemNeeded]) {
        self.moveToItem.enabled = (self.selectedIndexPaths.count > 0) && ![self.viewModel checkIfHasFolderInDocuments:self.selectedDocuments];
    }
}

#pragma mark - Create folder

- (void)createFolderNamed:(NSString *)folderName
{
    NSError *error = nil;
    if ([self.viewModel createFolderInCurrentFolderWithName:folderName error:&error] != nil) {
        [self reload];
    } else {
        [self showAlertForError:error];
    }
}

- (void)createFolderNamed:(NSString *)folderName andMoveDocuments:(NSArray *)documetns
{
    NSError *error = nil;
    if ([self.viewModel createFolderInCurrentFolderWithName:folderName andMoveDocuments:documetns error:&error]) {
        [self reload];
        [self updateButtonsEnabled];
    } else {
        [self showAlertForError:error];
    }
}

#pragma mark - Delete documents

- (void)deleteSelectedDocuments
{
    NSError *error = nil;
    if ([self.viewModel deleteDocuments:self.selectedDocuments error:&error]) {
        [self deleteCellsAtIndexPaths:self.selectedIndexPaths];
        [self updateButtonsEnabled];
    } else {
        [self showAlertForError:error];
    }
}

#pragma mark -

- (void)showAlertForError:(NSError *)error
{
    NSString *errorDesc = error.localizedDescription;
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil
                                                        message:errorDesc
                                                       delegate:nil
                                              cancelButtonTitle:nil
                                              otherButtonTitles:LocalizedString(@".ok"), nil] ;
    [alertView show];
}

#pragma mark - UIAlertView Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:LocalizedString(@".ok")]) {
        UITextField *alertTextField = [alertView textFieldAtIndex:0];
        NSString *folderName = alertTextField.text;
        [self createFolderNamed:folderName andMoveDocuments:self.selectedDocuments];
    }
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [actionSheet buttonTitleAtIndex:buttonIndex];

    if (actionSheet.tag == DELETE_SHEET_TAG) {
        if (actionSheet.destructiveButtonIndex == buttonIndex) {
            [self deleteSelectedDocuments];
        }
    } else if (actionSheet.tag == MOVE_SHEET_TAG) {
        if ([title isEqualToString:LocalizedString(@".new-folder")]) {
            [self showCreateFolderAlertView];
        }
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
    } else if ([segue.identifier isEqual:DocumentListViewControllerSegueFolder]) {
        DocumentListViewController *folderListViewController = (DocumentListViewController *)segue.destinationViewController;
        Folder *folder = [self.selectedDocuments firstObject];
        FolderDocumentListViewModel *folderModel = [[FolderDocumentListViewModel alloc] initWithFolder:folder];
        folderListViewController.viewModel = folderModel;
        [folderListViewController reload];
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
- (BOOL)isMoveToBarButtonItemNeeded { return NO; }

@end
