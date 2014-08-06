//
//  PDFPageLinkList.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/29/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFPageLinkList.h"

#import "PDFDocumentNameList.h"
#import "PDFPageLink.h"
#import "PDFUtils.h"

@implementation PDFPageLinkList

- (instancetype)initWithCGPDFPage:(CGPDFPageRef)cgPage
                         nameList:(PDFDocumentNameList *)nameList
{
    self = [super init];
    if (self) {
        _links = [self parse:cgPage
                    nameList:nameList];
    }
    return self;
}

- (NSArray *)parse:(CGPDFPageRef)cgPage
          nameList:(PDFDocumentNameList *)nameList
{
    NSMutableArray *results = NSMutableArray.array;
    
    CGPDFDictionaryRef dic = CGPDFPageGetDictionary(cgPage);
    CGPDFArrayRef annots = PDFDictionaryGetArray(dic, "Annots");
    for (int i = 0; i < CGPDFArrayGetCount(annots); i++) {
        CGPDFDictionaryRef a = PDFArrayGetDictionary(annots, i);
        const char *subtype = PDFDictionaryGetName(a, "Subtype");
        if (!strcmp(subtype, "Link")) {
            CGPDFObjectRef dest = PDFDictionaryGetObject(a, "Dest");
            NSString *key = [self stringForDest:dest];            
            NSUInteger pageNumber = [nameList pageNumberForName:key];
            if (pageNumber != NSNotFound) {
                CGPDFArrayRef rect = PDFDictionaryGetArray(a, "Rect");
                CGFloat minX = PDFArrayGetNumber(rect, 0);
                CGFloat minY = PDFArrayGetNumber(rect, 1);
                CGFloat maxX = PDFArrayGetNumber(rect, 2);
                CGFloat maxY = PDFArrayGetNumber(rect, 3);
                CGRect cgrect = CGRectMake(minX, minY, maxX - minX, maxY - minY);
                PDFPageLink *link = [[PDFPageLink alloc] initWithPageNumber:pageNumber
                                                                       rect:cgrect];
                [results addObject:link];
            }
        }
    }

    return results;
}

- (NSString *)stringForDest:(CGPDFObjectRef)dest
{
    switch (CGPDFObjectGetType(dest)) {
        case kCGPDFObjectTypeName: {
            const char *name = NULL;
            CGPDFObjectGetValue(dest, kCGPDFObjectTypeName, &name);
            return [[NSString alloc] initWithCString:name encoding:NSUTF8StringEncoding];
        }
        case kCGPDFObjectTypeString: {
            CGPDFStringRef str = NULL;
            CGPDFObjectGetValue(dest, kCGPDFObjectTypeString, &str);
            return (__bridge_transfer NSString *)CGPDFStringCopyTextString(str);
        }
        case kCGPDFObjectTypeArray: {
            return nil;
        }
        default: {
            return nil;
        }
    }
}

@end
