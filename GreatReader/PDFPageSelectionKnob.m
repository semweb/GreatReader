//
//  PDFPageSelectionKnob.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/2/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFPageSelectionKnob.h"

@interface PDFPageSelectionKnob ()
@property (nonatomic, assign) CGPoint beganPoint;
@end

@implementation PDFPageSelectionKnob

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.exclusiveTouch = YES;
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    self.beganPoint = [touch locationInView:self];
    self.point = [self convertPoint:self.beganPoint toView:self.superview];    
    [self sendActionsForControlEvents:UIControlEventTouchDown];
    return YES;
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    if (touch.phase == UITouchPhaseCancelled) {
        [self sendActionsForControlEvents:UIControlEventTouchCancel];
    } else if (CGRectContainsPoint(self.bounds, [touch locationInView:self])) {
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    } else {
        [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
    }
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint point = [touch locationInView:self];
    CGPoint origin = self.origin;
    CGPoint offset = CGPointMake(self.beganPoint.x - origin.x,
                                 self.beganPoint.y - origin.y);
    point = CGPointMake(point.x - offset.x,
                        point.y - offset.y);
    
    self.point = [self convertPoint:point toView:self.superview];

    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

- (void)drawRect:(CGRect)rect
{
    [[self tintColor] set];
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    CGFloat x = CGRectGetWidth(self.frame) / 2.0;
    [bezierPath moveToPoint:CGPointMake(x, 0.5)];
    [bezierPath addLineToPoint:CGPointMake(x, CGRectGetHeight(self.frame) - 0.5)];
    [bezierPath stroke];

    CGRect ovalRect = ({
        CGFloat w = CGRectGetWidth(self.frame);
        CGRect f = CGRectMake(0, 0, w, w);
        if (!self.start) {
            f.origin.y = CGRectGetHeight(self.frame) - w;
        }
        f;
    });
    [[UIBezierPath bezierPathWithOvalInRect:ovalRect] fill];
}

#pragma mark -

- (CGPoint)origin
{
    CGFloat selectionHeight = self.frame.size.height - self.frame.size.width;
    CGFloat x = self.frame.size.width / 2.0;
    if (self.start) {
        return CGPointMake(x, selectionHeight / 2.0 + self.frame.size.width);
    } else {
        return CGPointMake(x, selectionHeight / 2.0);
    }
}

#pragma mark -

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    CGRect b = self.bounds;
    b.origin.x -= 20;
    b.origin.y -= 20;
    b.size.width += 40;
    b.size.height += 40;
    return CGRectContainsPoint(b, point);
}

@end
