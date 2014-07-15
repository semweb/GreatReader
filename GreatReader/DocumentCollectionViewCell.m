//
//  DocumentCollectionViewCell.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/6/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "DocumentCollectionViewCell.h"

#import "Device.h"
#import "PDFDocument.h"

@interface DocumentCollectionViewCell ()
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@end

@implementation DocumentCollectionViewCell

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"document.name"];              
    [self removeObserver:self forKeyPath:@"document.iconImage"];
}

- (void)setDocument:(PDFDocument *)document
{
    _document = document;
}

- (void)awakeFromNib
{
    [self addObserver:self
           forKeyPath:@"document.name"
              options:NSKeyValueObservingOptionOld
              context:NULL];
    [self addObserver:self
           forKeyPath:@"document.iconImage"
              options:NSKeyValueObservingOptionOld
              context:NULL];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"document.name"]) {
        self.titleLabel.text = self.document.name;
    } else if ([keyPath isEqualToString:@"document.iconImage"]) {
        [self setNeedsDisplay];
    }
}

- (void)drawRect:(CGRect)rect
{
    if (self.document.iconImage) {
        // draw image
        CGSize imageSize = self.document.iconImage.size;
        CGRect r = CGRectMake(roundf(rect.size.width / 2.0 - imageSize.width / 2.0),
                              roundf(rect.size.width - imageSize.height),
                              roundf(imageSize.width),
                              roundf(imageSize.height));
        [self.document.iconImage drawInRect:r];
        // draw selected white overlay
        if (self.selected) {
            [[[UIColor whiteColor] colorWithAlphaComponent:0.4] set];
            [[UIBezierPath bezierPathWithRect:r] fill];
        }        
        // draw border
        CGFloat lineWidth = 1.0 / [UIScreen mainScreen].scale;
        CGRect bezierPathRect = CGRectInset(r, lineWidth / 2.0, lineWidth / 2.0);
        [[UIColor blackColor] set];
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:bezierPathRect];
        bezierPath.lineWidth = lineWidth;
        [bezierPath stroke];
        // draw selected check mark
        if (self.selected) {
            UIImage *checkImage = [UIImage imageNamed:@"Check"];
            const CGFloat margin = IsPad() ? 6 : 4;
            [checkImage drawAtPoint:CGPointMake(CGRectGetMaxX(r) - checkImage.size.width - margin,
                                                CGRectGetMaxY(r) - checkImage.size.height - margin)];
        }
    }
}

@end
