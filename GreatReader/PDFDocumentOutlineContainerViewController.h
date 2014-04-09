//
//  PDFDocumentOutlineContainerViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 4/7/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFDocumentOutlineViewController;
@class PDFDocumentBookmarkListViewController;

@interface PDFDocumentOutlineContainerViewController : UIViewController
@property (nonatomic, strong) PDFDocumentOutlineViewController *outlineViewController;
@property (nonatomic, strong) PDFDocumentBookmarkListViewController *bookmarkListViewController;
@property (nonatomic, strong) UIViewController *currentViewController;
@end
