//
//  GRTArrayController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 4/2/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRTArrayController : NSObject
- (id)initWithArray:(NSArray *)array;
- (void)addObject:(id)object;
- (void)removeObject:(id)object;
- (void)insertObject:(id)object atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (id)objectAtIndex:(NSUInteger)index;
- (BOOL)containsObject:(id)object;
- (NSUInteger)indexOfObject:(id)object;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, strong, readonly) NSArray *array;
@end
