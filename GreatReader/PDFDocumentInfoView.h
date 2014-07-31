//
//  PDFDocumentInfoView.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/17.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFDocumentInfo;

@interface PDFDocumentInfoView : UIView
@property (nonatomic, strong) PDFDocumentInfo *info;
- (void)show;
- (void)hide;
- (void)showAndHide;
@end
