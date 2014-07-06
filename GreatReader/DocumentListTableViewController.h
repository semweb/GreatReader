//
//  DocumentListTableViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/5/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DocumentListViewController.h"

@interface DocumentListTableViewController : DocumentListViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end
