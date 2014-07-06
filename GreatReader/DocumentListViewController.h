//
//  DocumentListViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/22/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DocumentListViewModel;

extern NSString * const DocumentListViewControllerCellIdentifier;
extern NSString * const DocumentListViewControllerSeguePDFDocument;

@interface DocumentListViewController : UIViewController
@property (nonatomic, strong) DocumentListViewModel *viewModel;
- (void)reload;
- (void)updateButtonsEnabled;

- (void)deselectAll:(BOOL)animated;
- (void)registerNibForCell;
- (void)reloadView;
- (NSArray *)selectedIndexPaths;
- (NSArray *)selectedDocuments;
- (void)openDocumentsAtURL:(NSURL *)URL;
- (void)deleteCellsAtIndexPaths:(NSArray *)indexPaths;
@end
