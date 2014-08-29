//
//  PDFCMapParser.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/8/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

typedef void (^PDFCMapParserHandler)(NSArray *lines);

#import "PDFCMapParser.h"
#import "NSArray+GreatReaderAdditions.h"

@interface PDFCMapParser ()
@property (nonatomic, strong) NSArray *lines;
@end

@implementation PDFCMapParser

- (instancetype)initWithStream:(CGPDFStreamRef)stream
{
    self = [super init];
    if (self) {
        NSData *data = (__bridge_transfer NSData *)CGPDFStreamCopyData(stream, nil);
        NSString *string = [[NSString alloc] initWithData:data
                                                 encoding:NSUTF8StringEncoding];
        _lines = [string componentsSeparatedByCharactersInSet:NSCharacterSet.newlineCharacterSet];
    }
    return self;
}

- (void)parse
{
    NSArray *operators = @[
        @{
            @"begin": @"begincodespacerange",
            @"end": @"endcodespacerange",
            @"handler": self.codeSpaceRangeHandler
        },
        @{
            @"begin": @"beginbfrange",
            @"end": @"endbfrange",
            @"handler": self.BFRangeHandler
        },
        @{
            @"begin": @"beginbfchar",
            @"end": @"endbfrchar",
            @"handler": self.BFCharHandler
        }         
    ];

    for (int i = 0; i < self.lines.count; i++) {
        NSString *line = self.lines[i];
        NSArray *components = [line componentsSeparatedByString:@" "];
        NSInteger count = [[components firstObject] integerValue];
        if (count > 0 && components.count > 1) {
            NSString *op = components[1];
            for (NSDictionary *operator in operators) {
                if ([operator[@"begin"] isEqualToString:op]) {
                    PDFCMapParserHandler handler = operator[@"handler"];
                    if (components.count == 2) {
                        handler([self.lines subarrayWithRange:NSMakeRange(i + 1, count)]);
                        i += count;
                    } else {
                        NSUInteger endIndex = [components indexOfObject:operator[@"end"]];
                        handler(@[[[components subarrayWithRange:NSMakeRange(2, endIndex - 2)]
                                    componentsJoinedByString:@" "]]);
                    }                   
                }
            }
        }
    }
}

- (NSArray *)parseLine:(NSString *)line
{
    BOOL (^emptyFilter)(id) = ^(NSString *str) {
        return (BOOL)(str.length > 0);
    };    
    NSMutableArray *values = [NSMutableArray array];
    NSArray *components = [[line componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[]"]]
                              grt_filter:emptyFilter];

    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"<> "];
    NSArray *src = [[components[0] componentsSeparatedByCharactersInSet:set]
                              grt_filter:emptyFilter];
    for (NSString *str in src) {
        [values addObject:str];
    }
    if (components.count > 1) {
        NSArray *dest = [[components[1] componentsSeparatedByCharactersInSet:set]
                                                          grt_filter:emptyFilter];
        [values addObject:dest];
    }

    return values;
}

- (PDFCMapParserHandler)codeSpaceRangeHandler
{
    __weak typeof(self) wself = self;
    return ^(NSArray *lines) {
        for (NSString *line in lines) {
            NSArray *values = [wself parseLine:line];
            unsigned from = 0;
            [[NSScanner scannerWithString:values[0]] scanHexInt:&from];
            unsigned to = 0;
            [[NSScanner scannerWithString:values[1]] scanHexInt:&to];
            [wself.delegate parser:self
               foundCodeSpaceRange:NSMakeRange(from, to - from)];
        }
    };
}

- (PDFCMapParserHandler)BFRangeHandler
{
    __weak typeof(self) wself = self;    
    return ^(NSArray *lines) {
        for (NSString *line in lines) {
            NSArray *values = [wself parseLine:line];
            unsigned src1 = 0;
            [[NSScanner scannerWithString:values[0]] scanHexInt:&src1];
            unsigned src2 = 0;
            [[NSScanner scannerWithString:values[1]] scanHexInt:&src2];
            id destObject = values[2];
            if ([destObject isKindOfClass:NSString.class]) {
                NSString *destString = (NSString *)destObject;
                unsigned dest = 0;
                [[NSScanner scannerWithString:destString] scanHexInt:&dest];                
                for (int i = src1; i <= src2; i++) {
                    [wself.delegate parser:self
                              foundMapping:@{@(i): @(i - src1 + dest)}];
                }
            } else if ([destObject isKindOfClass:NSArray.class]) {
                NSArray *destArray = (NSArray *)destObject;
                [destArray enumerateObjectsUsingBlock:^(NSString *destString,
                                                        NSUInteger idx,
                                                        BOOL *stop) {
                    unsigned dest = 0;
                    [[NSScanner scannerWithString:destString] scanHexInt:&dest];
                    [wself.delegate parser:self
                              foundMapping:@{@(idx + src1): @(dest)}];
                }];
            } else {
                NSString *err = [NSString stringWithFormat:@"%@", destObject];
                NSAssert(0, err);
                         
            }
        }
    };
}

- (PDFCMapParserHandler)BFCharHandler
{
    __weak typeof(self) wself = self;    
    return ^(NSArray *lines) {
        for (NSString *line in lines) {
            NSArray *values = [wself parseLine:line];
            unsigned src = 0;
            [[NSScanner scannerWithString:values[0]] scanHexInt:&src];
            unsigned dest = 0;
            [[NSScanner scannerWithString:values[1]] scanHexInt:&dest];
            [wself.delegate parser:self
                      foundMapping:@{@(src): @(dest)}];
        }
    };
}

@end
