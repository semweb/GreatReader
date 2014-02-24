//
//  PDFDocumentBookmarkListViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2/25/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFDocumentBookmarkList;

@interface PDFDocumentBookmarkListViewController : UITableViewController
@property (nonatomic, strong) PDFDocumentBookmarkList *bookmarkList;
@end
