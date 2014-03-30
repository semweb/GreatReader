//
//  PDFPageLoopeView.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/29/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFPageLoopeView.h"

@implementation PDFPageLoopeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = CGRectGetWidth(frame) / 2.0;
        self.layer.borderColor = [UIColor blackColor].CGColor;
        self.layer.borderWidth = 1.0;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [[UIColor colorWithWhite:128/255.0 alpha:1.0] set];
    UIRectFill(rect);
    [self.image drawInRect:CGRectMake(-CGRectGetWidth(rect) / 2.0,
                                      -CGRectGetHeight(rect) / 2.0,
                                      CGRectGetWidth(rect) * 2.0,
                                      CGRectGetHeight(rect) * 2.0)];                                      
         
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    [self setNeedsDisplay];
}

@end
