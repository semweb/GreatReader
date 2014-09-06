//
//  PDFDocumentBookmarkListViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2/25/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentBookmarkListViewController.h"

#import "Device.h"
#import "PDFDocumentBookmarkList.h"
#import "PDFDocumentViewController.h"

static NSString * const PDFDocumentBookmarkListSegueExit = @"PDFDocumentBookmarkListSegueExit";

@implementation PDFDocumentBookmarkListViewController
@synthesize bookmarkList = bookmarkList_;

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = LocalizedString(@".bookmarks");

    if (IsPhone()) {
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    }    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.bookmarkList.bookmarkedSectionList.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *sec = self.bookmarkList.bookmarkedSectionList[section];
    NSArray *bookmarks = sec[@"bookmarks"];
    return bookmarks.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *sec = self.bookmarkList.bookmarkedSectionList[section];
    NSString *title = sec[@"section"];
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookmarkCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    NSDictionary *sec = self.bookmarkList.bookmarkedSectionList[indexPath.section];
    NSNumber *bookmark = sec[@"bookmarks"][indexPath.row];
    cell.textLabel.text = [bookmark description];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:PDFDocumentBookmarkListSegueExit
                              sender:self];    
}


#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:PDFDocumentBookmarkListSegueExit]) {
        if (sender == self) {
            NSIndexPath *indexPath = self.tableView.indexPathForSelectedRow;
            NSDictionary *sec = self.bookmarkList.bookmarkedSectionList[indexPath.section];
            NSNumber *bookmark = sec[@"bookmarks"][indexPath.row];            

            PDFDocumentViewController *vc = segue.destinationViewController;
            [vc goAtIndex:[bookmark integerValue] animated:YES];
        }
    }
}


@end
