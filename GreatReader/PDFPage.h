//
//  PDFPage.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/12.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFDocumentCrop;

@interface PDFPage : NSObject
@property (nonatomic, assign) CGPDFPageRef CGPDFPage;
@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, readonly) CGRect rect;
@property (nonatomic, readonly) CGRect croppedRect;
@property (nonatomic, weak) PDFDocumentCrop *crop;
- (instancetype)initWithCGPDFPage:(CGPDFPageRef)CGPDFPage;
- (UIImage *)thumbnailImageWithSize:(CGSize)size cropping:(BOOL)cropping;
- (void)drawInRect:(CGRect)rect inContext:(CGContextRef)context cropping:(BOOL)cropping;
@end
