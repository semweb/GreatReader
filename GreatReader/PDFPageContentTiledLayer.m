//
//  PDFPageContentTiledLayer.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/12.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFPageContentTiledLayer.h"

@implementation PDFPageContentTiledLayer

+ (CFTimeInterval)fadeDuration
{
    return 0.001;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.levelsOfDetail = 16;
        self.levelsOfDetailBias = 16 - 1;
        self.tileSize = CGSizeMake(4096, 4096);
    }
    return self;
}

@end
