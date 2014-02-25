//
//  PDFDocumentInfoView.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/17.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentInfoView.h"

#import "PDFDocumentInfo.h"

@interface PDFDocumentInfoView ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *outlineLabel;
@property (nonatomic, strong) UILabel *pageLabel;
@end

@implementation PDFDocumentInfoView

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"info.pageDescription"];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.opaque = NO;

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.layer.cornerRadius = 4.0;
        [self addSubview:_titleLabel];
        _outlineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _outlineLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        _outlineLabel.textColor = [UIColor whiteColor];
        _outlineLabel.layer.masksToBounds = YES;
        _outlineLabel.layer.cornerRadius = 4.0;
        [self addSubview:_outlineLabel];        
        _pageLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _pageLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        _pageLabel.textColor = [UIColor whiteColor];
        _pageLabel.layer.masksToBounds = YES;
        _pageLabel.layer.cornerRadius = 4.0;        
        [self addSubview:_pageLabel];

        [self addObserver:self
               forKeyPath:@"info.pageDescription"
                  options:NSKeyValueObservingOptionInitial
                  context:NULL];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    const CGFloat top = 100;
    self.titleLabel.text = self.info.title;
    [self.titleLabel sizeToFit];
    CGRect titleFrame = ({
        CGRect f = self.titleLabel.frame;
        f.origin.x = roundf((self.bounds.size.width - f.size.width) / 2.0),
        f.origin.y = top;
        f;
    });
    self.titleLabel.frame = titleFrame;

    const CGFloat bottom = 100;
    self.pageLabel.text = self.info.pageDescription;
    [self.pageLabel sizeToFit];    
    CGRect pageFrame = ({
        CGRect f = self.pageLabel.frame;
        f.origin.x = roundf((self.bounds.size.width - f.size.width) / 2.0),
        f.origin.y = self.bounds.size.height - bottom - f.size.height;
        f;
    });
    self.pageLabel.frame = pageFrame;

    self.outlineLabel.text = self.info.sectionTitle;
    [self.outlineLabel sizeToFit];    
    CGRect outlineFrame = ({
        CGRect f = self.outlineLabel.frame;
        f.origin.x = roundf((self.bounds.size.width - f.size.width) / 2.0),
        f.origin.y = CGRectGetMinY(self.pageLabel.frame) - f.size.height - 10;
        f;
    });
    self.outlineLabel.frame = outlineFrame;
    self.outlineLabel.hidden = (self.outlineLabel.text == nil);
}

- (void)show
{
    [UIView animateWithDuration:0.25
                     animations:^{ self.alpha = 1.0; }];
}

- (void)hide
{
    [UIView animateWithDuration:0.25
                     animations:^{ self.alpha = 0.0; }];
}

@end
