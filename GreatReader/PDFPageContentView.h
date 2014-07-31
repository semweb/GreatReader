//
//  PDFPageContentView.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/12.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFPage;
@class PDFPageContentView;
@class PDFPageLink;

@protocol PDFPageContentViewDelegate <NSObject>
- (void)contentView:(PDFPageContentView *)contentView
   copyMenuSelected:(NSString *)selectedString;
- (void)contentView:(PDFPageContentView *)contentView
 lookupMenuSelected:(NSString *)selectedString;
- (UIView *)loopeContainerViewForContentView:(PDFPageContentView *)contentView;
@end

@interface PDFPageContentView : UIView
@property (nonatomic, strong) PDFPage *page;
@property (nonatomic, readonly) CGFloat scale;
@property (nonatomic, readonly) CGRect selectionFrame;
@property (nonatomic, weak) id<PDFPageContentViewDelegate> delegate;
- (void)showLoopeAtPoint:(CGPoint)point
                  inView:(UIView *)containerView;
- (void)hideLoope;
- (void)redraw;
- (void)zoomStarted;
- (void)zoomFinished;
@end
