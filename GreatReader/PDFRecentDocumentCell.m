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
    self.backgroundColor = [UIColor whiteColor];

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
        self.imageView.image = self.document.iconImage;
    }
}

@end
