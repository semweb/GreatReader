//
//  DocumentListViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/22/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DocumentCell;
@class PDFDocument;
@class DocumentListViewModel;

extern NSString * const DocumentListViewControllerCellIdentifier;
extern NSString * const DocumentListViewControllerSeguePDFDocument;
extern NSString * const DocumentListViewControllerSegueFolder;

@interface DocumentListViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) DocumentListViewModel *viewModel;
- (void)reload;
- (void)updateButtonsEnabled;
- (void)showAlertForError:(NSError *)error;

- (void)deselectAll:(BOOL)animated;
- (void)registerNibForCell;
- (void)reloadView;
- (NSArray *)selectedIndexPaths;
- (NSArray *)selectedDocuments;
- (void)openDocumentsAtURL:(NSURL *)URL;
- (void)deleteCellsAtIndexPaths:(NSArray *)indexPaths;
- (id<DocumentCell>)selectedDocumentCell;
- (id<DocumentCell>)documentCellForDocument:(PDFDocument *)document;
- (BOOL)isMoveToBarButtonItemNeeded;
@end
