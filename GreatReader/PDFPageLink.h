//
//  PDFPageLink.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/30/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFDocumentOutlineItem;

@interface PDFPageLink : NSObject
@property (nonatomic, readonly, strong) PDFDocumentOutlineItem *outlineItem;
@property (nonatomic, readonly, assign) CGRect rect;

- (instancetype)initWithOutlineItem:(PDFDocumentOutlineItem *)item
                               rect:(CGRect)rect;
@end
