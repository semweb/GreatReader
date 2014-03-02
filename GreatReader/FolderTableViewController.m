//
//  FolderTableViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/17.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "FolderTableViewController.h"

#import "FileCell.h"
#import "Folder.h"
#import "PDFDocument.h"
#import "PDFRecentDocumentList.h"
#import "PDFDocumentViewController.h"
#import "FolderTableDataSource.h"

NSString * const FolderTableViewControllerSeguePDFDocument = @"FolderTableViewControllerSeguePDFDocument";

@interface FolderTableViewController ()
@end

@implementation FolderTableViewController

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
    self.title = self.dataSource.title;

    self.automaticallyAdjustsScrollViewInsets = NO;
    UIEdgeInsets inset = self.tableView.contentInset;
    inset.bottom = 44;
    self.tableView.contentInset = inset;    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataSource.numberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource numberOfFilesInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FileCell";
    FileCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    File *file = [self.dataSource fileAtIndexPath:indexPath];
    cell.file = file;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return self.dataSource.title;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView beginUpdates]; {
            NSError *error = NULL;
            if ([self.dataSource removeItemAtIndexPath:indexPath error:&error]) {
                [tableView deleteRowsAtIndexPaths:@[indexPath]
                                 withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        } [tableView endUpdates];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    File *file = [self.dataSource fileAtIndexPath:indexPath];
    if ([file isKindOfClass:Folder.class]) {
        
    } else if ([file isKindOfClass:PDFDocument.class]) {
        [self performSegueWithIdentifier:FolderTableViewControllerSeguePDFDocument
                                  sender:[tableView cellForRowAtIndexPath:indexPath]];
    }
}

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{   
    if ([segue.identifier isEqualToString:FolderTableViewControllerSeguePDFDocument]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        PDFDocumentViewController *vc =
                (PDFDocumentViewController *)segue.destinationViewController;
        PDFDocument *document = (PDFDocument *)[self.dataSource fileAtIndexPath:indexPath];
        vc.document = [self.documentList open:document];
        vc.documentList = self.documentList;
    }
}

#pragma mark -

- (void)openDocumentsAtURL:(NSURL *)URL
{
    NSUInteger section = self.dataSource.numberOfSections - 1;
    NSUInteger count = [self.dataSource numberOfFilesInSection:section];
    for (int i = 0; i < count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i
                                                    inSection:section];
        File *file = [self.dataSource fileAtIndexPath:indexPath];
        if ([file.path.lastPathComponent isEqual:URL.lastPathComponent]) {
            [self.tableView selectRowAtIndexPath:indexPath
                                        animated:YES
                                  scrollPosition:UITableViewScrollPositionMiddle];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                [self performSegueWithIdentifier:FolderTableViewControllerSeguePDFDocument
                                          sender:cell];                    
            });
        }
    }
}

@end
