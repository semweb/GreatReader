//
//  PDFPageLinkList.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/29/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFDocumentOutline;
@class PDFPageLink;

@interface PDFPageLinkList : NSObject
- (instancetype)initWithCGPDFPage:(CGPDFPageRef)cgPage
                          outline:(PDFDocumentOutline *)outline;
@property (nonatomic, readonly) NSArray *links;
@end
