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
@property (nonatomic, assign, readwrite) NSRange range;
@property (nonatomic, copy, readwrite) NSString *surroundingText;
@end

@implementation PDFDocumentSearchResult

+ (PDFDocumentSearchResult *)resultWithSurroundingText:(NSString *)surroundingText
                                                 range:(NSRange)range
                                                atPage:(NSUInteger)page;
{
    PDFDocumentSearchResult *result = [PDFDocumentSearchResult new];
    result.range = range;
    result.page = page;
    result.surroundingText = surroundingText;
    return result;
}

@end

@implementation PDFDocumentSearchResult (TableViewCellAdditions)

- (NSAttributedString *)attributedDescription
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    NSDictionary *boldAttributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:14]};    

    NSMutableAttributedString *string = [NSMutableAttributedString new];
    [string appendAttributedString:
        [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n",
                                                             [NSString stringWithFormat:LocalizedString(@"find.page-format"),
                                                                       (int)self.page]]
                                        attributes:boldAttributes]];
    [string appendAttributedString:
        [[NSAttributedString alloc] initWithString:[self.surroundingText substringToIndex:self.range.location]
                                        attributes:attributes]];
    [string appendAttributedString:
        [[NSAttributedString alloc] initWithString:[self.surroundingText substringWithRange:self.range]
                                        attributes:boldAttributes]];
    [string appendAttributedString:
        [[NSAttributedString alloc] initWithString:[self.surroundingText substringFromIndex:self.range.location + self.range.length]
                                        attributes:attributes]];
    return string;
}

@end

