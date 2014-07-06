//
//  DocumentCollectionViewCell.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/6/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "DocumentCollectionViewCell.h"

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
        CGFloat w = rect.size.width;
        CGPoint center = CGPointMake(w / 2.0, w / 2.0);
        CGRect r = CGRectMake(roundf(center.x - self.document.iconImage.size.width / 2.0),
                              roundf(center.y - self.document.iconImage.size.height / 2.0),
                              roundf(self.document.iconImage.size.width),
                              roundf(self.document.iconImage.size.height));
        [self.document.iconImage drawInRect:r];
        CGFloat lineWidth = 1.0 / [UIScreen mainScreen].scale;
        CGRect bezierPathRect;
        if (self.selected) {
            [self.tintColor set];
            lineWidth = 2;
            bezierPathRect = r;
        } else {
            [[UIColor blackColor] set];
            bezierPathRect = CGRectInset(r, lineWidth / 2.0, lineWidth / 2.0);
        }
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:bezierPathRect];
        bezierPath.lineWidth = lineWidth;
        [bezierPath stroke];
    }
}

@end
