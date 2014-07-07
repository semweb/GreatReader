//
//  PDFDocumentSearchResult.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/7/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentSearchResult.h"

#import "NSArray+GreatReaderAdditions.h"
#import "PDFRenderingCharacter.h"

@interface PDFDocumentSearchResult ()
@property (nonatomic, assign, readwrite) NSUInteger page;
@property (nonatomic, copy, readwrite) NSString *surroundingText;
@end

@implementation PDFDocumentSearchResult

+ (PDFDocumentSearchResult *)resultWithSurroundingText:(NSString *)surroundingText
                                                atPage:(NSUInteger)page;
{
    PDFDocumentSearchResult *result = [PDFDocumentSearchResult new];
    result.page = page;
    result.surroundingText = surroundingText;
    return result;
}

@end
