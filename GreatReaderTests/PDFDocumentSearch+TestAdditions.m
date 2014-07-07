//
//  PDFDocumentSearch+TestAdditions.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/10/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentSearch+TestAdditions.h"

#import "PDFDocument.h"

@implementation PDFDocumentSearch (TestAdditions)

+ (PDFDocumentSearch *)test_searchWithPDFName:(NSString *)name
{
    NSString *resourcePath = [[NSBundle bundleForClass:self]
                                 pathForResource:name
                                          ofType:@"pdf"];
    PDFDocument *document = [[PDFDocument alloc] initWithPath:resourcePath];
    PDFDocumentSearch *search = [[PDFDocumentSearch alloc] initWithCGPDFDocument:document.CGPDFDocument];
    return search;
}

@end
