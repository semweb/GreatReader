//
//  PDFDocumentOutlineItemCell.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/20.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentOutlineItemCell.h"

#import "PDFDocumentOutlineItem.h"

@implementation PDFDocumentOutlineItemCell

+ (CGFloat)cellHeightForItem:(PDFDocumentOutlineItem *)item
                       level:(NSUInteger)level
{
    CGFloat vMargin = 14;
    CGFloat x = 15 * (level + 1);
    CGFloat w = 320 - x - self.titleRightMargin;
    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont boldSystemFontOfSize:UIFont.systemFontSize]
    };
    CGRect rect = [item.title boundingRectWithSize:CGSizeMake(w, 10000)
                                           options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                        attributes:attributes
                                           context:NULL];
    CGFloat height = rect.size.height + vMargin * 2;
    return height > 44 ? height : 44;
}

+ (CGFloat)titleRightMargin
{
    return 66;
}

- (void)configureWithItem:(PDFDocumentOutlineItem *)item
                    level:(NSUInteger)level
                  current:(BOOL)current
{
    self.titleLabel.text = item.title;
    self.titleLabel.numberOfLines = 0;
    if (level == 0) {
        self.titleLabel.font = [UIFont boldSystemFontOfSize:UIFont.systemFontSize];
    } else {
        self.titleLabel.font = [UIFont systemFontOfSize:UIFont.systemFontSize];
    }
    self.titleLabel.textColor = current ? self.tintColor : UIColor.blackColor;
    
    self.pageNumberLabel.text = [NSString stringWithFormat:@"%d", (int)item.pageNumber];
    self.pageNumberLabel.textColor = current ? self.tintColor : UIColor.blackColor;
    
    self.separatorInset = UIEdgeInsetsMake(0, 15 * (level + 1),
                                           0, 0);
    self.leftMarginConstraint.constant = 15 * (level + 1);
    self.currentLine.hidden = !current;
}

@end
