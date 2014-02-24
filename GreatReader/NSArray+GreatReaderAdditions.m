//
//  NSArray+GreatReaderAdditions.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "NSArray+GreatReaderAdditions.h"

@implementation NSArray (GreatReaderAdditions)

- (NSArray *)grt_map:(id (^)(id))block
{
    NSMutableArray *newArray = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id item, NSUInteger index, BOOL *stop) {
        id obj = block(item);
        if (obj) {
            [newArray addObject:obj];
        }
    }];
    return newArray;
}

- (NSArray *)grt_filter:(BOOL (^)(id))block
{
    NSMutableArray *newArray = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id item, NSUInteger index, BOOL *stop) {
        if (block(item)) {
            [newArray addObject:item];
        }
    }];
    return newArray;
}

@end
