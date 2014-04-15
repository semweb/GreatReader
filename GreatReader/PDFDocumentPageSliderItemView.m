//
//  PDFDocumentPageSliderItemView.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 4/14/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentPageSliderItemView.h"

#import "PDFDocumentPageSliderItem.h"
#import "UIColor+GreatReaderAdditions.h"

@interface PDFDocumentPageSliderItemView ()
@end

@implementation PDFDocumentPageSliderItemView

+ (CGSize)sizeForItem:(PDFDocumentPageSliderItem *)item
{
    if ([item isKindOfClass:PDFDocumentPageSliderOutlineItem.class]) {
        return CGSizeMake(6, 40);
    } else if ([item isKindOfClass:PDFDocumentPageSliderBookmarkItem.class]) {
        return CGSizeMake(6, 40);        
    } else {
        return CGSizeMake(10, 44);
    }
}

- (instancetype)initWithItem:(PDFDocumentPageSliderItem *)item
{
    CGRect frame = CGRectZero;
    frame.size = [[self class] sizeForItem:item];
    self = [super initWithFrame:frame];
    if (self) {
        _item = item;
        self.backgroundColor = UIColor.clearColor;
        if ([self.item isKindOfClass:PDFDocumentPageSliderBookmarkItem.class]) {
            self.tintColor = [UIColor redColor];
        } else {
            self.tintColor = [UIColor grayColor];
        }
    }
    return self;
}

- (UIColor *)strokeColor
{
    return self.tintColor;
}

- (UIColor *)fillColor
{
    if ([self.item isKindOfClass:PDFDocumentPageSliderOutlineItem.class]) {
        return self.tintColor;
    } else if ([self.item isKindOfClass:PDFDocumentPageSliderBookmarkItem.class]) {
        return self.tintColor;
    } else {
        return UIColor.whiteColor;
    }    
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGFloat radius = rect.size.width - 1;
    CGRect circle = CGRectMake(0.5, 4.5,
                               radius, radius);
    [self.fillColor set];
    [[UIBezierPath bezierPathWithOvalInRect:circle] fill];
    [self.strokeColor set];
    [[UIBezierPath bezierPathWithOvalInRect:circle] stroke];

    CGRect line = ({
        CGFloat x = CGRectGetWidth(rect) / 2.0 - 0.5;
        CGFloat y = CGRectGetMaxY(circle);
        CGRectMake(x, y,
                   1, CGRectGetHeight(rect) / 2.0 - y);
    });
    UIRectFill(line);
}

- (void)setFlag:(BOOL)flag
{
    _flag = flag;
    if (self.flag) {
        self.transform = CGAffineTransformMakeScale(1.0, -1.0);
    }
}

@end
