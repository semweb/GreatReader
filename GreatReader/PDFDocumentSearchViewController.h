//
//  PDFDocumentSearchViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/9/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFDocumentSearchViewModel;

@interface PDFDocumentSearchViewController : UITableViewController
@property (nonatomic, strong) PDFDocumentSearchViewModel *viewModel;
@end
