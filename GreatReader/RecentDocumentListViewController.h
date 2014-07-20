//
//  RecentDocumentListViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/20/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RecentDocumentListViewModel;

@interface RecentDocumentListViewController : UITableViewController
@property (nonatomic, strong) RecentDocumentListViewModel *viewModel;
@end
