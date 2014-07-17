
//
//  PDFDocumentSearch.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/7/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentSearch.h"

#import "NSArray+GreatReaderAdditions.h"
#import "PDFDocument.h"
#import "PDFPageScanner.h"
#import "PDFRenderingCharacter.h"
#import "PDFDocumentSearchResult.h"

@interface PDFDocumentSearch ()
@property (nonatomic, assign) BOOL searching;
@property (nonatomic, assign) BOOL cancel;
@end

@implementation PDFDocumentSearch

- (instancetype)initWithDocument:(PDFDocument *)document
{
    self = [super init];
    if (self) {
        _document = document;
    }
    return self;
}

- (void)cancelSearch
{
    self.cancel = YES;
    while (self.searching) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.01]];
    }
    self.cancel = NO;
}

- (void)searchWithString:(NSString *)keyword
{
    if (self.searching) {
        [self cancelSearch];
    }
    self.searching = YES;
    size_t numberOfPages = CGPDFDocumentGetNumberOfPages(self.document.CGPDFDocument);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        for (int i = 1; i <= numberOfPages; i++) {
            if (self.cancel) {
                break;
            }
            [self searchWithString:keyword
                            atPage:i];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.searching = NO;
        });
    });
}

- (void)searchWithString:(NSString *)keyword
                  atPage:(NSUInteger)index
{
    CGPDFPageRef page = CGPDFDocumentGetPage(self.document.CGPDFDocument, index);
    PDFPageScanner *scanner = [[PDFPageScanner alloc] initWithCGPDFPage:page];
    NSArray *contents = [scanner scanStringContents];
    NSString *text = [[contents grt_map:^(PDFRenderingCharacter *character) {
        return character.stringDescription;
    }] componentsJoinedByString:@""];
    NSRange range = [text rangeOfString:keyword];
    while (range.location != NSNotFound) {
        PDFDocumentSearchResult *result =
                [self searchResultWithCharacters:contents
                                           range:range
                                          atPage:index];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate search:self
                    didFindString:result];
        });

        NSUInteger start = range.location + range.length;
        NSRange targetRange = NSMakeRange(start,
                                          text.length - start);
        range = [text rangeOfString:keyword
                            options:0
                              range:targetRange];
    }
}

- (PDFDocumentSearchResult *)searchResultWithCharacters:(NSArray *)characters
                                                  range:(NSRange)range
                                                 atPage:(NSUInteger)page
{
    const NSUInteger maxLength = 30;
    NSUInteger left = (maxLength - range.length) / 2;
    if ((int)(range.location - left) < 0) {
        range.location = 0;
        range.length = MIN(maxLength, characters.count);
    } else {
        range.location = range.location - left;
        range.length = MIN(maxLength, characters.count - range.location);
        if (range.length < maxLength) {
            NSInteger location = range.location - (maxLength - range.length);
            if (location < 0) {
                location = 0;
            }
            range.location = location;
            range.length = characters.count - range.location;
        }
    }
    
    NSString *text = [[[characters subarrayWithRange:range] grt_map:^(PDFRenderingCharacter *character) {
        return character.stringDescription;
    }] componentsJoinedByString:@""];

    PDFDocumentSearchResult *result =
            [PDFDocumentSearchResult resultWithSurroundingText:text
                                                        atPage:page];
    return result;
}

@end
