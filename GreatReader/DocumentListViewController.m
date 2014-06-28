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
#import "NSArray+GreatReaderAdditions.h"
#import "PDFRecentDocumentCell.h"
#import "PDFDocument.h"
#import "PDFDocumentStore.h"
#import "PDFRecentDocumentList.h"
#import "PDFDocumentViewController.h"

NSString * const DocumentListViewControllerCellIdentifier = @"DocumentListViewControllerCellIdentifier";
NSString * const DocumentListViewControllerSeguePDFDocument = @"DocumentListViewControllerSeguePDFDocument";

@interface DocumentListViewController () <UIActionSheetDelegate>
@property (nonatomic, strong) UIBarButtonItem *actionItem;
@property (nonatomic, strong) UIBarButtonItem *deleteItem;
@property (nonatomic, strong) UIDocumentInteractionController *interactionController;
@end

@implementation DocumentListViewController

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

    self.collectionView.allowsMultipleSelection = YES;

    self.navigationItem.title = self.viewModel.title;
    self.title = self.viewModel.title;

    self.navigationItem.rightBarButtonItem = self.editButtonItem;

    NSString *nibName = @"PDFRecentDocumentCell";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nibName = [nibName stringByAppendingString:@"_iPad"];
    } else {
        nibName = [nibName stringByAppendingString:@"_iPhone"];
    }
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    [self.collectionView registerNib:nib
          forCellWithReuseIdentifier:DocumentListViewControllerCellIdentifier];    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.collectionView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];

    if (editing) {
        self.deleteItem =
                [[UIBarButtonItem alloc] initWithTitle:@"Delete"
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
        [[self.collectionView indexPathsForSelectedItems]
                enumerateObjectsUsingBlock:^(NSIndexPath *indexPath, NSUInteger idx, BOOL *stop) {
            [self.collectionView deselectItemAtIndexPath:indexPath
                                                 animated:animated];
        }];
    }
}

#pragma mark - Edit Action

- (void)delete:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Delete"
                                              otherButtonTitles:nil];
    if (IsPad()) {
        [sheet showFromBarButtonItem:sender animated:YES];
    } else {
        [sheet showInView:self.view];
    }
}

- (void)performAction:(id)sender
{
    NSIndexPath *indexPath = [self.collectionView.indexPathsForSelectedItems firstObject];
    PDFDocument *doc = [self.viewModel documentAtIndex:indexPath.item];
    NSURL *URL = [NSURL fileURLWithPath:doc.path];
    self.interactionController =
            [UIDocumentInteractionController interactionControllerWithURL:URL];
    [self.interactionController presentOpenInMenuFromBarButtonItem:sender animated:YES];
}

- (void)updateButtonsEnabled
{
    self.deleteItem.enabled = self.collectionView.indexPathsForSelectedItems.count > 0;
    self.actionItem.enabled = self.collectionView.indexPathsForSelectedItems.count == 1;
}

#pragma mark - UIActionSheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.destructiveButtonIndex == buttonIndex) {
        NSArray *indexPaths = [self.collectionView indexPathsForSelectedItems];
        NSArray *documents = [indexPaths grt_map:^(NSIndexPath *indexPath) {
            return [self.viewModel documentAtIndex:indexPath.item];
        }];
        [self.viewModel deleteDocuments:documents];
        [self.collectionView deleteItemsAtIndexPaths:indexPaths];
        [self updateButtonsEnabled];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:DocumentListViewControllerSeguePDFDocument]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        UINavigationController *navi =
                (UINavigationController *)segue.destinationViewController;
        PDFDocumentViewController *vc =
                (PDFDocumentViewController *)navi.topViewController;
        vc.hidesBottomBarWhenPushed = YES;
        PDFDocument *document = (PDFDocument *)[self.viewModel documentAtIndex:indexPath.item];
        vc.document = document;
        [document.store addHistory:document];
    }
}

#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing) {
        [self updateButtonsEnabled];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing) {
        [self updateButtonsEnabled];
    } else {
        [self performSegueWithIdentifier:DocumentListViewControllerSeguePDFDocument
                                  sender:[collectionView cellForItemAtIndexPath:indexPath]];
        [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    }
}

- (void)collectionView:(UICollectionView *)collectionView
didHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.editing) {
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        cell.highlighted = NO;
    }
}

#pragma mark -

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PDFRecentDocumentCell *cell =
            [collectionView dequeueReusableCellWithReuseIdentifier:DocumentListViewControllerCellIdentifier
                                                      forIndexPath:indexPath];

    PDFDocument *document = [self.viewModel documentAtIndex:indexPath.item];
    cell.document = document;
    
    return cell;    
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.viewModel.count;
}

#pragma mark -

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return IsPad() ? CGSizeMake(180, 230) : CGSizeMake(100, 140);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return IsPad() ? 20 : 10;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(UICollectionViewLayout*)collectionViewLayout
        insetForSectionAtIndex:(NSInteger)section
{
    return IsPad() ? UIEdgeInsetsMake(40, 20, 40, 20) : UIEdgeInsetsMake(20, 10, 20, 10);
}

#pragma mark -

- (void)openDocumentsAtURL:(NSURL *)URL
{
    for (int i = 0; i < self.viewModel.count; i++) {
        PDFDocument *document = [self.viewModel documentAtIndex:i];
        if ([document.path.lastPathComponent isEqual:URL.lastPathComponent]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.collectionView selectItemAtIndexPath:indexPath
                                              animated:YES
                                        scrollPosition:UICollectionViewScrollPositionCenteredVertically];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
                [self performSegueWithIdentifier:DocumentListViewControllerSeguePDFDocument
                                          sender:cell];                                        
            });
        }
    }
}

#pragma mark -

- (void)reload
{
    [self.viewModel reload];
    [self.collectionView reloadData];
}

@end
