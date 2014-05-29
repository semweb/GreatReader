//
//  PDFRecentDocumentListViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/07.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFRecentDocumentListViewController.h"

#import "FileCell.h"
#import "GRTArrayController.h"
#import "PDFDocument.h"
#import "PDFDocumentStore.h"
#import "PDFDocumentViewController.h"
#import "PDFRecentDocumentCell.h"
#import "PDFRecentDocumentList.h"
#import "PDFRecentDocumentListViewModel.h"

NSString * const PDFRecentDocumentListViewControllerCellIdentifier = @"PDFRecentDocumentListViewControllerCellIdentifier";
NSString * const PDFRecentDocumentListViewControllerSeguePDFDocument = @"PDFRecentDocumentListViewControllerSeguePDFDocument";

@interface PDFRecentDocumentListViewController () <UICollectionViewDelegate,
                                                   UICollectionViewDataSource>

@end

@implementation PDFRecentDocumentListViewController

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"model.documents"];
}

- (void)awakeFromNib
{
    [self addObserver:self
           forKeyPath:@"model.documents"
              options:0
              context:NULL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    NSString *nibName = @"PDFRecentDocumentCell";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        nibName = [nibName stringByAppendingString:@"_iPad"];
    } else {
        nibName = [nibName stringByAppendingString:@"_iPhone"];
    }
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    [self.collectionView registerNib:nib
          forCellWithReuseIdentifier:PDFRecentDocumentListViewControllerCellIdentifier];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.collectionView reloadData];
}

#pragma mark -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.model.documents.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PDFRecentDocumentCell *cell =
            [collectionView dequeueReusableCellWithReuseIdentifier:PDFRecentDocumentListViewControllerCellIdentifier
                                                      forIndexPath:indexPath];

    PDFDocument *document = self.model.documents[indexPath.row];
    cell.document = document;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:PDFRecentDocumentListViewControllerSeguePDFDocument
                              sender:[collectionView cellForItemAtIndexPath:indexPath]];
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{   
    if ([segue.identifier isEqualToString:PDFRecentDocumentListViewControllerSeguePDFDocument]) {
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:sender];
        PDFDocumentViewController *vc =
                (PDFDocumentViewController *)segue.destinationViewController;
        PDFDocument *document = self.model.documents[indexPath.row];
        [vc openDocument:document];
        [document.store addHistory:document];
    }
}

@end
