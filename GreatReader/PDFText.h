//
//  PDFText.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/2/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFTextState;

@interface PDFText : NSObject
- (instancetype)initWithText:(NSString *)text
                       state:(PDFTextState *)state;
@property (nonatomic, strong) PDFTextState *state;
@property (nonatomic, copy) NSString *text;
@end
