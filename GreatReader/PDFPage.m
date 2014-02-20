//
//  PDFPage.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/12.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFPage.h"

#import "PDFDocumentCrop.h"

@interface PDFPage ()
@end

@implementation PDFPage

- (void)dealloc
{
    CGPDFPageRelease(_CGPDFPage);
}

- (instancetype)initWithCGPDFPage:(CGPDFPageRef)CGPDFPage
{
    self = [super init];
    if (self) {
        _CGPDFPage = CGPDFPageRetain(CGPDFPage);
    }
    return self;
}

- (NSUInteger)index
{
    size_t pageNumber = CGPDFPageGetPageNumber(self.CGPDFPage);
    return (NSUInteger)pageNumber;
}

- (CGRect)rect
{
    CGRect rect = CGPDFPageGetBoxRect(self.CGPDFPage, kCGPDFMediaBox);
    return rect;
}

- (CGRect)croppedRect
{
    CGRect rect = self.rect;
    if (self.crop && !CGRectEqualToRect(self.crop.cropRect, CGRectZero)) {
        CGRect cropRect = self.crop.cropRect;
        CGFloat w = rect.size.width;
        rect.origin.x = cropRect.origin.x * w;
        rect.origin.y = cropRect.origin.y * w;
        rect.size.width = cropRect.size.width * w;
        rect.size.height = cropRect.size.height * w;        
    }
    return rect;
}

- (void)drawInRect:(CGRect)rect inContext:(CGContextRef)context cropping:(BOOL)cropping
{  
    CGContextSetRGBFillColor(context, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextFillRect(context, CGContextGetClipBoundingBox(context));
    
    CGContextTranslateCTM(context, 0.0f, rect.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);

    CGRect pdfRect = self.rect;
    CGRect drawRect = cropping ? self.croppedRect : pdfRect;
    CGFloat scale = rect.size.width / drawRect.size.width;
    CGContextScaleCTM(context, scale, scale);
    CGContextTranslateCTM(context,
                          -drawRect.origin.x,
                          -(pdfRect.size.height - CGRectGetMaxY(drawRect)));    

    CGContextDrawPDFPage(context, self.CGPDFPage);
}

- (UIImage *)thumbnailImageWithSize:(CGSize)size cropping:(BOOL)cropping
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    CGContextRef context = UIGraphicsGetCurrentContext();    
    [self drawInRect:CGRectMake(0, 0, size.width, size.height)
           inContext:context
            cropping:cropping];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
