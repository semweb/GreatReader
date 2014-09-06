//
//  PDFDocument.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/10.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "File.h"

@class PDFDocumentBackForwardList;
@class PDFDocumentBookmarkList;
@class PDFDocumentCrop;
@class PDFDocumentOutline;
@class PDFDocumentSearch;
@class PDFDocumentStore;
@class PDFPage;

extern NSString * const PDFDocumentDeletedNotification;

@interface PDFDocument : File <NSCoding>
@property (nonatomic, assign, readonly) NSUInteger numberOfPages;
@property (nonatomic, strong, readonly) PDFDocumentOutline *outline;
@property (nonatomic, strong, readonly) PDFDocumentCrop *crop;
@property (nonatomic, strong, readonly) PDFDocumentBookmarkList *bookmarkList;
@property (nonatomic, strong, readonly) PDFDocumentSearch *search;
@property (nonatomic, strong, readonly) UIImage *thumbnailImage;
@property (nonatomic, assign, readonly) CGPDFDocumentRef CGPDFDocument;
@property (nonatomic, assign, readonly) NSUInteger currentPage;
@property (nonatomic, assign) CGFloat brightness;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, readonly) BOOL currentPageBookmarked;
@property (nonatomic, weak) PDFDocumentStore *store;
@property (nonatomic, strong, readonly) PDFDocumentBackForwardList *backForwardList;
- (PDFPage *)pageAtIndex:(NSUInteger)index;
- (void)toggleRibbon;
- (void)delete;
- (void)goBack;
- (void)goForward;
- (void)goTo:(NSUInteger)page
  addHistory:(BOOL)addHistory;
+ (NSString *)absolutePathWithRelativePath:(NSString *)relativePath;
+ (NSString *)relativePathWithAbsolutePath:(NSString *)absolutePath;
@end
