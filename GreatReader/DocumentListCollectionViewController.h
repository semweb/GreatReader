//
//  DocumentListCollectionViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/6/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "DocumentListViewController.h"

@interface DocumentListCollectionViewController : DocumentListViewController <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@end
