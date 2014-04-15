//
//  PDFDocumentPageSlider.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/15.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentPageSlider.h"

#import "NSArray+GreatReaderAdditions.h"
#import "PDFDocumentPageSliderDataSource.h"
#import "PDFDocumentPageSliderItem.h"
#import "PDFDocumentPageSliderItemView.h"
#import "UIColor+GreatReaderAdditions.h"

@interface PDFDocumentPageSlider ()
@property (nonatomic, strong) UIView *knobView;
@property (nonatomic, strong) NSArray *itemViews;
@property (nonatomic, assign) BOOL moved;
@end

@implementation PDFDocumentPageSlider

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self reloadData];
}

#pragma mark -

- (void)awakeFromNib
{
    self.knobView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    self.knobView.backgroundColor = self.tintColor;    
    self.knobView.layer.borderWidth = 1.0;
    self.knobView.layer.borderColor = self.tintColor.CGColor;
    self.knobView.layer.masksToBounds = YES;
    self.knobView.layer.cornerRadius = 7;
    self.knobView.layer.zPosition = 1000;
    [self addSubview:self.knobView];
}

#pragma mark -

- (CGFloat)sideMargin
{
    return 20;
}

- (CGFloat)space
{
    return 2.0;
}

- (CGSize)knobSize
{
    return CGSizeMake(24, 32);
}

- (CGSize)thumbnailViewSize
{
    return CGSizeMake(18, 24);
}

#pragma mark -

- (UIImageView *)makeThumbnailView
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nil];
    imageView.layer.borderWidth = 0.5;
    imageView.layer.borderColor = UIColor.grt_defaultTintColor.CGColor;
    return imageView;
}

#pragma mark -

- (void)reloadData
{
    [self replaceSubviews];
    [self layoutSubviews];
}

- (void)replaceSubviews
{
    [self.itemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];

    __block BOOL flag = NO;
    self.itemViews = [self.dataSource.items grt_map:^(PDFDocumentPageSliderItem *item) {
        PDFDocumentPageSliderItemView *itemView =
                [[PDFDocumentPageSliderItemView alloc] initWithItem:item];
        itemView.flag = flag;
        flag = !flag;
        return itemView;
    }];

    for (PDFDocumentPageSliderItemView *itemView in self.itemViews) {
        [self addSubview:itemView];
    }   
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    for (PDFDocumentPageSliderItemView *itemView in self.itemViews) {
        [self addSubview:itemView];
        itemView.center = [self positionForProgress:itemView.item.position];
    }    
    [self layoutKnobView];
}

- (void)layoutKnobView
{
    CGFloat progress = (CGFloat)self.currentIndex / (self.dataSource.numberOfPages - 1);
    self.knobView.center = [self positionForProgress:progress];
}

- (CGPoint)positionForProgress:(CGFloat)progress
{
    CGFloat right = CGRectGetWidth(self.frame) - self.sideMargin;
    CGFloat left = self.sideMargin;    
    CGFloat x = progress * (right - left) + left;
    CGFloat y = CGRectGetHeight(self.frame) / 2.0;
    return CGPointMake(x, y);
}

#pragma mark - Update Knob

- (void)updateKnobView
{
    // self.knobView.image = nil;
    // [self.dataSource pageSlider:self
    //        pageThumbnailAtIndex:self.currentIndex
    //                    callback:^(UIImage *image, NSUInteger idx) {
    //     if (idx == self.currentIndex) {
    //         self.knobView.image = image;
    //     }
    // }];
}

#pragma mark -

- (void)drawRect:(CGRect)rect
{
    [UIColor.grayColor set];
    UIBezierPath *path = [UIBezierPath bezierPath];
    CGFloat y = 21.75;
    [path moveToPoint:CGPointMake(self.sideMargin, y)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.bounds) - self.sideMargin, y)];
    path.lineWidth = 0.5;
    [path stroke];
}

#pragma mark -

- (NSUInteger)indexAtPoint:(CGPoint)point
{
    CGFloat right = CGRectGetWidth(self.frame) - self.sideMargin;
    CGFloat left = self.sideMargin;
    CGFloat progress = (point.x - left) / (right - left);
    progress = MIN(1.0, MAX(0.0, progress));
    return roundf(progress * (self.dataSource.numberOfPages - 1));
}

- (PDFDocumentPageSliderItemView *)nearestItemViewAtPoint:(CGPoint)point
{
    PDFDocumentPageSliderItemView *nearest = self.itemViews.firstObject;

    for (PDFDocumentPageSliderItemView *itemView in self.itemViews) {
        CGPoint nearestPoint = CGPointMake(nearest.center.x,
                                           nearest.center.y + (nearest.flag ? 10 : -10));
        CGPoint p = CGPointMake(itemView.center.x,
                                itemView.center.y + (itemView.flag ? 10 : -10));
        CGFloat nearestD = sqrtf(pow(nearestPoint.x - point.x, 2) + pow(nearestPoint.y - point.y, 2));
        CGFloat pD = sqrtf(pow(p.x - point.x, 2) + pow(p.y - point.y, 2));
        if (pD < nearestD) {
            nearest = itemView;
        }
    }

    return nearest;
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.moved = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];    
    [self handleTouch:touch];
    self.moved = YES;    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.moved) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        PDFDocumentPageSliderItemView *itemView =
                [self nearestItemViewAtPoint:point];
        [self moveToIndex:itemView.item.pageNumber];
    }
}

- (void)handleTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self];
    NSUInteger index = [self indexAtPoint:point];
    [self moveToIndex:index];
}

#pragma mark -

- (void)moveToIndex:(NSUInteger)index
{
    if (self.currentIndex != index) {
        self.currentIndex = index;
        [self.delegate pageSlider:self didSelectAtIndex:self.currentIndex];
    }
}

#pragma mark -

- (void)setCurrentIndex:(NSUInteger)index
{
    NSUInteger old = _currentIndex;
    _currentIndex = index;
    if (old != index) {
        [self updateKnobView];        
        [self layoutKnobView];
    }
}

@end
