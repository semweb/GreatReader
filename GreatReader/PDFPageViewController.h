//
//  PDFPageViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/12.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFPage;
@class PDFPageContentView;
@class PDFDocumentViewController;

@interface PDFPageViewController : UIViewController
- (instancetype)initWithPage:(PDFPage *)page;
@property (nonatomic, weak) PDFDocumentViewController *documentViewController;
@property (nonatomic, readonly) CGRect contentFrame;
@property (nonatomic, strong, readonly) PDFPageContentView *contentView;
@property (nonatomic, readonly) CGRect frameThatFits;
@property (nonatomic, strong, readonly) PDFPage *page;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, copy) void (^tapAction)(void);
@end
