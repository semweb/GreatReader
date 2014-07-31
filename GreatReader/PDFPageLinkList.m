//
//  PDFPageLinkList.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/29/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFPageLinkList.h"

#import "PDFDocumentOutline.h"
#import "PDFDocumentOutlineItem.h"
#import "PDFPageLink.h"
#import "PDFUtils.h"

@implementation PDFPageLinkList

- (instancetype)initWithCGPDFPage:(CGPDFPageRef)cgPage
                          outline:(PDFDocumentOutline *)outline
{
    self = [super init];
    if (self) {
        _links = [self parse:cgPage
                     outline:outline];
    }
    return self;
}

- (NSArray *)parse:(CGPDFPageRef)cgPage
           outline:(PDFDocumentOutline *)outline
{
    NSMutableArray *results = NSMutableArray.array;
    
    CGPDFDictionaryRef dic = CGPDFPageGetDictionary(cgPage);
    CGPDFArrayRef annots = PDFDictionaryGetArray(dic, "Annots");
    for (int i = 0; i < CGPDFArrayGetCount(annots); i++) {
        CGPDFDictionaryRef a = PDFArrayGetDictionary(annots, i);
        const char *subtype = PDFDictionaryGetName(a, "Subtype");
        if (!strcmp(subtype, "Link")) {
            CGPDFObjectRef dest = PDFDictionaryGetObject(a, "Dest");
            PDFDocumentOutlineItem *outlineItem = [outline findItemForDestination:dest];
            if (outlineItem) {
                CGPDFArrayRef rect = PDFDictionaryGetArray(a, "Rect");
                CGFloat minX = PDFArrayGetNumber(rect, 0);
                CGFloat minY = PDFArrayGetNumber(rect, 1);
                CGFloat maxX = PDFArrayGetNumber(rect, 2);
                CGFloat maxY = PDFArrayGetNumber(rect, 3);
                CGRect cgrect = CGRectMake(minX, minY, maxX - minX, maxY - minY);
                PDFPageLink *link = [[PDFPageLink alloc] initWithOutlineItem:outlineItem
                                                                        rect:cgrect];
                [results addObject:link];
            }
        }
    }

    return results;
}

@end
