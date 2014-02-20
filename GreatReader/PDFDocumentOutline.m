//
//  PDFDocumentOutline.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentOutline.h"

#import "PDFDocumentOutlineItem.h"
#import "NSArray+GreatReaderAdditions.h"

@interface PDFDocumentOutline ()
@property (nonatomic, strong, readwrite) NSArray *items;
@end

@implementation PDFDocumentOutline

- (instancetype)initWithCGPDFDocument:(CGPDFDocumentRef)document
{
    self = [super init];
    if (self) {
        _items = [self outlineItemsForDocument:document];
    }
    return self;
}

- (NSArray *)outlineItemsForDocument:(CGPDFDocumentRef)document
{
    CGPDFDictionaryRef outlines = nil;
    CGPDFDictionaryGetDictionary(CGPDFDocumentGetCatalog(document),
                                 "Outlines",
                                 &outlines);
    return [self childrenForItem:outlines
                        document:document];
}

- (NSArray *)childrenForItem:(CGPDFDictionaryRef)item
                    document:(CGPDFDocumentRef)document
{
    NSMutableArray *children = [NSMutableArray array];
    CGPDFDictionaryRef current = nil;
    CGPDFDictionaryGetDictionary(item,
                                 "First",
                                 &current);
    if (!current) {
        return @[];
    }
    [children addObject:[NSValue valueWithPointer:current]];
    
    CGPDFDictionaryRef next = nil;
    while (CGPDFDictionaryGetDictionary(current, "Next", &next)) {
        current = next;
        [children addObject:[NSValue valueWithPointer:current]];
    }

    return [children grt_map:^(NSValue *value) {
        CGPDFDictionaryRef dic = [value pointerValue];
        NSArray *children = [self childrenForItem:dic
                                         document:document];
        NSString *title = [self titleOfDictionary:dic];
        NSUInteger pageNumber = [self pageNumberOfDictionary:dic
                                                    document:document];
        PDFDocumentOutlineItem *item = [[PDFDocumentOutlineItem alloc]
                                           initWithTitle:title
                                              pageNumber:pageNumber
                                                children:children];
        return item;
    }];
}

#pragma mark -

- (NSString *)titleOfDictionary:(CGPDFDictionaryRef)dictionary
{
    CGPDFStringRef title = nil;
    CGPDFDictionaryGetString(dictionary, "Title", &title);
    return (__bridge_transfer NSString *)CGPDFStringCopyTextString(title);
}

- (NSUInteger)pageNumberOfDictionary:(CGPDFDictionaryRef)dictionary
                            document:(CGPDFDocumentRef)document
{
    CGPDFArrayRef destArray = nil; CGPDFDictionaryGetArray(dictionary, "Dest", &destArray); 
    CGPDFDictionaryRef pageDictionary = nil; CGPDFArrayGetDictionary(destArray, 0, &pageDictionary);
                            
    NSUInteger numberOfPages = CGPDFDocumentGetNumberOfPages(document);
    for (NSUInteger i = 1; i <= numberOfPages; i++) {
        CGPDFPageRef page = CGPDFDocumentGetPage(document, i);
        CGPDFDictionaryRef pd = CGPDFPageGetDictionary(page);
        if (pd == pageDictionary) {
            return i;
        }
    }
    return 0;
}

#pragma mark -

- (NSString *)description
{
    return [[self.items grt_map:^(PDFDocumentOutlineItem *item) {
        return item.description;
    }] componentsJoinedByString:@"\n"];
}

@end
