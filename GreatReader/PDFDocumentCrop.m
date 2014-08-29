//
//  PDFDocumentCrop.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/21.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentCrop.h"

@implementation PDFDocumentCrop

- (instancetype)init
{
    self = [super init];
    if (self) {
        _oddCropRect = CGRectZero;
        _evenCropRect = CGRectZero;
        _mode = PDFDocumentCropModeSame;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        _oddCropRect = [decoder decodeCGRectForKey:@"oddCropRect"];
        _evenCropRect = [decoder decodeCGRectForKey:@"evenCropRect"];
        _mode = (PDFDocumentCropMode)[decoder decodeIntegerForKey:@"mode"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeCGRect:self.oddCropRect forKey:@"oddCropRect"];
    [encoder encodeCGRect:self.evenCropRect forKey:@"evenCropRect"];
    [encoder encodeInteger:self.mode forKey:@"mode"];
}

- (CGRect)cropRectAtPage:(NSUInteger)page
{
    CGRect rect = CGRectZero;
    if (page % 2 == 0) {
        rect = self.evenCropRect;
    } else {
        rect = self.oddCropRect;
    }
    return rect;
}

- (BOOL)enabled
{
    return self.mode != PDFDocumentCropModeNone;
}

@end
