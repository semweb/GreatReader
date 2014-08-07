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
@property (nonatomic, strong) NSString *baseFont;
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
    else if (!strcmp(subtype, "CIDFontType2")) {
        return CIDType2Font.class;
    }
    else if (!strcmp(subtype, "CIDFontType0")) {
        return CIDType0Font.class;
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
        _baseFont = [self baseFontWithFontDictionary:fontDictionary];        
        _fontDescriptor = [self fontDescriptorWithFontDictionary:fontDictionary];
        _encoding = [self encodingWithFontDictionary:fontDictionary];
    }
    return self;
}

- (NSString *)baseFontWithFontDictionary:(CGPDFDictionaryRef)fontDictionary
{
    const char *name = PDFDictionaryGetName(fontDictionary, "BaseFont");
    return [NSString stringWithCString:name
                              encoding:NSUTF8StringEncoding];
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
    return nil;
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

- (CGFloat)widthOfCharacter:(unichar)character
               withFontSize:(CGFloat)fontSize
{
    NSNumber *num = [self.widths objectForKey:@(character)];
    if (num) {
        return [num floatValue] * fontSize;
    } else if (self.defaultWidth != -1) {
        return self.defaultWidth * fontSize;
    } else {
        return [self calculateWidthWithCoreText:character] * fontSize;
    }
}

- (CGFloat)calculateWidthWithCoreText:(unichar)character
{
    CGFontRef cgFont = CGFontCreateWithFontName((CFStringRef)self.baseFont);
    CTFontRef ctFont = CTFontCreateWithGraphicsFont(cgFont,
                                                    10,
                                                    NULL,
                                                    NULL);

    CGGlyph *glyphs = (CGGlyph *)malloc(sizeof(CGGlyph));
    CTFontGetGlyphsForCharacters(ctFont,
                                 &character,
                                 glyphs,
                                 1);
    double w = CTFontGetAdvancesForGlyphs(ctFont,
                                          kCTFontDefaultOrientation,
                                          glyphs,
                                          NULL,
                                          1);
    CGFontRelease(cgFont);
    CFRelease(ctFont);
    free(glyphs);
    return w * 100;
}

- (PDFFontDescriptor *)fontDescriptorWithFontDictionary:(CGPDFDictionaryRef)fontDictionary
{
    CGPDFDictionaryRef dic = PDFDictionaryGetDictionary(fontDictionary, "FontDescriptor");
    if (dic) {
        return [[PDFFontDescriptor alloc] initWithFontDescriptorDictionary:dic];
    } else {
        NSString *baseFont = [self baseFontWithFontDictionary:fontDictionary];
        return [[PDFFontDescriptor alloc] initWithBaseFont:baseFont];
    }
}

@end

@implementation Type3Font
@end

@implementation TrueTypeFont
@end


@interface Type0Font ()
@property (nonatomic, strong) NSArray *descendantFonts;
@property (nonatomic, readonly) PDFFont *descendantFont;
@end
@implementation Type0Font

- (instancetype)initWithFontDictionary:(CGPDFDictionaryRef)fontDictionary
{
    self = [super initWithFontDictionary:fontDictionary];
    if (self) {
        _descendantFonts = [self descendantFontsWithFontDictionary:fontDictionary];
    }
    return self;
}

- (NSArray *)descendantFontsWithFontDictionary:(CGPDFDictionaryRef)fontDictionary
{
    CGPDFArrayRef descendantFonts = PDFDictionaryGetArray(fontDictionary, "DescendantFonts");
    CGPDFDictionaryRef descendantFont = PDFArrayGetDictionary(descendantFonts, 0);
    if (descendantFont) {
        return @[
            [PDFFont fontWithFontDictionary:descendantFont]
        ];
    } else {
        return nil;
    }
}

- (PDFFontDescriptor *)fontDescriptor
{
    return super.fontDescriptor ?: self.descendantFont.fontDescriptor;
}

- (NSDictionary *)widths
{
    return super.widths ?: self.descendantFont.widths;
}

- (PDFFont *)descendantFont
{
    return [self.descendantFonts lastObject];
}

- (NSString *)stringWithPDFString:(CGPDFStringRef)pdfString
{
    size_t length = CGPDFStringGetLength(pdfString);
    const unsigned char *chars = CGPDFStringGetBytePtr(pdfString);
    NSMutableString *string = [NSMutableString string];
    
    if (self.cmap) {
        for (int i = 0; i < length; i += 2) {
            unichar code = chars[i] << 8 | chars[i + 1];
            unichar unicode;
            if ([self.cmap canConvertCID:code]) {
                unicode = [self.cmap unicodeFromCID:code];
            } else {
                unicode = [self unicodeFromCID:code];
            }
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

static dispatch_once_t onceToken;
static CGGlyph s_glyphs[65535];

- (unichar)unicodeFromCID:(uint16_t)cid
{
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

- (uint16_t)CIDFromUnicode:(uint16_t)unicode
{
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
    return s_glyphs[unicode];
}

- (CGFloat)widthOfCharacter:(unichar)character
               withFontSize:(CGFloat)fontSize
{
    if (self.cmap) {
        character = [self.cmap CIDFromUnicode:character];
    } else {
        character = [self CIDFromUnicode:character];
    }
    
    NSNumber *num = [self.widths objectForKey:@(character)];
    if (num) {
        return [num floatValue] * fontSize;
    } else {
        return self.defaultWidth * fontSize;
    }
}

@end

@implementation CIDFont

- (CGFloat)defaultWidthWithFontDictionary:(CGPDFDictionaryRef)fontDictionary
{
    CGPDFInteger dw = PDFDictionaryGetInteger(fontDictionary, "DW");
    return (CGFloat)dw;
}

- (NSDictionary *)widthsWithFontDictionary:(CGPDFDictionaryRef)fontDictionary
{
    NSMutableDictionary *widths = [NSMutableDictionary dictionary];
    
    CGPDFArrayRef w = PDFDictionaryGetArray(fontDictionary, "W");
    size_t count = CGPDFArrayGetCount(w);

    CGPDFInteger from = 0;
    for (int i = 0; i < count; i++) {
        from = PDFArrayGetInteger(w, i);

        CGPDFObjectRef o = PDFArrayGetObject(w, ++i);
        CGPDFObjectType type = CGPDFObjectGetType(o);
        if (type == kCGPDFObjectTypeInteger) {
            CGPDFInteger to = -1;
            CGPDFObjectGetValue(o, type, &to);            
            CGPDFInteger width = PDFArrayGetInteger(w, ++i);
            for (NSInteger j = from; j <= to; j++) {
                [widths setObject:@(width) forKey:@(j)];
            }            
        } else if (type == kCGPDFObjectTypeArray) {
            CGPDFArrayRef wArray = NULL;
            CGPDFObjectGetValue(o, type, &wArray);
            for (int j = 0; j < CGPDFArrayGetCount(wArray); j++) {
                CGPDFReal width = PDFArrayGetNumber(wArray, j);
                [widths setObject:@(width) forKey:@(from + j)];
            }            
        }
    }

    return [widths copy];
}

@end


@implementation CIDType2Font


@end

@implementation CIDType0Font


@end
