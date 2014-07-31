//
//  PDFPageLink.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/30/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFPageLink.h"

#import "PDFDocumentOutlineItem.h"

@interface PDFPageLink ()
@property (nonatomic, readwrite, strong) PDFDocumentOutlineItem *outlineItem;
@property (nonatomic, readwrite, assign) CGRect rect;
@end

@implementation PDFPageLink

- (instancetype)initWithOutlineItem:(PDFDocumentOutlineItem *)item
                               rect:(CGRect)rect
{
    self = [super init];
    if (self) {
        _outlineItem = item;
        _rect = rect;
    }
    return self;
}

@end
