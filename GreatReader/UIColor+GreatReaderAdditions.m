//
//  UIColor+GreatReaderAdditions.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 4/14/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "UIColor+GreatReaderAdditions.h"

@implementation UIColor (GreatReaderAdditions)

+ (UIColor *)grt_defaultTintColor
{
    static dispatch_once_t onceToken;
    static UIColor *tintColor = nil;
    dispatch_once(&onceToken, ^{
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        tintColor = toolbar.tintColor;
    });
    return tintColor;
}

+ (UIColor *)grt_defaultBlackTintColor
{
    static dispatch_once_t onceToken;
    static UIColor *bTintColor = nil;
    dispatch_once(&onceToken, ^{
        UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        toolbar.barStyle = UIBarStyleBlack;
        bTintColor = toolbar.tintColor;
    });
    return bTintColor;    
}

@end
