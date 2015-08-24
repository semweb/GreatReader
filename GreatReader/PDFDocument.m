//
//  PDFDocument.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/10.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocument.h"

#import "Device.h"
#import "FBKVOController.h"
#import "NSFileManager+GreatReaderAdditions.h"
#import "NSString+GreatReaderAdditions.h"
#import "PDFDocumentBackForwardList.h"
#import "PDFDocumentBookmarkList.h"
#import "PDFDocumentCrop.h"
#import "PDFDocumentNameList.h"
#import "PDFDocumentOutline.h"
#import "PDFDocumentSearch.h"
#import "PDFPage.h"
#import "PDFPageLinkList.h"

NSString * const PDFDocumentDeletedNotification = @"PDFDocumentDeletedNotification";

@interface PDFDocument ()
@property (nonatomic, strong) PDFDocumentNameList *nameList;
@property (nonatomic, assign, readwrite) NSUInteger numberOfPages;
@property (nonatomic, strong, readwrite) UIImage *thumbnailImage;
@property (nonatomic, strong, readwrite) PDFDocumentOutline *outline;
@property (nonatomic, strong, readwrite) PDFDocumentCrop *crop;
@property (nonatomic, strong, readwrite) PDFDocumentBookmarkList *bookmarkList;
@property (nonatomic, assign, readwrite) CGPDFDocumentRef CGPDFDocument;
@property (nonatomic, strong, readwrite) PDFDocumentSearch *search;
@property (nonatomic, copy, readwrite) NSString *title;
@property (nonatomic, assign, readwrite) NSUInteger currentPage;
@property (nonatomic, strong, readwrite) PDFDocumentBackForwardList *backForwardList;
@property (nonatomic, strong) FBKVOController *kvoController;
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
            self.fileNotExist = YES;
            return self;
        }
        _currentPage = 1;
        _brightness = 1.0;
        
        [self loadThumbnailImageAsync];

        _kvoController = [FBKVOController controllerWithObserver:self];        
    }
    return self;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    NSString *path = [PDFDocument absolutePathWithRelativePath:
                                   [decoder decodeObjectForKey:@"path"]];
    self = [self initWithPath:path];
    if (self) {
        _currentPage = [decoder decodeIntegerForKey:@"currentPage"];
        _bookmarkList = [decoder decodeObjectForKey:@"bookmarkList"];
        _bookmarkList.document = self;        
        _brightness = [decoder decodeFloatForKey:@"brightness"];
        _crop = [decoder decodeObjectForKey:@"crop"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    NSString *path = [PDFDocument relativePathWithAbsolutePath:self.path];
    NSAssert(path, @"");
    [encoder encodeObject:path forKey:@"path"];
    [encoder encodeInteger:self.currentPage forKey:@"currentPage"];
    [encoder encodeObject:self.bookmarkList forKey:@"bookmarkList"];
    [encoder encodeFloat:self.brightness forKey:@"brightness"];
    [encoder encodeObject:self.crop forKey:@"crop"];
}

#pragma mark -

+ (NSString *)absolutePathWithRelativePath:(NSString *)relativePath
{
    return [[NSFileManager grt_documentsPath]
               stringByAppendingPathComponent:relativePath];
}

+ (NSString *)relativePathWithAbsolutePath:(NSString *)absolutePath
{
    NSRange range = [absolutePath rangeOfString:[NSFileManager grt_documentsPath]];
    if (range.location == NSNotFound) {
        return nil;
    } else {
        return [absolutePath substringFromIndex:range.location + range.length];
    }
}

#pragma mark -

- (PDFPage *)pageAtIndex:(NSUInteger)index
{
    CGPDFPageRef cgPage = CGPDFDocumentGetPage(self.CGPDFDocument, index);
    if (cgPage) {
        PDFPage *page = [[PDFPage alloc] initWithCGPDFPage:cgPage];
        page.linkList = [[PDFPageLinkList alloc] initWithCGPDFPage:cgPage
                                                          nameList:self.nameList];
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
        _crop = [[PDFDocumentCrop alloc] init];
    }
    return _crop;
}

- (PDFDocumentBookmarkList *)bookmarkList
{
    if (!_bookmarkList) {
        _bookmarkList = [PDFDocumentBookmarkList new];
        _bookmarkList.document = self;
    }
    return _bookmarkList;
}

- (PDFDocumentSearch *)search
{
    if (!_search) {
        _search = [[PDFDocumentSearch alloc] initWithDocument:self];
    }
    return _search;
}

- (PDFDocumentBackForwardList *)backForwardList
{
    if (!_backForwardList) {
        _backForwardList = [[PDFDocumentBackForwardList alloc] initWithCurrentPage:self.currentPage];
        [self.kvoController observe:_backForwardList
                            keyPath:@"currentPage"
                            options:0
                              block:^(PDFDocument *document, PDFDocumentBackForwardList *list, NSDictionary *change) {
            document.currentPage = list.currentPage;
        }];
    }
    return _backForwardList;
}

- (PDFDocumentNameList *)nameList
{
    if (!_nameList) {
        _nameList = [[PDFDocumentNameList alloc] initWithCGPDFDocument:self.CGPDFDocument];        
    }
    return _nameList;
}

#pragma mark -

- (NSString *)imagePath
{
    NSString *dirPath = [NSFileManager grt_cachePath];
    NSString *path = [PDFDocument relativePathWithAbsolutePath:self.path];
    return [dirPath stringByAppendingPathComponent:[path grt_md5]];
}

- (UIImage *)loadThumbnailImage
{
    NSFileManager *fm = [NSFileManager new];
    NSString *path = self.imagePath;
    if ([fm fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        CGFloat scale = UIScreen.mainScreen.scale;        
        return [UIImage imageWithData:data scale:scale];
    }
    return nil;
}

- (UIImage *)makeThumbnailImage
{
    PDFPage *page = [self pageAtIndex:1];
    CGFloat width = IsPad() ? 180 : 100;

    CGRect pageRect = page.rect;
    CGFloat ratio = pageRect.size.height / pageRect.size.width;
    CGFloat w, h;
    if (pageRect.size.width > pageRect.size.height) {
        w = width; h = width * ratio;
    } else {
        w = width / ratio; h = width;
    }
    
    CGRect rect = CGRectMake(0, 0, w, h);
    CGFloat scale = UIScreen.mainScreen.scale;
    UIGraphicsBeginImageContextWithOptions(rect.size,
                                           NO,
                                           scale);
    CGContextRef context = UIGraphicsGetCurrentContext();

    [UIColor.whiteColor set];        
    UIRectFill(CGRectMake(0, 0, w, h));
               
    CGContextSaveGState(context); {
        CGContextTranslateCTM(context, 0.0f, rect.size.height);
        CGContextScaleCTM(context, 1.0f, -1.0f);
        CGContextConcatCTM(context,
                           CGPDFPageGetDrawingTransform(page.CGPDFPage,
                                                        kCGPDFMediaBox,
                                                        CGRectMake(0, 0, w, h),
                                                        0,
                                                        YES));
        CGContextSetInterpolationQuality(context ,kCGInterpolationHigh);
        CGContextDrawPDFPage(context, page.CGPDFPage);
    } CGContextRestoreGState(context);

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    [self writeThumbnailImageAsync:image];
        
    return image;    
}

- (void)writeThumbnailImageAsync:(UIImage *)image
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{    
        [UIImagePNGRepresentation(image) writeToFile:self.imagePath
                                          atomically:YES];
    });
}

- (void)loadThumbnailImageAsync
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        UIImage *image = [self loadThumbnailImage] ?: [self makeThumbnailImage];
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

#pragma mark -

- (void)delete
{
    NSFileManager *fileManager = [NSFileManager new];
    [fileManager removeItemAtPath:self.path error:NULL];
    [fileManager removeItemAtPath:self.imagePath error:NULL];

    [[NSNotificationCenter defaultCenter]
        postNotificationName:PDFDocumentDeletedNotification
                      object:self];
}

#pragma mark -

- (void)goBack
{
    [self.backForwardList goBack];
}

- (void)goForward
{
    [self.backForwardList goForward];
}

- (void)goTo:(NSUInteger)page
  addHistory:(BOOL)addHistory
{
    [self.backForwardList goTo:page addHistory:addHistory];
}

@end
