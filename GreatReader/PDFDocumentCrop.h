//
//  PDFDocumentCrop.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/21.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFDocument;
@class PDFPage;

@interface PDFDocumentCrop : NSObject
- (id)initWithPDFDocument:(PDFDocument *)document;
@property (nonatomic, assign, readonly) PDFDocument *document;
@property (nonatomic, assign) CGRect cropRect;
@end
