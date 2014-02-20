//
//  PDFRecentDocumentListViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/07.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFRecentDocumentListViewController.h"

#import "FileCell.h"
#import "PDFDocumentViewController.h"
#import "PDFRecentDocumentCell.h"
#import "PDFRecentDocumentList.h"

NSString * const PDFRecentDocumentListViewControllerSeguePDFDocument = @"PDFRecentDocumentListViewControllerSeguePDFDocument";

@interface PDFRecentDocumentListViewController ()

@end

@implementation PDFRecentDocumentListViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.tableView reloadData];
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.documentList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DocumentCell";
    FileCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    cell.file = (File *)[self.documentList documentAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{   
    if ([segue.identifier isEqualToString:PDFRecentDocumentListViewControllerSeguePDFDocument]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PDFDocumentViewController *vc =
                (PDFDocumentViewController *)segue.destinationViewController;
        PDFDocument *document = [self.documentList documentAtIndex:indexPath.row];
        [vc openDocument:[self.documentList open:document]];
    }
}

@end
