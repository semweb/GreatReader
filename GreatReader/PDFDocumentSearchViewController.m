//
//  PDFDocumentSearchViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/9/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentSearchViewController.h"

#import <KVOController/FBKVOController.h>

#import "PDFDocumentSearchViewModel.h"
#import "PDFDocumentSearchResult.h"
#import "PDFDocumentSearchStateCell.h"
#import "PDFDocumentViewController.h"
#import "NSArray+GreatReaderAdditions.h"

static NSString * const PDFDocumentSearchViewControllerSegueExit = @"PDFDocumentSearchViewControllerSegueExit";
static NSString * const PDFDocumentSearchViewControllerCellIdentifier = @"PDFDocumentSearchViewControllerCellIdentifier";

@interface PDFDocumentSearchViewController () <UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) PDFDocumentSearchStateCell *stateCell;
@property (nonatomic, strong) FBKVOController *kvoController;
@end

@implementation PDFDocumentSearchViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.kvoController = [FBKVOController controllerWithObserver:self];

    self.searchBar = [[UISearchBar alloc] initWithFrame:[self.navigationController.navigationBar bounds]];
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    [self.searchBar becomeFirstResponder];
    self.navigationItem.titleView = self.searchBar;

    UIBarButtonItem *cancelItem = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                           target:self
                                                           action:@selector(cancel:)];
    self.navigationItem.rightBarButtonItem = cancelItem;

    PDFDocumentSearchStateCell *cell = [[PDFDocumentSearchStateCell alloc] init];
    self.stateCell = cell;
    [self.kvoController observe:self.viewModel
                        keyPath:@"searching"
                        options:0
                          block:^(id vc, PDFDocumentSearchViewModel *vm, NSDictionary *change) {
        cell.searching = vm.searching;
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.viewModel stopSearch];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:PDFDocumentSearchViewControllerSegueExit
                              sender:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.viewModel.sections.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == tableView.numberOfSections - 1) {
        return 1;
    } else {
        PDFDocumentSearchViewSection *viewSection = self.viewModel.sections[section];
        return viewSection.results.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == tableView.numberOfSections - 1) {
        return nil;
    } else {    
        PDFDocumentSearchViewSection *viewSection = self.viewModel.sections[section];
        return viewSection.title;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == tableView.numberOfSections - 1) {
        return self.stateCell;
    }

    PDFDocumentSearchResult *result = [self.viewModel resultAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PDFDocumentSearchViewControllerCellIdentifier
                                                            forIndexPath:indexPath];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.attributedText = result.attributedDescription;
    return cell;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:PDFDocumentSearchViewControllerSegueExit]) {
        if (sender == self) {
            NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
            if (indexPath) {
                PDFDocumentSearchResult *result = [self.viewModel resultAtIndexPath:indexPath];
     
                PDFDocumentViewController *vc = segue.destinationViewController;
                [vc goAtIndex:result.page animated:YES];
            }
        }
    }
}

#pragma mark - Cancel

- (void)cancel:(id)sender
{
    [self performSegueWithIdentifier:PDFDocumentSearchViewControllerSegueExit
                              sender:self];
}

#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.viewModel startSearchWithKeyword:searchBar.text
                                foundBlock:^(NSUInteger section, NSUInteger row) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row
                                                    inSection:section];
        if (row == 0) {
            NSIndexSet *set = [NSIndexSet indexSetWithIndex:section];
            [self.tableView insertSections:set
                          withRowAnimation:UITableViewRowAnimationTop];
        } else {
            [self.tableView insertRowsAtIndexPaths:@[indexPath]
                                  withRowAnimation:UITableViewRowAnimationTop];
        }
    } completionBlock:^(BOOL finished) {
    }];

    [self.tableView reloadData];
    [self.searchBar resignFirstResponder];
}

@end
