//
//  PDFPage.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/12.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFPage.h"

#import "NSArray+GreatReaderAdditions.h"
#import "PDFDocumentCrop.h"
#import "PDFRenderingCharacter.h"
#import "PDFText.h"
#import "PDFTextState.h"

@interface PDFPage ()
@property (nonatomic, strong) NSArray *characterFrames;
@property (nonatomic, assign) NSRange selectedRange;
@end

@implementation PDFPage

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"selectedCharacters"] ||
        [key isEqualToString:@"selectedFrames"]) {
        
        return [NSSet setWithObject:@"selectedRange"];
    }
    return [NSSet set];
}

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

- (BOOL)isOddPage
{
    return self.index % 2 != 0;
}

- (CGRect)croppedRect
{
    CGRect rect = self.rect;
    CGRect cropRect = [self.crop cropRectAtPage:self.index];
    if (self.crop.enabled && !CGRectEqualToRect(cropRect, CGRectZero)) {
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


    // CGContextSetRGBFillColor(context, 1.0f, 0.0f, 0.0f, 0.1f);
    // for (PDFRenderingCharacter *c in self.characters) {
    //     CGRect f = CGRectApplyAffineTransform(c.frame,
    //                                           c.state.transform);
    //     CGContextFillRect(context, f);
    // }
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

- (void)setCharacters:(NSArray *)characters
{
    _characters = characters;
    [self updateCharacterFrames];
}

- (void)updateCharacterFrames
{
    CGRect pdfRect = self.rect;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0.0f, pdfRect.size.height);
    transform = CGAffineTransformScale(transform, 1.0f, -1.0f);

    CGRect drawRect = self.croppedRect;
    CGFloat scale = pdfRect.size.width / drawRect.size.width;
    transform = CGAffineTransformScale(transform, scale, scale);
    transform = CGAffineTransformTranslate(transform,
                               -drawRect.origin.x,
                               -(pdfRect.size.height - CGRectGetMaxY(drawRect)));

    self.characterFrames = [self.characters grt_map:^(PDFRenderingCharacter *character) {
        CGAffineTransform t = CGAffineTransformConcat(character.state.transform, transform);
        return [NSValue valueWithCGRect:CGRectApplyAffineTransform(character.frame, t)];
    }];
}

- (PDFRenderingCharacter *)characterAtPoint:(CGPoint)point
{
    __block PDFRenderingCharacter *c = nil;
    
    [self.characterFrames enumerateObjectsUsingBlock:^(NSValue *v, NSUInteger idx, BOOL *stop) {
        CGRect r = [v CGRectValue];
        if (CGRectContainsPoint(r, point)) {
            c = self.characters[idx];
            *stop = YES;
        }
    }];

    return c;
}

- (void)selectWordForCharacter:(PDFRenderingCharacter *)character
{
    NSUInteger index = [self.characters indexOfObject:character];
    NSInteger from = index;
    NSInteger to = index;

    while (from > 0) {
        PDFRenderingCharacter *c = [self.characters objectAtIndex:from - 1];
        if (c.isNotWordCharater || ![c isSameLineAs:character]) {
            break;
        }
        from--;
    }
    while (to < self.characters.count - 1) {
        PDFRenderingCharacter *c = [self.characters objectAtIndex:to + 1];
        if (c.isNotWordCharater || ![c isSameLineAs:character]) {
            break;
        }
        to++;
    }

    [self selectCharactersFrom:[self.characters objectAtIndex:from]
                            to:[self.characters objectAtIndex:to]];
}

- (void)selectCharactersFrom:(PDFRenderingCharacter *)fromCharacter
                          to:(PDFRenderingCharacter *)toCharacter
{
    NSUInteger fromIndex = [self.characters indexOfObject:fromCharacter];
    NSUInteger toIndex = [self.characters indexOfObject:toCharacter];
    self.selectedRange = NSMakeRange(fromIndex, toIndex - fromIndex + 1);
}

- (void)unselectCharacters
{
    self.selectedRange = NSMakeRange(0, 0);
}

- (NSArray *)selectedCharacters
{
    return [self.characters subarrayWithRange:self.selectedRange];
}

- (NSArray *)selectedFrames
{
    return [self.characterFrames subarrayWithRange:self.selectedRange];
}

- (NSString *)selectedString
{
    NSMutableString *str = [NSMutableString string];
    for (PDFRenderingCharacter *c in self.selectedCharacters) {
        [str appendString:c.stringDescription];
    }
    return str;
}

@end
