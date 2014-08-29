//
//  PDFText.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/2/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFText.h"

#import "PDFTextState.h"

@implementation PDFText

- (instancetype)initWithText:(NSString *)text
                       state:(PDFTextState *)state
{
    self = [super init];
    if (self) {
        _text = text;
        _state = state;
    }
    return self;
}

@end
