//
//  DocumentTableViewCell.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/6/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "DocumentTableViewCell.h"

#import "PDFDocument.h"

@interface DocumentTableViewCell ()
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UIImageView *iconView;
@end

@implementation DocumentTableViewCell

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"document.name"];              
    [self removeObserver:self forKeyPath:@"document.iconImage"];
}

- (void)awakeFromNib
{
    CGFloat scale = UIScreen.mainScreen.scale;
    self.iconView.layer.borderWidth = 1.0 / scale;
    
    [self addObserver:self
           forKeyPath:@"document.name"
              options:NSKeyValueObservingOptionOld
              context:NULL];
    [self addObserver:self
           forKeyPath:@"document.iconImage"
              options:NSKeyValueObservingOptionOld
              context:NULL];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"document.name"]) {
        self.titleLabel.text = self.document.name;
    } else if ([keyPath isEqualToString:@"document.iconImage"]) {
        self.iconView.image = self.document.iconImage;
        [self setNeedsLayout];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.document.iconImage) {
        [self.iconView sizeToFit];
        CGFloat w = self.iconView.frame.size.width;
        CGFloat h = self.iconView.frame.size.height;
        if (w < h) {
            w = (w / h) * 50;
            h = 50;
        } else {
            h = (h / w) * 50;
            w = 50;
        }
        self.iconView.bounds = CGRectMake(0, 0, w, h);
        self.iconView.center = CGPointMake(35, 30);
    }
}

@end
