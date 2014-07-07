//
//  PDFDocumentSearchViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/9/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentSearchViewController.h"

#import "PDFDocumentSearchViewModel.h"
#import "PDFDocumentSearchResult.h"
#import "PDFDocumentViewController.h"
#import "NSArray+GreatReaderAdditions.h"

NSString * const PDFDocumentSearchViewControllerSegueExit = @"PDFDocumentSearchViewControllerSegueExit";
NSString * const PDFDocumentSearchViewControllerCellIdentifier = @"PDFDocumentSearchViewControllerCellIdentifier";

@interface PDFDocumentSearchViewController () <UISearchBarDelegate>
@property (nonatomic, strong) UISearchBar *searchBar;
@end

@implementation PDFDocumentSearchViewController

- (void)dealloc
{
    [self.viewModel removeObserver:self forKeyPath:@"results"];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.searchBar = [[UISearchBar alloc] initWithFrame:[self.navigationController.navigationBar bounds]];
    self.searchBar.delegate = self;
    self.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchBar.showsCancelButton = YES;
    [self.searchBar becomeFirstResponder];
    self.navigationItem.titleView = self.searchBar;

    [self.viewModel addObserver:self
                     forKeyPath:@"results"
                        options:NSKeyValueObservingOptionOld
                        context:NULL];
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewModel.results.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PDFDocumentSearchViewControllerCellIdentifier
                                                            forIndexPath:indexPath];
    PDFDocumentSearchResult *result = self.viewModel.results[indexPath.row];
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.textLabel.text = [NSString stringWithFormat:@"page: %d\n%@",
                                    (int)result.page,
                                    result.surroundingText];
    return cell;
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:PDFDocumentSearchViewControllerSegueExit]) {
        if (sender == self) {
            NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
            if (indexPath) {
                PDFDocumentSearchResult *result = self.viewModel.results[indexPath.row];
     
                PDFDocumentViewController *vc = segue.destinationViewController;
                [vc goAtIndex:result.page animated:YES];
            }
        }
    }
}

#pragma mark - UISearchBarDelegate

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self performSegueWithIdentifier:PDFDocumentSearchViewControllerSegueExit
                              sender:self];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.viewModel startSearchWithKeyword:searchBar.text];
    [self.searchBar resignFirstResponder];
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSIndexSet *indexes = [change objectForKey:NSKeyValueChangeIndexesKey];
    NSMutableArray *indexPaths = [NSMutableArray array];
    NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
    if (kind == NSKeyValueChangeInsertion) {
        [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            [indexPaths addObject:[NSIndexPath indexPathForRow:idx
                                                     inSection:0]];
        }];
        [self.tableView insertRowsAtIndexPaths:indexPaths
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView reloadData];
    }
}

@end
