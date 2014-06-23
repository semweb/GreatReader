//
//  PDFRecentDocumentCell.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/07.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFRecentDocumentCell.h"

#import "PDFDocument.h"

@interface PDFRecentDocumentCell ()
@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@end

@implementation PDFRecentDocumentCell

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
        CGRect r = CGRectMake(center.x - self.document.iconImage.size.width / 2.0,
                              center.y - self.document.iconImage.size.height / 2.0,
                              self.document.iconImage.size.width,
                              self.document.iconImage.size.height);
        [self.document.iconImage drawInRect:r];
        CGFloat lineWidth = 1.0 / [UIScreen mainScreen].scale;
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRect:CGRectInset(r, lineWidth / 2.0, lineWidth / 2.0)];
        bezierPath.lineWidth = lineWidth;
        [bezierPath stroke];
    }
}

@end
