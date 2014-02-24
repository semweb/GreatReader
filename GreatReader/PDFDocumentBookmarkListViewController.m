//
//  PDFDocumentBookmarkListViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2/25/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentBookmarkListViewController.h"

#import "PDFDocumentBookmarkList.h"
#import "PDFDocumentViewController.h"

NSString * const PDFDocumentBookmarkListSegueExit = @"PDFDocumentBookmarkListSegueExit";

@interface PDFDocumentBookmarkListViewController ()

@end

@implementation PDFDocumentBookmarkListViewController
@synthesize bookmarkList = bookmarkList_;

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

    self.title = @"Bookmarks";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.bookmarkList.bookmarkList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookmarkCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSNumber *bookmark = self.bookmarkList.bookmarkList[indexPath.row];
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
            NSNumber *bookmark = self.bookmarkList.bookmarkList[indexPath.row];

            PDFDocumentViewController *vc = segue.destinationViewController;
            [vc goAtIndex:[bookmark integerValue] animated:YES];
        }
    }
}


@end
