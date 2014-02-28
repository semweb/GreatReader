//
//  PDFDocumentOutlineItemCell.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/20.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFDocumentOutlineItem;

@interface PDFDocumentOutlineItemCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *pageNumberLabel;
@property (nonatomic, strong) IBOutlet UIView *currentLine;
@property (nonatomic, strong) IBOutlet NSLayoutConstraint *leftMarginConstraint;
+ (CGFloat)cellHeightForItem:(PDFDocumentOutlineItem *)item
                       level:(NSUInteger)level;
- (void)configureWithItem:(PDFDocumentOutlineItem *)item
                    level:(NSUInteger)level
                  current:(BOOL)current;
@end
