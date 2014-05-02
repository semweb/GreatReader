//
//  HomeViewController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2/26/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "HomeViewController.h"

#import "Folder.h"
#import "FolderTableDataSource.h"
#import "FolderTableViewController.h"
#import "PDFRecentDocumentList.h"
#import "PDFRecentDocumentListViewModel.h"
#import "PDFRecentDocumentListViewController.h"

NSString * const HomeViewControllerSegueEmbedFolder = @"HomeViewControllerSegueEmbedFolder";
NSString * const HomeViewControllerSegueEmbedRecent = @"HomeViewControllerSegueEmbedRecent";

@interface HomeViewController ()
@property (nonatomic, strong) PDFRecentDocumentList *documentList;
@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib
{
    self.title = @"GreatReader";
    self.documentList = [PDFRecentDocumentList new];
}

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{   
    if ([segue.identifier isEqualToString:HomeViewControllerSegueEmbedFolder]) {
        FolderTableViewController *vc = (FolderTableViewController *)segue.destinationViewController;
        vc.documentList = self.documentList;
        FolderTableDataSource *dataSource = [[FolderTableDataSource alloc] 
                                                initWithFolder:[Folder rootFolder]];
        vc.dataSource = dataSource;
        self.folderViewController = vc;
    } else if ([segue.identifier isEqualToString:HomeViewControllerSegueEmbedRecent]) {
        PDFRecentDocumentListViewController *vc = (PDFRecentDocumentListViewController *)segue.destinationViewController;
        PDFRecentDocumentListViewModel *model = [[PDFRecentDocumentListViewModel alloc]
                                                    initWithDocumentList:self.documentList
                                                           withoutActive:NO];
        vc.model = model;
        self.recentViewController = vc;
    }
}

@end
