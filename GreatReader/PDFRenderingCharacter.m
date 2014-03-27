//
//  PDFRenderingCharacter.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/10/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFRenderingCharacter.h"

#import "PDFFont.h"
#import "PDFFontDescriptor.h"
#import "PDFTextState.h"

@implementation PDFRenderingCharacter

- (instancetype)initWithCharacter:(unichar)c
                            state:(PDFTextState *)state
{
    self = [super init];
    if (self) {
        _c = c;
        _state = state;
    }
    return self;
}

- (CGRect)frame
{
    CGFloat w = [self.state.font widthOfCharacter:self.c
                                     withFontSize:self.state.fontSize] / 1000.0;
    CGFloat minY = self.state.font.fontDescriptor.descent * self.state.fontSize / 1000.0;
    CGFloat maxY = self.state.font.fontDescriptor.ascent * self.state.fontSize / 1000.0;
    return CGRectMake(0, minY, w, maxY - minY);
}

- (NSString *)description
{
    NSString *desc = [super description];
    return [NSString stringWithFormat:@"%@: %C,%@",
                     desc,
                     self.c,
                     NSStringFromCGRect(self.frame)];
}

- (NSString *)stringDescription
{
    return [NSString stringWithFormat:@"%C", self.c];
}

- (BOOL)isNotWordCharater
{
    NSCharacterSet *characterSet = [NSCharacterSet alphanumericCharacterSet];    
    return [self.stringDescription rangeOfCharacterFromSet:characterSet].length == 0;
}

- (BOOL)isSameLineAs:(PDFRenderingCharacter *)character
{
    CGRect f1 = CGRectApplyAffineTransform(self.frame,
                                           self.state.transform);
    CGRect f2 = CGRectApplyAffineTransform(character.frame,
                                           character.state.transform);
    return (CGRectGetMinY(f1) <= CGRectGetMinY(f2) && CGRectGetMinY(f2) <= CGRectGetMaxY(f1)) ||
            (CGRectGetMinY(f1) <= CGRectGetMaxY(f2) && CGRectGetMaxY(f2) <= CGRectGetMaxY(f1));
            
}

@end
