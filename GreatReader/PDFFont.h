//
//  PDFFont.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/5/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFFontDescriptor;

@interface PDFFont : NSObject
+ (PDFFont *)fontWithFontDictionary:(CGPDFDictionaryRef)dictionary;
- (instancetype)initWithFontDictionary:(CGPDFDictionaryRef)dictionary;
- (CGFloat)widthOfCharacter:(unichar)character
               withFontSize:(CGFloat)fontSize;
- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString;
@property (nonatomic, strong) PDFFontDescriptor *fontDescriptor;
@end

@interface Type1Font : PDFFont
@end

@interface Type0Font : PDFFont

@end

@interface Type3Font : PDFFont
@end

@interface TrueTypeFont : Type1Font
@end

@interface CIDFont : Type0Font
@end

@interface CIDType2Font : CIDFont
@end

@interface CIDType0Font : CIDFont
@end
