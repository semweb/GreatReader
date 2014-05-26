//
//  DocumentListViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/22/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentListViewModel;

@interface DocumentListViewController : UICollectionViewController
@property (nonatomic, strong) DocumentListViewModel *viewModel;
@end
