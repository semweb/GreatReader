//
//  UIColor+GreatReaderAdditionsTests.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/22/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "UIColor+GreatReaderAdditions.h"

@interface UIColor_GreatReaderAdditionsTests : XCTestCase

@end

@implementation UIColor_GreatReaderAdditionsTests

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

- (void)test_grt_defaultTintColor
{
    UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    UIColor *result = [UIColor grt_defaultTintColor];
    UIColor *expectation = bar.tintColor;
    CGFloat rRed, rGreen, rBlue;
    [result getRed:&rRed green:&rGreen blue:&rBlue alpha:NULL];
    CGFloat eRed, eGreen, eBlue;
    [expectation getRed:&eRed green:&eGreen blue:&eBlue alpha:NULL];
    XCTAssertEqual(rRed, eRed);
    XCTAssertEqual(rGreen, eGreen);
    XCTAssertEqual(rBlue, eBlue);    
}

- (void)test_grt_defaultBlackTintColor
{
    UIToolbar *bar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    bar.barStyle = UIBarStyleBlack;
    UIColor *result = [UIColor grt_defaultBlackTintColor];
    UIColor *expectation = bar.tintColor;
    CGFloat rRed, rGreen, rBlue;
    [result getRed:&rRed green:&rGreen blue:&rBlue alpha:NULL];
    CGFloat eRed, eGreen, eBlue;
    [expectation getRed:&eRed green:&eGreen blue:&eBlue alpha:NULL];
    XCTAssertEqual(rRed, eRed);
    XCTAssertEqual(rGreen, eGreen);
    XCTAssertEqual(rBlue, eBlue);    
}

@end
