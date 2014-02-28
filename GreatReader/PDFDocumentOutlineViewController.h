//
//  PDFDocumentOutlineViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/20.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFDocumentOutline;

@interface PDFDocumentOutlineViewController : UITableViewController
@property (nonatomic, strong) PDFDocumentOutline *outline;
@property (nonatomic, assign) NSUInteger currentPage;
@end
