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

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        self.opaque = NO;

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.numberOfLines = 0;
        _titleLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.layer.masksToBounds = YES;
        _titleLabel.layer.cornerRadius = 4.0;
        [self addSubview:_titleLabel];
        _outlineLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _outlineLabel.numberOfLines = 0;
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

    CGSize fitSize = self.bounds.size;
    fitSize.width -= 40;

    const CGFloat top = 100;
    self.titleLabel.text = self.info.title;    
    CGRect titleFrame = ({
        CGRect f = self.titleLabel.frame;
        f.size = [self.titleLabel sizeThatFits:fitSize];
        f.origin.x = roundf((self.bounds.size.width - f.size.width) / 2.0),
        f.origin.y = top;
        f;
    });
    self.titleLabel.frame = titleFrame;

    const CGFloat bottom = 100;
    self.pageLabel.text = self.info.pageDescription;
    CGRect pageFrame = ({
        CGRect f = self.pageLabel.frame;
        f.size = [self.pageLabel sizeThatFits:fitSize];    
        f.origin.x = roundf((self.bounds.size.width - f.size.width) / 2.0),
        f.origin.y = self.bounds.size.height - bottom - f.size.height;
        f;
    });
    self.pageLabel.frame = pageFrame;

    self.outlineLabel.text = self.info.sectionTitle;    
    CGRect outlineFrame = ({
        CGRect f = self.outlineLabel.frame;
        f.size = [self.outlineLabel sizeThatFits:fitSize];
        f.origin.x = roundf((self.bounds.size.width - f.size.width) / 2.0),
        f.origin.y = CGRectGetMinY(self.pageLabel.frame) - f.size.height - 10;
        f;
    });
    self.outlineLabel.frame = outlineFrame;
    self.outlineLabel.hidden = (self.outlineLabel.text == nil);
}

- (void)show
{
    [self cancelHideIfNeeded];    
    [UIView animateWithDuration:0.25
                     animations:^{ self.alpha = 1.0; }];
}

- (void)hide
{
    [self cancelHideIfNeeded];
    [UIView animateWithDuration:0.25
                     animations:^{ self.alpha = 0.0; }];
}

- (void)showAndHide
{
    // need not to send 'cancelHideIfNeeded' bacause 'show' method calls it
    [self show];
    [self performSelector:@selector(hide) withObject:nil afterDelay:2.0];
}

- (void)cancelHideIfNeeded
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self
                                             selector:@selector(hide)
                                               object:nil];
}

@end
