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
#import "PDFPageLink.h"
#import "PDFPageLinkList.h"
#import "PDFRenderingCharacter.h"
#import "PDFText.h"
#import "PDFTextState.h"

@interface PDFPage ()
@property (nonatomic, strong, readwrite) NSArray *characterFrames;
@property (nonatomic, strong) NSArray *linkFrames;
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
    [self updateLinkFrames];
}

- (PDFPageLink *)linkAtPoint:(CGPoint)point
{
    if (self.linkFrames.count != self.linkList.links.count) {
        return nil;
    }

    __block PDFPageLink *hit = nil;
    [self.linkList.links enumerateObjectsUsingBlock:^(PDFPageLink *link, NSUInteger idx, BOOL *stop) {
        NSValue *v = [self.linkFrames objectAtIndex:idx];
        if (CGRectContainsPoint(v.CGRectValue, point)) {
            *stop = YES;
            hit = link;
        }
    }];

    return hit;
}

- (void)updateLinkFrames
{
    CGAffineTransform baseTransform = self.baseTransform;
    NSArray *linkFrames = [self.linkList.links grt_map:^(PDFPageLink *link) {
        return [NSValue valueWithCGRect:CGRectApplyAffineTransform(link.rect, baseTransform)];
    }];
    self.linkFrames = linkFrames;
}

- (void)updateCharacterFrames
{
    CGAffineTransform baseTransform = self.baseTransform;
    NSArray *characters = [self.characters copy];
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        NSArray *frames = [characters grt_map:^(PDFRenderingCharacter *character) {
            CGAffineTransform t = CGAffineTransformIdentity;
            t = CGAffineTransformConcat(t, character.state.transform);        
            t = CGAffineTransformConcat(t, baseTransform);
            return [NSValue valueWithCGRect:CGRectApplyAffineTransform(character.frame, t)];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([characters isEqual:self.characters]) {
                self.characterFrames = frames;
            }
        });
    });
}

- (CGAffineTransform)baseTransform
{
    CGRect pdfRect = self.rect;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, 0.0f, pdfRect.size.height);
    transform = CGAffineTransformScale(transform, 1.0f, -1.0f);

    CGRect drawRect = self.croppedRect;
    CGFloat scale = pdfRect.size.width / drawRect.size.width;
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    CGAffineTransform translationTransform =
            CGAffineTransformMakeTranslation(-drawRect.origin.x,
                                             -drawRect.origin.y);

    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformConcat(t, transform);
    t = CGAffineTransformConcat(t, translationTransform);
    t = CGAffineTransformConcat(t, scaleTransform);

    return t;
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

- (PDFRenderingCharacter *)nearestCharacterAtPoint:(CGPoint)point
{
    __block PDFRenderingCharacter *c = nil;

    __block CGFloat nearest = 100;

    float (^distance)(CGRect) = ^(CGRect r) {
        CGFloat xd;
        CGFloat yd;
        CGFloat minX = CGRectGetMinX(r);
        CGFloat maxX = CGRectGetMaxX(r);
        CGFloat minY = CGRectGetMinY(r);
        CGFloat maxY = CGRectGetMaxY(r);
        if (minX <= point.x && point.x <= maxX) {
            xd = 0;
        } else {
            xd = MIN(fabs(minX - point.x), fabs(maxX - point.x));
        }
        if (minY <= point.y && point.y <= maxY) {
            yd = 0;
        } else {
            yd = MIN(fabs(minY - point.y), fabs(maxY - point.y));
        }
        return sqrtf(pow(xd, 2) + pow(yd, 2));
    };
    
    [self.characterFrames enumerateObjectsUsingBlock:^(NSValue *v, NSUInteger idx, BOOL *stop) {
        CGRect r = [v CGRectValue];
        if (CGRectContainsPoint(r, point)) {
            c = self.characters[idx];
            *stop = YES;
        }
        CGFloat d = distance(r);
        if (d < nearest) {
            c = self.characters[idx];
            nearest = d;
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
    NSAssert(fromCharacter ||
             self.selectedRange.length > 0, @"");
    NSAssert(toCharacter ||
             self.selectedRange.length > 0, @"");    
    
    NSUInteger fromIndex = fromCharacter
        ? [self.characters indexOfObject:fromCharacter]
        : self.selectedRange.location;
    NSUInteger toIndex = toCharacter
        ? [self.characters indexOfObject:toCharacter]
        : self.selectedRange.location + self.selectedRange.length - 1;

    if (fromIndex > toIndex) {
        return;
    }
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
