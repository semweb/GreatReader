//
//  NSArray+GreatReaderAdditions.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (GreatReaderAdditions)
- (NSArray *)grt_map:(id (^)(id))block;
- (NSArray *)grt_filter:(BOOL (^)(id))block;
@end
