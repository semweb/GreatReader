//
//  PDFDocumentNameList.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 8/5/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentNameList.h"

#import "PDFUtils.h"

@interface PDFDocumentNameList ()
@property (nonatomic, strong) NSDictionary *names;
@end

@implementation PDFDocumentNameList

- (instancetype)initWithCGPDFDocument:(CGPDFDocumentRef)document
{
    self = [super init];
    if (self) {
        _names = [self namesOfDocument:document];
    }
    return self;
}

- (NSDictionary *)namesOfDocument:(CGPDFDocumentRef)document
{
    CGPDFDictionaryRef names = nil;
    CGPDFDictionaryGetDictionary(CGPDFDocumentGetCatalog(document),
                                 "Names",
                                 &names);
    return [self namesOfItem:PDFDictionaryGetDictionary(names, "Dests")
                    document:document];
}

- (NSDictionary *)namesOfItem:(CGPDFDictionaryRef)dictionary
                     document:(CGPDFDocumentRef)document
{
    NSMutableDictionary *results = [NSMutableDictionary dictionary];

    CGPDFArrayRef kids = PDFDictionaryGetArray(dictionary, "Kids");
    CGPDFArrayRef names = PDFDictionaryGetArray(dictionary, "Names");
    if (kids) {
        for (int i = 0; i < CGPDFArrayGetCount(kids); i++) {
            CGPDFDictionaryRef kid = PDFArrayGetDictionary(kids, i);
            [results addEntriesFromDictionary:[self namesOfItem:kid document:document]];
        }
    } else if (names) {
        for (int i = 0; i < CGPDFArrayGetCount(names); i++) {
            NSString *string = PDFArrayGetString(names, i);
            CGPDFArrayRef d = PDFArrayGetArray(names, i + 1);
            if (!d) {
                CGPDFDictionaryRef dic = PDFArrayGetDictionary(names, i + 1);
                d = PDFDictionaryGetArray(dic, "D");
            }
            CGPDFDictionaryRef page = PDFArrayGetDictionary(d, 0);
            [results setObject:@([self pageNumberForPage:page document:document])
                        forKey:string];
            i++;
        }
    }
    
    return [results copy];
}

- (NSUInteger)pageNumberForPage:(CGPDFDictionaryRef)page
                       document:(CGPDFDocumentRef)document
{
    NSUInteger numberOfPages = CGPDFDocumentGetNumberOfPages(document);
    for (NSUInteger i = 1; i <= numberOfPages; i++) {
        CGPDFPageRef p = CGPDFDocumentGetPage(document, i);
        CGPDFDictionaryRef pd = CGPDFPageGetDictionary(p);
        if (pd == page) {
            return i;
        }
    }
    return NSNotFound;
}

- (NSUInteger)pageNumberForName:(NSString *)name
{
    NSNumber *num = [self.names objectForKey:name];
    if (num) {
        return [num unsignedIntegerValue];
    } else {
        return NSNotFound;
    }
}

@end
