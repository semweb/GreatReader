//
//  FolderTableViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/17.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFRecentDocumentList;
@class FolderTableDataSource;

@interface FolderTableViewController : UITableViewController
@property (nonatomic, strong) PDFRecentDocumentList *documentList;
@property (nonatomic, strong) FolderTableDataSource *dataSource;
@end
