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
#import "PDFRecentDocumentCell.h"
#import "PDFDocument.h"
#import "PDFDocumentStore.h"
#import "PDFRecentDocumentList.h"
#import "PDFDocumentViewController.h"

NSString * const DocumentListViewControllerCellIdentifier = @"DocumentListViewControllerCellIdentifier";
NSString * const DocumentListViewControllerSeguePDFDocument = @"DocumentListViewControllerSeguePDFDocument";

@interface DocumentListViewController ()

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

    self.navigationItem.title = self.viewModel.title;
    self.title = self.viewModel.title;

    // Do any additional setup after loading the view.
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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:DocumentListViewControllerSeguePDFDocument]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        PDFDocumentViewController *vc =
                (PDFDocumentViewController *)segue.destinationViewController;
        vc.hidesBottomBarWhenPushed = YES;
        PDFDocument *document = (PDFDocument *)[self.viewModel documentAtIndex:indexPath.row];
        vc.document = document;
        [document.store addHistory:document];
    }
}

#pragma mark -

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:DocumentListViewControllerSeguePDFDocument
                              sender:[collectionView cellForItemAtIndexPath:indexPath]];
}

#pragma mark -

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PDFRecentDocumentCell *cell =
            [collectionView dequeueReusableCellWithReuseIdentifier:DocumentListViewControllerCellIdentifier
                                                      forIndexPath:indexPath];

    PDFDocument *document = [self.viewModel documentAtIndex:indexPath.row];
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

@end
