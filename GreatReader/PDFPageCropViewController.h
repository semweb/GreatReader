//
//  PDFPageCropViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/21.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFPageViewController.h"

@class PDFDocumentCrop;

@interface PDFPageCropViewController : PDFPageViewController
@property (nonatomic, strong) PDFDocumentCrop *crop;
@property (nonatomic, readonly) CGRect cropRect;
@end
