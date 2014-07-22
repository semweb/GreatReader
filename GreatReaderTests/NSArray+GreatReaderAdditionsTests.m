//
//  NSArray+GreatReaderAdditionsTests.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/22/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSArray+GreatReaderAdditions.h"

@interface NSArray_GreatReaderAdditionsTests : XCTestCase

@end

@implementation NSArray_GreatReaderAdditionsTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test_grt_map
{
    NSArray *list = @[@1, @2, @3];

    // identity
    NSArray *result = [list grt_map:^(NSNumber *num) {
        return num;
    }];
    XCTAssertTrue([list isEqual:result]);

    // double
    NSArray *result2 = [list grt_map:^(NSNumber *num) {
        return @([num integerValue] * 2);
    }];
    NSArray *expectation2 = @[@2, @4, @6];
    XCTAssertTrue([result2 isEqual:expectation2]);

    // return nil
    NSArray *result3 = [list grt_map:^(NSNumber *num) {
        return [num integerValue] == 1 ? nil : num;
    }];
    NSArray *expectation3 = @[@2, @3];
    XCTAssertTrue([result3 isEqual:expectation3]);
}

- (void)test_grt_filter
{
    NSArray *list = @[@1, @2, @3];

    // odd
    NSArray *result1 = [list grt_filter:^(NSNumber *num) {
        return (BOOL)([num integerValue] % 2 != 0);
    }];
    NSArray *expectation1 = @[@1, @3];
    XCTAssertTrue([result1 isEqual:expectation1]);

    // even
    NSArray *result2 = [list grt_filter:^(NSNumber *num) {
        return (BOOL)([num integerValue] % 2 == 0);
    }];
    NSArray *expectation2 = @[@2];
    XCTAssertTrue([result2 isEqual:expectation2]);
}

@end
