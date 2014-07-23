//
//  DocumentCollectionViewCell.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/6/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "DocumentCollectionViewCell.h"

#import <KVOController/FBKVOController.h>

#import "Device.h"
#import "PDFDocument.h"

@interface DocumentCollectionViewCell ()
@property (nonatomic, strong) FBKVOController *kvoController;
@property (nonatomic, strong) IBOutlet UILabel *textLabel;
@property (nonatomic, strong) IBOutlet UIView *selectionView;
@property (nonatomic, strong, readwrite) IBOutlet UIImageView *imageView;
@end

@implementation DocumentCollectionViewCell

- (void)awakeFromNib
{
    CGFloat scale = [UIScreen mainScreen].scale;
    self.imageView.layer.borderWidth = 1.0 / scale;
    self.imageView.layer.borderColor = UIColor.blackColor.CGColor;
    self.selectionView.hidden = !self.selected;
    self.selectionView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    self.selectionView.layer.borderWidth = 1.0 / scale;
    self.selectionView.layer.borderColor = UIColor.blackColor.CGColor;    
}

- (void)setDocument:(PDFDocument *)document
{
    _document = document;
    self.kvoController = [FBKVOController controllerWithObserver:self];
    [self.kvoController observe:_document
                        keyPath:@"name"
                        options:NSKeyValueObservingOptionInitial
                          block:^(DocumentCollectionViewCell *cell, id doc, NSDictionary *change) {
        cell.textLabel.text = document.name;
    }];
    [self.kvoController observe:_document
                        keyPath:@"iconImage"
                        options:NSKeyValueObservingOptionInitial
                          block:^(DocumentCollectionViewCell *cell, id doc, NSDictionary *change) {
        cell.imageView.image = document.iconImage;
        [cell setNeedsLayout];
    }];        
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.selectionView.hidden = !selected;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self.imageView sizeToFit];
    CGRect frame = self.imageView.frame;
    CGFloat scale = MAX(frame.size.width / self.frame.size.width,
                        frame.size.height / self.frame.size.width);
    if (scale > 1.0) {
        frame.size = CGSizeMake(floorf(frame.size.width / scale),
                                floorf(frame.size.height / scale));
    }
    frame.origin = CGPointMake(self.frame.size.width / 2 - frame.size.width / 2,
                               self.frame.size.width - frame.size.height);
    self.imageView.frame = frame;
    self.selectionView.frame = frame;
}

@end
