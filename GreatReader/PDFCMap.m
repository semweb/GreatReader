//
//  PDFCMap.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/8/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFCMap.h"

#import "PDFCMapParser.h"

@interface PDFCMap () <PDFCMapParserDelegate>
@property (nonatomic, assign) NSRange codeSpaceRange;
@property (nonatomic, strong) NSMutableDictionary *characterMapping;
@end

@implementation PDFCMap

- (instancetype)initWithStream:(CGPDFStreamRef)stream
{
    self = [super init];
    if (self) {
        self.characterMapping = [NSMutableDictionary dictionary];
        PDFCMapParser *parser = [[PDFCMapParser alloc] initWithStream:stream];
        parser.delegate = self;
        [parser parse];
    }
    return self;
}

- (unichar)unicodeFromCID:(char)cid
{
    NSNumber *num = [self.characterMapping objectForKey:@(cid)];
    return [num unsignedCharValue];
}

- (char)CIDFromUnicode:(unichar)unicode
{
    return 0;
}

#pragma mark -

- (void)parser:(PDFCMapParser *)parser
foundCodeSpaceRange:(NSRange)range
{
    self.codeSpaceRange = range;
}

- (void)parser:(PDFCMapParser *)parser
  foundMapping:(NSDictionary *)mapping
{
    [self.characterMapping addEntriesFromDictionary:mapping];
}

@end
