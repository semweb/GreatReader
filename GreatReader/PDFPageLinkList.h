//
//  PDFPageLinkList.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/29/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFDocumentNameList;
@class PDFPageLink;

@interface PDFPageLinkList : NSObject
- (instancetype)initWithCGPDFPage:(CGPDFPageRef)cgPage
                         nameList:(PDFDocumentNameList *)nameList;
@property (nonatomic, readonly) NSArray *links;
@end
