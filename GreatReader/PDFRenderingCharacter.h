//
//  PDFRenderingCharacter.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/10/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFTextState;

@interface PDFRenderingCharacter : NSObject
@property (nonatomic, assign) unichar c;
@property (nonatomic, strong) PDFTextState *state;
@property (nonatomic, readonly) CGRect frame;
@property (nonatomic, readonly) NSString *stringDescription;
- (instancetype)initWithCharacter:(unichar)c
                            state:(PDFTextState *)state;
- (BOOL)isNotWordCharater;
- (BOOL)isSameLineAs:(PDFRenderingCharacter *)character;
@end
