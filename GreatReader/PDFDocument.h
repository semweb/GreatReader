//
//  PDFDocument.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/10.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "File.h"

@class PDFDocumentBookmarkList;
@class PDFDocumentCrop;
@class PDFDocumentOutline;
@class PDFPage;

@interface PDFDocument : File <NSCoding>
@property (nonatomic, assign, readonly) NSUInteger numberOfPages;
@property (nonatomic, strong, readonly) PDFDocumentOutline *outline;
@property (nonatomic, strong, readonly) PDFDocumentCrop *crop;
@property (nonatomic, strong, readonly) PDFDocumentBookmarkList *bookmarkList;
@property (nonatomic, strong, readonly) UIImage *thumbnailImage;
@property (nonatomic, assign, readonly) CGPDFDocumentRef CGPDFDocument;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, readonly) BOOL currentPageBookmarked;
- (PDFPage *)pageAtIndex:(NSUInteger)index;
- (void)toggleRibbon;
@end
