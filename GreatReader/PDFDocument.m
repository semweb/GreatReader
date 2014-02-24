//
//  PDFDocument.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/10.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocument.h"

#import "PDFDocumentBookmarkList.h"
#import "PDFDocumentCrop.h"
#import "PDFDocumentOutline.h"
#import "PDFPage.h"

@interface PDFDocument ()
@property (nonatomic, assign, readwrite) NSUInteger numberOfPages;
@property (nonatomic, strong, readwrite) NSString *path;
@property (nonatomic, strong, readwrite) UIImage *thumbnailImage;
@property (nonatomic, strong, readwrite) UIImage *iconImage;
@property (nonatomic, strong, readwrite) PDFDocumentOutline *outline;
@property (nonatomic, strong, readwrite) PDFDocumentCrop *crop;
@property (nonatomic, strong) PDFDocumentBookmarkList *bookmarkList;
@property (nonatomic, assign, readwrite) CGPDFDocumentRef CGPDFDocument;
@property (nonatomic, copy, readwrite) NSString *title;
@end

@implementation PDFDocument

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"currentPageBookmarked"]) {
        return [NSSet setWithObject:@"currentPage"];
    }
    return [NSSet set];
}

- (void)dealloc
{
    CGPDFDocumentRelease(_CGPDFDocument);
}

- (instancetype)initWithPath:(NSString *)path
{
    self = [super initWithPath:path];
    if (self) {
        NSURL *URL = [NSURL fileURLWithPath:path];
        _CGPDFDocument = CGPDFDocumentCreateWithURL((__bridge CFURLRef)URL);
        if (_CGPDFDocument) {
            _numberOfPages = CGPDFDocumentGetNumberOfPages(_CGPDFDocument);
        } else {
            return nil;
        }
        _currentPage = 1;
        
        [self loadThumbnailImage];
    }
    return self;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)decoder
{
    NSString *path = [decoder decodeObjectForKey:@"path"];
    self = [self initWithPath:path];
    if (self) {
        _currentPage = [decoder decodeIntegerForKey:@"currentPage"];
        _bookmarkList = [decoder decodeObjectForKey:@"bookmarkList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.path forKey:@"path"];
    [encoder encodeInteger:self.currentPage forKey:@"currentPage"];
    [encoder encodeObject:self.bookmarkList forKey:@"bookmarkList"];
}

#pragma mark -

- (PDFPage *)pageAtIndex:(NSUInteger)index
{
    CGPDFPageRef cgPage = CGPDFDocumentGetPage(self.CGPDFDocument, index);
    if (cgPage) {
        PDFPage *page = [[PDFPage alloc] initWithCGPDFPage:cgPage];
        return page;
    } else {
        return nil;
    }
}

#pragma mark - Title

- (NSString *)title
{
    if (!_title) {
        CGPDFDictionaryRef dict = CGPDFDocumentGetInfo(self.CGPDFDocument);
        CGPDFStringRef title = NULL;
        CGPDFDictionaryGetString(dict, "Title", &title);
        _title = (__bridge_transfer NSString *)CGPDFStringCopyTextString(title);
    }
    return _title;
}

#pragma mark -

- (PDFDocumentOutline *)outline
{
    if (!_outline) {
        _outline = [[PDFDocumentOutline alloc]
                       initWithCGPDFDocument:self.CGPDFDocument];
    }
    return _outline;
}

- (PDFDocumentCrop *)crop
{
    if (!_crop) {
        _crop = [[PDFDocumentCrop alloc] initWithPDFDocument:self];
    }
    return _crop;
}

- (PDFDocumentBookmarkList *)bookmarkList
{
    if (!_bookmarkList) {
        _bookmarkList = [PDFDocumentBookmarkList new];
    }
    return _bookmarkList;
}

#pragma mark -

- (void)loadThumbnailImage
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        PDFPage *page = [self pageAtIndex:1];
        CGFloat width = 50;
        CGRect rect = CGRectMake(0, 0, width, width);
        UIGraphicsBeginImageContextWithOptions(rect.size,
                                               NO,
                                               2.0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSaveGState(context); {
            CGContextTranslateCTM(context, 0.0f, rect.size.height);
            CGContextScaleCTM(context, 1.0f, -1.0f);
            CGContextConcatCTM(context,
                               CGPDFPageGetDrawingTransform(page.CGPDFPage,
                                                            kCGPDFMediaBox,
                                                            rect,
                                                            0,
                                                            YES));
            CGContextDrawPDFPage(context, page.CGPDFPage);
        } CGContextRestoreGState(context);
        CGRect pageRect = page.rect;
        CGFloat ratio = pageRect.size.height / pageRect.size.width;
        CGFloat x, y, w, h;
        if (pageRect.size.width > pageRect.size.height) {
            w = width; h = width * ratio;
            x = 0; y = (width - h) / 2.0;
        } else {
            w = width / ratio; h = width;
            x = (width - w) / 2.0; y = 0;
        }
        x += 0.5; y += 0.5;
        w -= 1.0; h -= 1.0;
        [UIColor.blackColor set];
        CGContextStrokeRectWithWidth(context, CGRectMake(x, y, w, h), 0.5);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        dispatch_async(dispatch_get_main_queue(), ^{
            self.thumbnailImage = image;
            self.iconImage = image;
        });
    });
}

#pragma mark - Equal

- (NSUInteger)hash
{
    return [self.path hash];
}

- (BOOL)isEqual:(id)anObject
{
    if ([anObject isKindOfClass:[PDFDocument class]]) {
        PDFDocument *doc = (PDFDocument *)anObject;
        return [self.path isEqual:doc.path];
    }
    else {
        return [super isEqual:anObject];
    }
}

#pragma mark - File (Override)

- (NSString *)name
{
    if (self.title.length > 0) {
        return self.title;
    } else {
        return [[super name] stringByDeletingPathExtension];
    }
}

#pragma mark - Ribbon

- (void)toggleRibbon
{
    [self willChangeValueForKey:@"currentPageBookmarked"];
    [self.bookmarkList toggleBookmarkAtPage:self.currentPage];
    [self didChangeValueForKey:@"currentPageBookmarked"];    
}

- (BOOL)currentPageBookmarked
{
    return [self.bookmarkList bookmarkedAtPage:self.currentPage];
}

@end
