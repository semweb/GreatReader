//
//  PDFFontDescriptor.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/11/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFFontDescriptor.h"

#import "PDFUtils.h"

@interface PDFFontDescriptor ()
@property (nonatomic, assign) CGPDFDictionaryRef dictionary;
@end

@implementation PDFFontDescriptor

- (instancetype)initWithFontDescriptorDictionary:(CGPDFDictionaryRef)dictionary
{
    self = [super init];
    if (self) {
        _dictionary = dictionary;
    }
    return self;
}

- (CGFloat)ascent
{
    return (CGFloat)PDFDictionaryGetInteger(self.dictionary, "Ascent");
}

- (CGFloat)descent
{
    return (CGFloat)PDFDictionaryGetInteger(self.dictionary, "Descent");
}

@end
