//
//  HomeViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2/26/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FolderTableViewController;
@class PDFRecentDocumentListViewController;

@interface HomeViewController : UIViewController
@property (nonatomic, strong) FolderTableViewController *folderViewController;
@property (nonatomic, strong) PDFRecentDocumentListViewController *recentViewController;
@end
