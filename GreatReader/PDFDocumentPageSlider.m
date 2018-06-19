//
//  PDFDocumentPageSlider.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/15.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentPageSlider.h"

#import <KVOController/FBKVOController.h>

#import "NSArray+GreatReaderAdditions.h"
#import "PDFDocumentPageSliderModel.h"
#import "UIColor+GreatReaderAdditions.h"

@interface PDFDocumentPageSliderKnobView : UIView
@end

@implementation PDFDocumentPageSliderKnobView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = self.tintColor;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = self.tintColor.CGColor;
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = 7;
        self.layer.zPosition = 1000;
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect b = self.bounds;
    b.origin.x -= 15;
    b.origin.y -= 15;
    b.size.width += 30;
    b.size.height += 30;
    return CGRectContainsPoint(b, point);
}

@end

@interface PDFDocumentPageSlider ()
@property (nonatomic, strong) UIView *knobView;
@property (nonatomic, strong) NSArray *itemViews;
@property (nonatomic, assign) BOOL started;
@property (nonatomic, strong) FBKVOController *kvoController;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *forwardButton;
@end

@implementation PDFDocumentPageSlider

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.knobView = [[PDFDocumentPageSliderKnobView alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
    [self addSubview:self.knobView];

    self.backButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.backButton setImage:[UIImage imageNamed:@"Back.png"]
                     forState:UIControlStateNormal];
    [self.backButton addTarget:self
                        action:@selector(goBack:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.backButton sizeToFit];
    [self addSubview:self.backButton];

    self.forwardButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.forwardButton setImage:[UIImage imageNamed:@"Forward.png"]
                     forState:UIControlStateNormal];
    [self.forwardButton addTarget:self
                        action:@selector(goForward:)
              forControlEvents:UIControlEventTouchUpInside];    
    [self.forwardButton sizeToFit];
    [self addSubview:self.forwardButton];
}

#pragma mark -

- (void)goBack:(id)sender
{
    [self.delegate pageSliderBackClicked:self];
}

- (void)goForward:(id)sender
{
    [self.delegate pageSliderForwardClicked:self];
}
    
#pragma mark -

- (void)setModel:(PDFDocumentPageSliderModel *)model
{
    _model = model;

    self.kvoController = [FBKVOController controllerWithObserver:self];    
    [self.kvoController observe:self.model
                        keyPath:@"currentPage"
                        options:NSKeyValueObservingOptionInitial
                          block:^(PDFDocumentPageSlider *slider, id obj, NSDictionary *change) {
        [slider layoutKnobView];
    }];
    UIButton *back = self.backButton;
    [self.kvoController observe:self.model
                        keyPath:@"canGoBack"
                        options:NSKeyValueObservingOptionInitial
                          block:^(PDFDocumentPageSlider *slider, PDFDocumentPageSliderModel *model, NSDictionary *change) {
        back.enabled = model.canGoBack;
    }];
    UIButton *forward = self.forwardButton;
    [self.kvoController observe:self.model
                        keyPath:@"canGoForward"
                        options:NSKeyValueObservingOptionInitial
                          block:^(PDFDocumentPageSlider *slider, PDFDocumentPageSliderModel *model, NSDictionary *change) {
        forward.enabled = model.canGoForward;
    }];
}

#pragma mark -

- (CGFloat)sideMargin
{
    return 50;
}

- (CGFloat)space
{
    return 2.0;
}

- (CGSize)knobSize
{
    return CGSizeMake(24, 32);
}

#pragma mark -

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutKnobView];
    [self layoutButtons];
}

- (void)layoutButtons
{
    const CGFloat margin = 10;
    
    self.backButton.frame = ({
        CGRect f = self.backButton.frame;
        f.origin.x = margin;
        f.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(f)) / 2.0;
        f;
    });

    self.forwardButton.frame = ({
        CGRect f = self.forwardButton.frame;
        f.origin.x = CGRectGetWidth(self.frame) - CGRectGetWidth(f) - margin;
        f.origin.y = (CGRectGetHeight(self.frame) - CGRectGetHeight(f)) / 2.0;
        f;
    });
}

- (void)layoutKnobView
{
    CGFloat progress = (CGFloat)(self.model.currentPage - 1) / MAX(1, (self.model.numberOfPages - 1));
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
    if (progress < -0.1 || progress > 1.1) {
        return NSNotFound;
    }
    progress = MIN(1.0, MAX(0.0, progress));
    return roundf(progress * (self.model.numberOfPages - 1)) + 1;
}

#pragma mark - Touch

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];

    self.started = NO;
    if (![self.knobView pointInside:[touch locationInView:self.knobView]
                          withEvent:event]) {
        return;
    }
    
    CGPoint point = [touch locationInView:self];
    NSUInteger index = [self indexAtPoint:point];
    if (index != NSNotFound) {
        [self.delegate pageSlider:self didStartAtIndex:index];
        self.started = YES;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.started) return;
    
    UITouch *touch = [touches anyObject];    
    CGPoint point = [touch locationInView:self];
    NSUInteger index = [self indexAtPoint:point];
    if (index != NSNotFound && self.model.currentPage != index) {
        [self.delegate pageSlider:self didSelectAtIndex:index];
    }
}

@end
