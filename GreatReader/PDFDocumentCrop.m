//
//  PDFDocumentCrop.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/21.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentCrop.h"

#import "PDFDocument.h"

@interface PDFDocumentCrop ()
@end

@implementation PDFDocumentCrop

- (id)initWithPDFDocument:(PDFDocument *)document
{
    self = [super init];
    if (self) {
        _document = document;
        _cropRect = CGRectZero;
    }
    return self;
}

@end
