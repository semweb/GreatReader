//
//  FileCell.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/18.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "FileCell.h"

#import "File.h"

@implementation FileCell

- (void)dealloc
{
    self.file = nil;
    [self removeObserver:self forKeyPath:@"file.name"];              
    [self removeObserver:self forKeyPath:@"file.iconImage"];
}

- (void)awakeFromNib
{
    [self addObserver:self
           forKeyPath:@"file.name"
              options:NSKeyValueObservingOptionOld
              context:NULL];
    [self addObserver:self
           forKeyPath:@"file.iconImage"
              options:NSKeyValueObservingOptionOld
              context:NULL];
}

- (void)setFile:(File *)file
{
    [_file removeObserver:self forKeyPath:@"name"];
    [_file removeObserver:self forKeyPath:@"iconImage"];
    
    _file = file;

    if (file) {
        [file addObserver:self
               forKeyPath:@"name"
                  options:NSKeyValueObservingOptionInitial
                  context:NULL];
        [file addObserver:self
               forKeyPath:@"iconImage"
                  options:NSKeyValueObservingOptionInitial
                  context:NULL];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"name"]) {
        self.textLabel.text = self.file.name;
    } else if ([keyPath isEqualToString:@"iconImage"]) {
        self.imageView.image = self.file.iconImage;
        [self setNeedsLayout];
    }
}

@end
