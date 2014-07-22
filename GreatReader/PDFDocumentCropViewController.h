//
//  PDFDocumentCropViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/21.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFDocument;
@class PDFDocumentCrop;

@interface PDFDocumentCropViewController : UIViewController
@property (nonatomic, strong) PDFDocumentCrop *crop;
@property (nonatomic, strong) PDFDocument *document;
@property (nonatomic, assign) BOOL even;
@end

@interface PDFDocumentCropLayoutView : UIView
@end
