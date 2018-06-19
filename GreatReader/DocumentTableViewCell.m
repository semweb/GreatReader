//
//  DocumentTableViewCell.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/6/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "DocumentTableViewCell.h"

#import <KVOController/FBKVOController.h>

#import "PDFDocument.h"

@interface DocumentTableViewCell ()
@property (nonatomic, strong) FBKVOController *kvoController;
@end

@implementation DocumentTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    CGFloat scale = UIScreen.mainScreen.scale;
    self.imageView.layer.borderWidth = 1.0 / scale;
}

- (void)setDocument:(PDFDocument *)document
{
    _document = document;
    self.kvoController = [FBKVOController controllerWithObserver:self];
    [self.kvoController observe:_document
                        keyPath:@"name"
                        options:NSKeyValueObservingOptionInitial
                          block:^(DocumentTableViewCell *cell, id doc, NSDictionary *change) {
        cell.textLabel.text = document.name;
    }];
    [self.kvoController observe:_document
                        keyPath:@"iconImage"
                        options:NSKeyValueObservingOptionInitial
                          block:^(DocumentTableViewCell *cell, id doc, NSDictionary *change) {
        cell.imageView.image = document.iconImage;
        [cell setNeedsLayout];
    }];        
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (self.document.iconImage) {
        [self.imageView sizeToFit];
        CGFloat w = self.imageView.frame.size.width;
        CGFloat h = self.imageView.frame.size.height;
        if (w < h) {
            w = (w / h) * 50;
            h = 50;
        } else {
            h = (h / w) * 50;
            w = 50;
        }
        self.imageView.bounds = CGRectMake(0, 0, w, h);
        self.imageView.center = CGPointMake(35, 30);

        CGFloat maxX = CGRectGetMaxX(self.textLabel.frame);
        self.textLabel.frame = ({
            CGRect f = self.textLabel.frame;
            f.origin.x = CGRectGetMaxX(self.imageView.frame) + 10;
            f.size.width = maxX - f.origin.x;
            f;
        });
    }
}

@end
