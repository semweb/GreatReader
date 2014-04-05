//
//  GRTArrayController.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 4/2/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "GRTArrayController.h"

@interface GRTArrayController ()
@property (nonatomic, strong, readwrite) NSArray *array;
@end

@implementation GRTArrayController

- (id)initWithArray:(NSArray *)array
{
    self = [super init];
    if (self) {
        _array = array;
    }
    return self;
}

- (void)addObject:(id)object
{
    [[self proxy] addObject:object];
}

- (void)removeObject:(id)object
{
    [[self proxy] removeObject:object];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index
{
    [[self proxy] insertObject:object atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [[self proxy] removeObjectAtIndex:index];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [[self proxy] objectAtIndex:index];
}

- (BOOL)containsObject:(id)object
{
    return [self.array containsObject:object];
}

- (NSUInteger)indexOfObject:(id)object
{
    return [self.array indexOfObject:object];
}

- (id)proxy
{
    return [self mutableArrayValueForKeyPath:@"array"];
}

- (NSUInteger)count
{
    return self.array.count;
}

@end
