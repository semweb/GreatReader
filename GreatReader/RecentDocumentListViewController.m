//
//  RecentDocumentListViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/20/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RecentDocumentListViewController.h"

#import "PDFDocument.h"
#import "PDFDocumentStore.h"
#import "PDFDocumentViewController.h"
#import "DocumentTableViewCell.h"
#import "RecentDocumentListViewModel.h"

static NSString * const RecentDocumentListViewControllerCellIdentifier = @"RecentDocumentListViewControllerCellIdentifier";
static NSString * const RecentDocumentListViewControllerSegueExit = @"RecentDocumentListViewControllerSegueExit";

@implementation RecentDocumentListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = self.viewModel.title;
    UINib *nib = [UINib nibWithNibName:@"DocumentTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:RecentDocumentListViewControllerCellIdentifier];

    UIBarButtonItem *doneItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                              target:self
                                                                              action:@selector(done:)];
    self.navigationItem.rightBarButtonItem = doneItem;
}

#pragma mark -

- (void)done:(id)sender
{
    [self performSegueWithIdentifier:RecentDocumentListViewControllerSegueExit
                              sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewModel.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DocumentTableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:RecentDocumentListViewControllerCellIdentifier];
    cell.document = [self.viewModel documentAtIndex:indexPath.row];
    if (indexPath.row == 0) {
        cell.backgroundColor = [UIColor colorWithRed:234/255.0 green:240/255.0 blue:249/255.0 alpha:1.0];
        cell.userInteractionEnabled = NO;
        cell.contentView.alpha = 0.6;
    } else {
        cell.backgroundColor = [UIColor clearColor];
        cell.userInteractionEnabled = YES;
        cell.contentView.alpha = 1.0;
    }
    return cell;
}

#pragma mark - Table View Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:RecentDocumentListViewControllerSegueExit
                              sender:[tableView cellForRowAtIndexPath:indexPath]];
}

#pragma mark -

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqual:RecentDocumentListViewControllerSegueExit] &&
        [sender isKindOfClass:UITableViewCell.class]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PDFDocumentViewController *vc =
                (PDFDocumentViewController *)segue.destinationViewController;
        PDFDocument *document = [self.viewModel documentAtIndex:indexPath.row];
        [vc openDocument:document];
        [document.store addHistory:document];        
    }
}

@end
