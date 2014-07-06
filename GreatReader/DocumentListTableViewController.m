//
//  DocumentListTableViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/5/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "DocumentListTableViewController.h"

#import "Device.h"
#import "DocumentListViewModel.h"
#import "DocumentTableViewCell.h"
#import "NSArray+GreatReaderAdditions.h"
#import "PDFRecentDocumentCell.h"
#import "PDFDocument.h"
#import "PDFDocumentStore.h"
#import "PDFRecentDocumentList.h"
#import "PDFDocumentViewController.h"

@interface DocumentListTableViewController ()

@end

@implementation DocumentListTableViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    self.tableView.allowsMultipleSelectionDuringEditing = editing;    
    [self.tableView setEditing:editing animated:animated];
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
            [tableView dequeueReusableCellWithIdentifier:DocumentListViewControllerCellIdentifier];
    cell.document = [self.viewModel documentAtIndex:indexPath.row];
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSUInteger index = indexPath.row;
        [self.viewModel deleteDocuments:@[[self.viewModel documentAtIndex:index]]];
        [tableView deleteRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing) {
        [self updateButtonsEnabled];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing) {
        [self updateButtonsEnabled];
    } else {
        [self performSegueWithIdentifier:DocumentListViewControllerSeguePDFDocument
                                  sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

#pragma mark -

- (void)registerNibForCell
{
    UINib *nib = [UINib nibWithNibName:@"DocumentTableViewCell" bundle:nil];
    [self.tableView registerNib:nib
         forCellReuseIdentifier:DocumentListViewControllerCellIdentifier];
}

- (void)reloadView
{
    [self.tableView reloadData];
}

- (NSArray *)selectedIndexPaths
{
    return self.tableView.indexPathsForSelectedRows;
}

- (void)deleteCellsAtIndexPaths:(NSArray *)indexPaths
{
    [self.tableView deleteRowsAtIndexPaths:indexPaths
                          withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)openDocumentsAtURL:(NSURL *)URL
{
    for (int i = 0; i < self.viewModel.count; i++) {
        PDFDocument *document = [self.viewModel documentAtIndex:i];
        if ([document.path.lastPathComponent isEqual:URL.lastPathComponent]) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.tableView selectRowAtIndexPath:indexPath
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionMiddle];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                [self performSegueWithIdentifier:DocumentListViewControllerSeguePDFDocument
                                          sender:cell];
            });
        }
    }
}

@end
