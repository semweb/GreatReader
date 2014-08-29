//
//  PDFDocumentSearchStateCell.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/18/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentSearchStateCell.h"

@interface PDFDocumentSearchStateCell ()
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@end

@implementation PDFDocumentSearchStateCell

- (instancetype)init
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (self) {
        _indicator = [[UIActivityIndicatorView alloc]
                         initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:_indicator];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.indicator.center = CGPointMake(roundf(self.contentView.frame.size.width / 2),
                                        roundf(self.contentView.frame.size.height / 2));
}

- (void)setSearching:(BOOL)searching
{
    if (searching) {
        [self.indicator startAnimating];
    } else {
        [self.indicator stopAnimating];
    }
}

- (BOOL)searching
{
    return !self.indicator.isHidden;
}

@end
