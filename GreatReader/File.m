//
//  File.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/17.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "File.h"

@interface File ()
@property (nonatomic, strong, readwrite) UIImage *iconImage;
@end

@implementation File

- (id)initWithPath:(NSString *)path
{
    self = [super init];
    if (self) {
        _path = path;
    }
    return self;
}

- (NSString *)name
{
    return self.path.lastPathComponent;
}

@end
