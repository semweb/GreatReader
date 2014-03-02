//
//  PDFFont.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/5/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFFont.h"

#import <CoreText/CoreText.h>

#import "PDFCMap.h"
#import "PDFFontDescriptor.h"
#import "PDFUtils.h"


@interface PDFFont ()
@property (nonatomic, strong) NSDictionary *widths;
@property (nonatomic, assign) CGFloat defaultWidth;
@property (nonatomic, strong) PDFCMap *cmap;
@property (nonatomic, assign) NSStringEncoding encoding;
@end

@implementation PDFFont

+ (PDFFont *)fontWithFontDictionary:(CGPDFDictionaryRef)fontDictionary
{
    const char *type = PDFDictionaryGetName(fontDictionary, "Type");
    const char *subtype = PDFDictionaryGetName(fontDictionary, "Subtype");
    Class fontClass = [self fontClassForType:type subtype:subtype];
    PDFFont *font;
    if (fontClass) {
        font = [fontClass alloc];
    } else {
        return nil;
    }
        
    return [font initWithFontDictionary:fontDictionary];
}

+ (Class)fontClassForType:(const char *)type subtype:(const char *)subtype
{
    if (!type || strcmp(type, "Font")) {
        return nil;
    }

    if (!strcmp(subtype, "Type0")) {
        return Type0Font.class;
    }
    else if (!strcmp(subtype, "Type1")) {
        return Type1Font.class;
    }
    else if (!strcmp(subtype, "Type3")) {
        return PDFFont.class;
    }
    else if (!strcmp(subtype, "MMType1")) {
        return PDFFont.class;
    }
    else if (!strcmp(subtype, "TrueType")) {
        return TrueTypeFont.class;
    }
    else {
        return PDFFont.class;        
    }

    return nil;
}

- (instancetype)initWithFontDictionary:(CGPDFDictionaryRef)fontDictionary
{
    self = [super init];
    if (self) {
        _widths = [self widthsWithFontDictionary:fontDictionary];
        _defaultWidth = [self defaultWidthWithFontDictionary:fontDictionary];
        _cmap = [self cmapWithFontDictionary:fontDictionary];
        _fontDescriptor = [self fontDescriptorWithFontDictionary:fontDictionary];
        _encoding = [self encodingWithFontDictionary:fontDictionary];
    }
    return self;
}

- (PDFFontDescriptor *)fontDescriptorWithFontDictionary:(CGPDFDictionaryRef)fontDictionary
{
    CGPDFDictionaryRef dic = PDFDictionaryGetDictionary(fontDictionary, "FontDescriptor");
    PDFFontDescriptor *fontDescriptor =
            [[PDFFontDescriptor alloc] initWithFontDescriptorDictionary:dic];
    return fontDescriptor;
}

- (PDFCMap *)cmapWithFontDictionary:(CGPDFDictionaryRef)fontDictionary
{
    CGPDFStreamRef stream = PDFDictionaryGetStream(fontDictionary, "ToUnicode");
    if (stream) {
        PDFCMap *cmap = [[PDFCMap alloc] initWithStream:stream];
        return cmap;
    }
    return nil;
}

- (CGFloat)defaultWidthWithFontDictionary:(CGPDFDictionaryRef)fontDictionary
{
    CGPDFArrayRef descendantFonts = PDFDictionaryGetArray(fontDictionary, "DescendantFonts");
    CGPDFDictionaryRef descendantFont = PDFArrayGetDictionary(descendantFonts, 0);
    CGPDFInteger dw = PDFDictionaryGetInteger(descendantFont, "DW");
    return (CGFloat)dw;
}

- (NSDictionary *)widthsWithFontDictionary:(CGPDFDictionaryRef)fontDictionary
{
    NSMutableDictionary *widths = [NSMutableDictionary dictionary];
    
    CGPDFArrayRef descendantFonts = PDFDictionaryGetArray(fontDictionary, "DescendantFonts");
    CGPDFDictionaryRef descendantFont = PDFArrayGetDictionary(descendantFonts, 0);
    CGPDFArrayRef w = PDFDictionaryGetArray(descendantFont, "W");
    size_t count = CGPDFArrayGetCount(w);
    if (count == 2) {
        CGPDFInteger from = PDFArrayGetInteger(w, 0);
        CGPDFArrayRef wArray = PDFArrayGetArray(w, 1);
        for (int i = 0; i <= CGPDFArrayGetCount(wArray); i++) {
            CGPDFInteger width = PDFArrayGetInteger(wArray, i);
            [widths setObject:@(width) forKey:@(from + i)];
        }
    } else if (count == 3) {
        CGPDFInteger from = PDFArrayGetInteger(w, 0);
        CGPDFInteger to = PDFArrayGetInteger(w, 1);
        CGPDFInteger width = PDFArrayGetInteger(w, 2);
        for (int i = from; i <= to; i++) {
            [widths setObject:@(width) forKey:@(i)];
        }
    }

    return [widths copy];
}

- (NSStringEncoding)encodingWithFontDictionary:(CGPDFDictionaryRef)fontDictionary
{
    const char *name = PDFDictionaryGetName(fontDictionary, "Encoding");
    if (name) {
        if (!strcmp(name, "MacRomanEncoding")) {
            return NSMacOSRomanStringEncoding;
        } else if (!strcmp(name, "WinAnsiEncoding")) {
            return NSWindowsCP1252StringEncoding;
        }
    }
    return NSUTF8StringEncoding;
}

- (CGFloat)widthOfCharacter:(unichar)character
               withFontSize:(CGFloat)fontSize
{
    if (self.cmap) {
        character = [self.cmap CIDFromUnicode:character];
    }
    
    NSNumber *num = [self.widths objectForKey:@(character)];
    if (num) {
        return [num floatValue] * fontSize;
    } else {
        return self.defaultWidth * fontSize;
    }
}

- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
    const unsigned char *chars = CGPDFStringGetBytePtr(pdfString);
    
    if (self.cmap) {
        size_t length = CGPDFStringGetLength(pdfString);
        NSMutableString *string = [NSMutableString string];
        for (int i = 0; i < length; i++) {
            unichar unicode = [self.cmap unicodeFromCID:chars[i]];
            [string appendFormat:@"%C", unicode];
        }
        return string;
    } else {
        NSString *string = [NSString stringWithCString:(const char *)chars
                                              encoding:self.encoding];
        return string;
    }
}

@end

@implementation Type1Font

- (NSDictionary *)widthsWithFontDictionary:(CGPDFDictionaryRef)fontDictionary
{
    NSMutableDictionary *widthDictionary = [NSMutableDictionary dictionary];
    
    CGPDFArrayRef widths = PDFDictionaryGetArray(fontDictionary, "Widths");
    CGPDFInteger from = PDFDictionaryGetInteger(fontDictionary, "FirstChar");
    size_t count = CGPDFArrayGetCount(widths);
    for (int i = 0; i < count; i++) {
        CGPDFInteger width = PDFArrayGetInteger(widths, i);
        [widthDictionary setObject:@(width) forKey:@(from + i)];
    }

    return [widthDictionary copy];
}

@end

@implementation Type3Font
@end

@implementation TrueTypeFont
@end

@implementation Type0Font

- (PDFFontDescriptor *)fontDescriptorWithFontDictionary:(CGPDFDictionaryRef)fontDictionary
{
    CGPDFArrayRef descendantFonts = PDFDictionaryGetArray(fontDictionary, "DescendantFonts");
    CGPDFDictionaryRef descendantFont = PDFArrayGetDictionary(descendantFonts, 0);
    CGPDFDictionaryRef dic = PDFDictionaryGetDictionary(descendantFont, "FontDescriptor");
    PDFFontDescriptor *fontDescriptor =
            [[PDFFontDescriptor alloc] initWithFontDescriptorDictionary:dic];
    return fontDescriptor;
}

- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
    size_t length = CGPDFStringGetLength(pdfString);
    const unsigned char *chars = CGPDFStringGetBytePtr(pdfString);
    NSMutableString *string = [NSMutableString string];
    
    if (self.cmap) {
        for (int i = 0; i < length; i += 2) {
            unichar code = chars[i] << 8 | chars[i + 1];
            unichar unicode = [self.cmap unicodeFromCID:code];
            [string appendFormat:@"%C", unicode];
        }
        return string;
    } else {
        for (int i = 0; i < length; i += 2) {
            unichar code = chars[i] << 8 | chars[i + 1];
            unichar unicode = [self unicodeFromCID:code];
            [string appendFormat:@"%C", unicode];
        }
        return string;
    }    
    
    return nil;
}

- (unichar)unicodeFromCID:(uint16_t)cid
{
    static dispatch_once_t onceToken;
    static CGGlyph s_glyphs[65535];
    dispatch_once(&onceToken, ^{
        unichar unichars[65535];
        for (int i = 0; i < 65535; i++) {
            unichars[i] = i;
        }
        CTFontRef ctFont = CTFontCreateWithName((CFStringRef)@"HiraKakuProN-W3",
                                                10.0,
                                                NULL);
        CTFontGetGlyphsForCharacters(ctFont, unichars, s_glyphs, 65535);
    });

    for (int i = 0; i < 65535; i++) {
        if (s_glyphs[i] == cid) {
            return i;
        }
    }
    return 0;    
}

@end
