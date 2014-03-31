//
//  Device.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 4/1/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "Device.h"

BOOL IsPad()
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
}

BOOL IsPhone()
{
    return UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone;
}
