//
//  PDFDocumentPageSlider.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/15.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentPageSlider.h"

@interface PDFDocumentPageSlider ()
@property (nonatomic, strong) UIImageView *knobView;
@property (nonatomic, strong) NSMutableArray *thumbnailBarViews;
@property (nonatomic, assign, readwrite) NSUInteger numberOfPages;
@property (nonatomic, assign) CGFloat startX;
@property (nonatomic, assign) CGFloat endX;
@end

@implementation PDFDocumentPageSlider

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self reloadData];
}

- (void)setDataSource:(id<PDFDocumentPageSliderDataSource>)dataSource
{
    _dataSource = dataSource;
    if (_dataSource && self.superview) {
        [self reloadData];
    }
}

#pragma mark -

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
    imageView.layer.borderColor = UIColor.grayColor.CGColor;
    return imageView;
}

#pragma mark -

- (void)reloadData
{
    [self replaceSubviews];
}

- (void)replaceSubviews
{
    [self.knobView removeFromSuperview];
    [self.thumbnailBarViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.thumbnailBarViews = [NSMutableArray array];
    
    const CGFloat minSideMargin = 20;
    const CGFloat availableWidth = self.bounds.size.width - (minSideMargin * 2);
    const CGSize thumbnailViewSize = self.thumbnailViewSize;

    self.numberOfPages = [self.dataSource numberOfPagesInPageSlider:self];
    NSUInteger maxNumberOfThumbnails = ((availableWidth - thumbnailViewSize.width) /
                                        (thumbnailViewSize.width + self.space)) + 1;
    NSUInteger numberOfThumbnails = MIN(self.numberOfPages, maxNumberOfThumbnails);
    if (numberOfThumbnails == 0) {
        return;
    }
    CGFloat width = (thumbnailViewSize.width * numberOfThumbnails) +
            (self.space * (numberOfThumbnails - 1));

    self.startX = roundf((self.bounds.size.width - width + thumbnailViewSize.width) / 2.0);
    self.endX = self.startX + width - thumbnailViewSize.width / 2.0;

    for (int i = 0; i < numberOfThumbnails; i++) {
        int index = (numberOfThumbnails > 1)
                ? (self.numberOfPages - 1) * ((CGFloat)i / (numberOfThumbnails - 1))
                : 0;
        UIImageView *imageView = [self makeThumbnailView];
        [self.dataSource pageSlider:self
               pageThumbnailAtIndex:index
                           callback:^(UIImage *image, NSUInteger idx) {
            if (index == idx) {
                imageView.image = image;
            }
        }];       
        [self.thumbnailBarViews addObject:imageView];
        [self addSubview:imageView];
    }

    const CGSize knobSize = self.knobSize;
    self.knobView = [self makeThumbnailView];
    self.knobView.frame = CGRectMake(0, 0, knobSize.width, knobSize.height);
    [self updateKnobView];
    [self addSubview:self.knobView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [self reloadData];

    CGSize size = self.thumbnailViewSize;

    CGFloat x = self.startX - size.width / 2.0;
    CGFloat y = roundf((self.bounds.size.height - size.height) / 2.0);
    for (UIView *v in self.thumbnailBarViews) {
        CGRect f = CGRectMake(x, y, size.width, size.height);
        v.frame = f;
        x = CGRectGetMaxX(f) + self.space;
    }

    [self layoutKnobView];
}

- (void)layoutKnobView
{
    CGFloat progress = (CGFloat)self.currentIndex / (self.numberOfPages - 1);
    self.knobView.center = CGPointMake(roundf((self.endX - self.startX) * progress) + self.startX,
                                       roundf((self.bounds.size.height) / 2.0));
}

#pragma mark - Update Knob

- (void)updateKnobView
{
    self.knobView.image = nil;
    [self.dataSource pageSlider:self
           pageThumbnailAtIndex:self.currentIndex
                       callback:^(UIImage *image, NSUInteger idx) {
        if (idx == self.currentIndex) {
            self.knobView.image = image;
        }
    }];
}

#pragma mark -

- (NSUInteger)indexAtPoint:(CGPoint)point
{
    CGFloat progress = (point.x - self.startX) / (self.endX - self.startX);
    progress = MIN(1.0, MAX(0.0, progress));
    return roundf(progress * (self.numberOfPages - 1));
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];    
    [self handleTouch:touch];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];    
    [self handleTouch:touch];
}

- (void)handleTouch:(UITouch *)touch
{
    CGPoint point = [touch locationInView:self];
    NSUInteger index = [self indexAtPoint:point];
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
