//
//  PDFRecentDocumentListViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/07.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFRecentDocumentListViewModel;

@interface PDFRecentDocumentListViewController : UIViewController {
    UICollectionView *collectionView_;
}
@property (nonatomic, strong) PDFRecentDocumentListViewModel *model;
@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;
@end
