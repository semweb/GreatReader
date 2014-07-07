//
//  PDFDocumentSearch.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/7/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFDocumentSearch;
@class PDFDocumentSearchResult;

@protocol PDFDocumentSearchDelegate <NSObject>
- (void)search:(PDFDocumentSearch *)search
 didFindString:(PDFDocumentSearchResult *)result;
@end

@interface PDFDocumentSearch : NSObject
- (instancetype)initWithCGPDFDocument:(CGPDFDocumentRef)CGPDFDocument;
@property (nonatomic, assign, readonly) CGPDFDocumentRef CGPDFDocument;
@property (nonatomic, weak) id<PDFDocumentSearchDelegate> delegate;
- (void)searchWithString:(NSString *)keyword;
- (void)cancelSearch;
@end
