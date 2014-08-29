//
//  PDFTextState.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/2/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFTextState.h"

@implementation PDFTextState

- (instancetype)init
{
    self = [super init];
    if (self) {
        _ctm = CGAffineTransformIdentity;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
	PDFTextState *copy = [[PDFTextState alloc] init];
    copy.leading = self.leading;
    copy.characterSpace = self.characterSpace;
    copy.wordSpace = self.wordSpace;
    copy.fontSize = self.fontSize;
    copy.textMatrix = self.textMatrix;
    copy.textLineMatrix = self.textLineMatrix;
    copy.ctm = self.ctm;
    copy.font = self.font;
	return copy;
}

- (CGAffineTransform)transform
{
    return CGAffineTransformConcat(self.textMatrix, self.ctm);
}

- (void)moveLine:(CGSize)offset
{
    self.textLineMatrix = CGAffineTransformTranslate(self.textLineMatrix,
                                                     offset.width,
                                                     offset.height);
    self.textMatrix = self.textLineMatrix;
}

- (void)move:(CGSize)offset
{
    self.textMatrix = CGAffineTransformTranslate(self.textMatrix,
                                                 offset.width,
                                                 offset.height);
}

@end
