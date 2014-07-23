//
//  PDFDocument+TestAdditions.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocument+TestAdditions.h"

#import "PDFDocument.h"

@implementation PDFDocument (TestAdditions)

+ (PDFDocument *)test_documentWithPDFName:(NSString *)name
{
    NSString *resourcePath = [[NSBundle bundleForClass:self]
                                 pathForResource:name
                                          ofType:@"pdf"];
    PDFDocument *document = [[PDFDocument alloc] initWithPath:resourcePath];
    return document;
}

@end
