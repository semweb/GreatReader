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
    [self.viewModel removeObserver:self forKeyPath:@"sections"];
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
                     forKeyPath:@"sections"
                        options:NSKeyValueObservingOptionOld
                        context:NULL];
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
    return self.viewModel.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    PDFDocumentSearchViewSection *viewSection = self.viewModel.sections[section];
    return viewSection.results.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    PDFDocumentSearchViewSection *viewSection = self.viewModel.sections[section];    
    return viewSection.title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PDFDocumentSearchResult *result = [self.viewModel resultAtIndexPath:indexPath];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PDFDocumentSearchViewControllerCellIdentifier
                                                            forIndexPath:indexPath];
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
                PDFDocumentSearchResult *result = [self.viewModel resultAtIndexPath:indexPath];
     
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
    NSKeyValueChange kind = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
    if (kind == NSKeyValueChangeInsertion) {
        [self.tableView insertSections:indexes
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (kind == NSKeyValueChangeReplacement) {
        [self.tableView reloadSections:indexes
                      withRowAnimation:UITableViewRowAnimationAutomatic];
    } else {
        [self.tableView reloadData];
    }
}

@end
