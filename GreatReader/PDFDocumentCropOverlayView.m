//
//  PDFDocumentCropOverlayView.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/22.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentCropOverlayView.h"

#import "UIColor+GreatReaderAdditions.h"

@class PDFDocumentCropOverlayKnob;
@protocol PDFDocumentCropOverlayKnobDelegate <NSObject>
- (void)knob:(PDFDocumentCropOverlayKnob *)knob moveTo:(CGPoint)point;
@end

@interface PDFDocumentCropOverlayKnob : UIView
@property (nonatomic, weak) id<PDFDocumentCropOverlayKnobDelegate> delegate;
@end

@implementation PDFDocumentCropOverlayKnob

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.alpha = 0.8;
    }
    return self;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint previousLocation = [touch previousLocationInView:self];
    CGPoint location = [touch locationInView:self];

    CGPoint to = self.center;
    to.x += (location.x - previousLocation.x);
    to.y += (location.y - previousLocation.y);
    [self.delegate knob:self moveTo:to];
}

- (void)drawRect:(CGRect)rect
{
    CGFloat drawWidth = 10;
    CGRect r = CGRectMake(roundf(rect.size.width - drawWidth) / 2.0,
                          roundf(rect.size.height - drawWidth) / 2.0,
                          drawWidth, drawWidth);
    [[UIColor redColor] set];    
    [[UIBezierPath bezierPathWithOvalInRect:r] fill];    
}

@end

@interface PDFDocumentCropOverlayView () <PDFDocumentCropOverlayKnobDelegate>
@property (nonatomic, strong) PDFDocumentCropOverlayKnob *topKnob;
@property (nonatomic, strong) PDFDocumentCropOverlayKnob *leftKnob;
@property (nonatomic, strong) PDFDocumentCropOverlayKnob *bottomKnob;
@property (nonatomic, strong) PDFDocumentCropOverlayKnob *rightKnob;
@property (nonatomic, strong) PDFDocumentCropOverlayKnob *leftTopKnob;
@property (nonatomic, strong) PDFDocumentCropOverlayKnob *leftBottomKnob;
@property (nonatomic, strong) PDFDocumentCropOverlayKnob *rightBottomKnob;
@property (nonatomic, strong) PDFDocumentCropOverlayKnob *rightTopKnob;
@property (nonatomic, assign) CGRect knobRect;
@end

@implementation PDFDocumentCropOverlayView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = 28;
        
        _topKnob = [[PDFDocumentCropOverlayKnob alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        _leftKnob = [[PDFDocumentCropOverlayKnob alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        _bottomKnob = [[PDFDocumentCropOverlayKnob alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        _rightKnob = [[PDFDocumentCropOverlayKnob alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        _leftTopKnob = [[PDFDocumentCropOverlayKnob alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        _leftBottomKnob = [[PDFDocumentCropOverlayKnob alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        _rightBottomKnob = [[PDFDocumentCropOverlayKnob alloc] initWithFrame:CGRectMake(0, 0, width, width)];
        _rightTopKnob = [[PDFDocumentCropOverlayKnob alloc] initWithFrame:CGRectMake(0, 0, width, width)];
            
        [self addSubview:_topKnob];
        [self addSubview:_leftKnob];
        [self addSubview:_bottomKnob];
        [self addSubview:_rightKnob];
        [self addSubview:_leftTopKnob];
        [self addSubview:_leftBottomKnob];
        [self addSubview:_rightBottomKnob];
        [self addSubview:_rightTopKnob];
     
        _topKnob.delegate = self;
        _leftKnob.delegate = self;
        _bottomKnob.delegate = self;
        _rightKnob.delegate = self;
        _leftTopKnob.delegate = self;
        _leftBottomKnob.delegate = self;
        _rightBottomKnob.delegate = self;
        _rightTopKnob.delegate = self;

        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = NO;
    }

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.leftTopKnob.center = CGPointMake(CGRectGetMinX(self.knobRect),
                                          CGRectGetMinY(self.knobRect));
    self.leftBottomKnob.center = CGPointMake(CGRectGetMinX(self.knobRect),
                                             CGRectGetMaxY(self.knobRect));
    self.rightTopKnob.center = CGPointMake(CGRectGetMaxX(self.knobRect),
                                           CGRectGetMinY(self.knobRect));
    self.rightBottomKnob.center = CGPointMake(CGRectGetMaxX(self.knobRect),
                                              CGRectGetMaxY(self.knobRect));
    self.topKnob.center = CGPointMake((self.leftTopKnob.center.x + self.rightTopKnob.center.x) / 2.0,
                                      self.leftTopKnob.center.y);
    self.leftKnob.center = CGPointMake(self.leftTopKnob.center.x,
                                       (self.leftTopKnob.center.y + self.leftBottomKnob.center.y) / 2.0);
    self.bottomKnob.center = CGPointMake((self.leftBottomKnob.center.x + self.rightBottomKnob.center.x) / 2.0,
                                         self.leftBottomKnob.center.y);
    self.rightKnob.center = CGPointMake(self.rightTopKnob.center.x,
                                        (self.rightTopKnob.center.y + self.rightBottomKnob.center.y) / 2.0);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    [[UIColor.blackColor colorWithAlphaComponent:0.2] set];
    UIRectFill(self.bounds);
    CGContextClearRect(UIGraphicsGetCurrentContext(), self.knobRect);
}

- (void)drawKnob:(PDFDocumentCropOverlayKnob *)knob
{
    CGFloat x = knob.center.x;
    CGFloat y = knob.center.y;
    CGFloat w = knob.frame.size.width;        

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, x, y - w / 4);
    CGContextAddLineToPoint(context, x + w / 4, y);
    CGContextAddLineToPoint(context, x, y + w / 4);
    CGContextAddLineToPoint(context, x - w / 4, y);
    CGContextClosePath(context);

    CGContextSetFillColorWithColor(context, UIColor.whiteColor.CGColor);
    CGContextSetStrokeColorWithColor(context, UIColor.redColor.CGColor);
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)drawKnobAtPoint:(CGPoint)point
{
    CGFloat w = self.leftTopKnob.frame.size.width;

    CGRect rect = CGRectMake(point.x - w / 2, point.y - w / 2, w, w);
    [UIColor.redColor set];
    UIRectFill(rect);
}

#pragma mark -

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return YES;
}

#pragma mark -

- (void)knob:(PDFDocumentCropOverlayKnob *)knob moveTo:(CGPoint)point
{
    CGFloat x = point.x;
    CGFloat y = point.y;
    CGFloat w = knob.frame.size.width;

    CGFloat minX = CGRectGetMinX(self.knobRect);
    CGFloat minY = CGRectGetMinY(self.knobRect);
    CGFloat maxX = CGRectGetMaxX(self.knobRect);
    CGFloat maxY = CGRectGetMaxY(self.knobRect);
       
    
    if (knob == self.leftTopKnob ||
        knob == self.leftKnob ||
        knob == self.leftBottomKnob) {

        minX = x;
        if (minX > self.rightKnob.center.x - w - w) {
            minX = self.rightKnob.center.x - w - w;
        }
        if (minX < CGRectGetMinX(self.bounds)) {
            minX = CGRectGetMinX(self.bounds);
        }
    }
    if (knob == self.leftTopKnob ||
        knob == self.topKnob ||
        knob == self.rightTopKnob) {

        minY = y;
        if (minY > self.bottomKnob.center.y - w - w) {
            minY = self.bottomKnob.center.y - w - w;
        }
        if (minY < CGRectGetMinY(self.bounds)) {
            minY = CGRectGetMinY(self.bounds);
        }
    }
    if (knob == self.rightTopKnob ||
        knob == self.rightKnob ||
        knob == self.rightBottomKnob) {

        maxX = x;
        if (maxX < self.leftKnob.center.x + w + w) {
            maxX = self.leftKnob.center.x + w + w;
        }
        if (maxX > CGRectGetMaxX(self.bounds)) {
            maxX = CGRectGetMaxX(self.bounds);
        }
    }
    if (knob == self.leftBottomKnob ||
        knob == self.bottomKnob ||
        knob == self.rightBottomKnob) {

        maxY = y;
        if (maxY < self.topKnob.center.y + w + w) {
            maxY = self.topKnob.center.y + w + w;
        }
        if (maxY > CGRectGetMaxY(self.bounds)) {
            maxY = CGRectGetMaxY(self.bounds);
        }
    }    

    self.knobRect = CGRectMake(minX, minY,
                               maxX - minX, maxY - minY);
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

#pragma mark -

- (CGRect)cropRect
{
    CGRect rect = self.knobRect;
    rect.origin.x -= CGRectGetMinX(self.bounds);
    rect.origin.y -= CGRectGetMinY(self.bounds);

    CGFloat width = CGRectGetWidth(self.bounds);
            
    CGFloat x = rect.origin.x / width;
    CGFloat y = rect.origin.y / width;
    CGFloat w = rect.size.width / width;
    CGFloat h = rect.size.height / width;

    return CGRectMake(x, y, w, h);
}

- (void)setCropRect:(CGRect)cropRect
{
    if (CGRectEqualToRect(cropRect, CGRectZero)) {
        self.knobRect = self.bounds;
    } else {
        CGFloat width = CGRectGetWidth(self.bounds);
        CGFloat x = cropRect.origin.x * width + CGRectGetMinX(self.bounds);
        CGFloat y = cropRect.origin.y * width + CGRectGetMinY(self.bounds);
        CGFloat w = cropRect.size.width * width;
        CGFloat h = cropRect.size.height * width;
        self.knobRect = CGRectMake(x, y, w, h);
    }

    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)setFrame:(CGRect)frame
{
    CGRect cropRect = self.cropRect;

    [super setFrame:frame];
    self.knobRect = self.bounds;
    self.cropRect = cropRect;
}

@end
