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
@end

@implementation PDFPageContentView

- (void)dealloc
{
    // dealloc後にdrawInContextが呼ばれてしまわないように
    // tileViewのdeallocでやると、間に合わないので、ここで。
    self.tileView.layer.delegate = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect tileFrame = frame;
        tileFrame.origin.x = 0;
        tileFrame.origin.y = 0;
        _tileView = [[PDFPageContentTileView alloc] initWithFrame:tileFrame];
        [self addSubview:_tileView];
    }
    return self;
}

- (void)setPage:(PDFPage *)page
{
    _page = page;
    self.tileView.page = page;
}

@end
