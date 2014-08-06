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
        CGPDFObjectRef dest = NULL;
        NSUInteger pageNumber = [self pageNumberOfDictionary:dic
                                                    document:document
                                                 destination:&dest];
        PDFDocumentOutlineItem *item = [[PDFDocumentOutlineItem alloc]
                                           initWithTitle:title
                                              pageNumber:pageNumber
                                             destination:dest
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
                         destination:(CGPDFObjectRef *)destination
{
    CGPDFDictionaryRef pageDictionary = NULL;
    CGPDFArrayRef destArray = NULL;
    CGPDFStringRef destString = NULL;
    const char *destName = NULL;
    
    CGPDFDictionaryRef a = nil; CGPDFDictionaryGetDictionary(dictionary, "A", &a);
    if (a != NULL) {
        CGPDFDictionaryGetObject(a, "D", destination);
        if (CGPDFDictionaryGetArray(a, "D", &destArray) ||
            CGPDFDictionaryGetString(a, "D", &destString)) {}
    } else {
        CGPDFDictionaryGetObject(dictionary, "Dest", destination);
        if (CGPDFDictionaryGetArray(dictionary, "Dest", &destArray) ||
            CGPDFDictionaryGetString(dictionary, "Dest", &destString) ||
            CGPDFDictionaryGetName(dictionary, "Dest", &destName)) {}
    }

    if (destString != NULL) {
        const char *name = (const char *)CGPDFStringGetBytePtr(destString);
        destArray = [self findDestination:name document:document];
    }

    if (destName != NULL) {
        CGPDFDictionaryRef catalog = CGPDFDocumentGetCatalog(document);
        CGPDFDictionaryRef dests = NULL;
        if (CGPDFDictionaryGetDictionary(catalog, "Dests", &dests)) {
            CGPDFDictionaryRef dict = NULL;
            if (CGPDFDictionaryGetDictionary(dests, destName, &dict)) {
                CGPDFDictionaryGetArray(dict, "D", &destArray);
            }
        }
    }

    if (destArray != NULL) {
        CGPDFArrayGetDictionary(destArray, 0, &pageDictionary);    
        NSUInteger numberOfPages = CGPDFDocumentGetNumberOfPages(document);
        for (NSUInteger i = 1; i <= numberOfPages; i++) {
            CGPDFPageRef page = CGPDFDocumentGetPage(document, i);
            CGPDFDictionaryRef pd = CGPDFPageGetDictionary(page);
            if (pd == pageDictionary) {
                return i;
            }
        }
   }
    
    return 0;
}

#pragma mark -

- (CGPDFArrayRef)findDestination:(const char *)destinationName
                            node:(CGPDFDictionaryRef)node
{
    CGPDFArrayRef destArray = NULL;
        
               
    CGPDFArrayRef limits = NULL;
    if (CGPDFDictionaryGetArray(node, "Limits", &limits)) {
        CGPDFStringRef start = NULL;
        CGPDFStringRef end = NULL;
        if (CGPDFArrayGetString(limits, 0, &start) && CGPDFArrayGetString(limits, 1, &end)) {
            const char *startName = (const char *)CGPDFStringGetBytePtr(start);
            const char *endName = (const char *)CGPDFStringGetBytePtr(end);
            if (strcmp(destinationName, startName) < 0 || strcmp(destinationName, endName) > 0) {
                return NULL;
            }
        }                    
    }

    CGPDFArrayRef names = NULL;
    if (CGPDFDictionaryGetArray(node, "Names", &names)) {
        size_t namesCount = CGPDFArrayGetCount(names);
        for (int j = 0; j < namesCount; j += 2) {
            CGPDFStringRef name = NULL;
            if (CGPDFArrayGetString(names, j, &name)) {
                const char *n = (const char *)CGPDFStringGetBytePtr(name);
                if (strcmp(destinationName, n) == 0) {
                    if (CGPDFArrayGetArray(names, j + 1, &destArray)) {
                        return destArray;
                    } else {
                        CGPDFDictionaryRef destDictionary = NULL;
                        if (CGPDFArrayGetDictionary(names, j + 1, &destDictionary)) {
                            if (CGPDFDictionaryGetArray(destDictionary, "D", &destArray)) {
                                return destArray;
                            }
                        }
                    }
                }
            }
        }
    }

    CGPDFArrayRef kids = NULL;
    if (CGPDFDictionaryGetArray(node, "Kids", &kids)) {
        size_t count = CGPDFArrayGetCount(kids);
        for (int i = 0; i < count; i++) {
            CGPDFDictionaryRef kid = NULL;
            if (CGPDFArrayGetDictionary(kids, i, &kid)) {
                destArray = [self findDestination:destinationName
                                             node:kid];
                if (destArray) {
                    return destArray;
                }
            }
        }
    }    

    return NULL;
}

- (CGPDFArrayRef)findDestination:(const char *)destinationName
                        document:(CGPDFDocumentRef)document
{
    CGPDFDictionaryRef catalog = CGPDFDocumentGetCatalog(document);
    CGPDFDictionaryRef names = NULL;
    if (CGPDFDictionaryGetDictionary(catalog, "Names", &names)) {
        CGPDFDictionaryRef dests = NULL;
        if (CGPDFDictionaryGetDictionary(names, "Dests", &dests)) {
            return [self findDestination:destinationName
                                    node:dests];
        }
    }

    return NULL;
}

#pragma mark -

- (NSString *)sectionTitleAtIndex:(NSUInteger)index
{
    PDFDocumentOutlineItem *current = nil;
    for (PDFDocumentOutlineItem *item in self.items) {
        if (item.pageNumber <= index) {
            current = item;
            if (item.pageNumber == index) {
                break;
            }
        }
        else {
            break;
        }
    }
    return current.title;
}

#pragma mark -

- (NSString *)description
{
    return [[self.items grt_map:^(PDFDocumentOutlineItem *item) {
        return item.description;
    }] componentsJoinedByString:@"\n"];
}

@end
