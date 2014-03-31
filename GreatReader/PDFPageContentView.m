//
//  PDFPageContentView.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/12.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFPageContentView.h"

#import <QuartzCore/QuartzCore.h>

#import "PDFPage.h"
#import "PDFPageContentTiledLayer.h"
#import "PDFPageLoopeView.h"
#import "PDFRenderingCharacter.h"

@interface PDFPageContentTileView : UIView
@property (nonatomic, strong) PDFPage *page;
@end

@implementation PDFPageContentTileView

+ (Class)layerClass
{
    return [PDFPageContentTiledLayer class];
}

- (void)drawLayer:(CALayer*)layer inContext:(CGContextRef)context
{
    [self.page drawInRect:self.bounds inContext:context cropping:YES];
}

@end

@interface PDFPageContentView ()
@property (nonatomic, strong) PDFPageContentTileView *tileView;
@property (nonatomic, strong) NSMutableArray *selectionViews;
@property (nonatomic, strong) PDFPageLoopeView *loopeView;
@end

@implementation PDFPageContentView

- (void)dealloc
{
    // dealloc後にdrawInContextが呼ばれてしまわないように
    // tileViewのdeallocでやると、間に合わないので、ここで。
    self.tileView.layer.delegate = nil;
    [self removeObserver:self forKeyPath:@"page.selectedFrames"];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect tileFrame = frame;
        tileFrame.origin.x = 0;
        tileFrame.origin.y = 0;
        _tileView = [[PDFPageContentTileView alloc] initWithFrame:tileFrame];
        _tileView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_tileView];

        _selectionViews = [NSMutableArray array];
        [self addObserver:self
               forKeyPath:@"page.selectedFrames"
                  options:0
                  context:NULL];
        
        _loopeView = [[PDFPageLoopeView alloc] init];
    }
    return self;
}

- (void)setPage:(PDFPage *)page
{
    _page = page;
    self.tileView.page = page;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self updateSelectionViews];   
}

- (void)updateSelectionViews
{
    [self.selectionViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.selectionViews removeAllObjects];

    CGFloat scale = self.scale;
    CGRect rect = CGRectZero;
    NSMutableArray *lines = NSMutableArray.array;
    for (NSValue *v in self.page.selectedFrames) {
        CGRect r = v.CGRectValue;
        CGRect scaleFrame = CGRectMake(CGRectGetMinX(r) * scale,
                                       CGRectGetMinY(r) * scale,
                                       CGRectGetWidth(r) * scale,
                                       CGRectGetHeight(r) * scale);
        if (CGRectEqualToRect(rect, CGRectZero)) {
            rect = scaleFrame;
            [lines addObject:[NSValue valueWithCGRect:rect]];            
        } else if (fabs(CGRectGetMinY(rect) - CGRectGetMinY(scaleFrame)) > CGRectGetHeight(scaleFrame) / 2.0) {
            rect = scaleFrame;
            [lines addObject:[NSValue valueWithCGRect:rect]];            
        } else {
            rect = CGRectUnion(rect, scaleFrame);
            [lines replaceObjectAtIndex:lines.count - 1
                             withObject:[NSValue valueWithCGRect:rect]];
        }
    }

    for (NSValue *line in lines) {
        CGRect r = line.CGRectValue;
        UIView *v = [[UIView alloc] initWithFrame:r];
        v.backgroundColor = [UIColor colorWithRed:10 / 255.0
                                            green:90 / 255.0
                                             blue:160 / 255.0
                                            alpha:0.2];
        [self addSubview:v];
        [self.selectionViews addObject:v];
    }
}

- (CGFloat)scale
{
    CGAffineTransform invertTransform = CGAffineTransformInvert(self.transform);
    CGRect f = CGRectApplyAffineTransform(self.frame, invertTransform);
    return CGRectGetWidth(f) / CGRectGetWidth(self.page.rect);
}

- (CGRect)selectionFrame
{
    if (!self.selectionViews) {
        return CGRectZero;
    } else {
        CGRect rect = [[self.selectionViews firstObject] frame];
        for (int i = 1; i < self.selectionViews.count; i++) {
            CGRect r = [self.selectionViews[i] frame];
            rect = CGRectUnion(rect, r); 
        }
        return rect;
    }
}

- (void)showLoopeAtPoint:(CGPoint)point
{
    if (!self.loopeView.superview) {
        [self.window addSubview:self.loopeView];
    }
    point = [self convertPoint:point toView:nil];
    self.loopeView.center = CGPointMake(roundf(point.x), roundf(point.y));
    UIGraphicsBeginImageContextWithOptions(self.loopeView.frame.size, NO, 2.0);  {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGPoint p = [self convertPoint:self.loopeView.frame.origin
                              fromView:nil];
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformTranslate(transform, -p.x, -p.y);
        transform = CGAffineTransformConcat(transform, self.transform);
        CGContextConcatCTM(context, transform);
        [self.layer renderInContext:context];
        self.loopeView.image = UIGraphicsGetImageFromCurrentImageContext();
    } UIGraphicsEndImageContext();

    self.loopeView.center =
            CGPointMake(self.loopeView.center.x,
                        self.loopeView.center.y - self.loopeView.frame.size.height / 2.0 - 20);
}

- (void)hideLoope
{
    [self.loopeView removeFromSuperview];
}

@end
