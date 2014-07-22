//
//  NSString+GreatReaderAdditionsTests.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/22/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <CommonCrypto/CommonDigest.h>

#import "NSString+GreatReaderAdditions.h"

@interface NSString_GreatReaderAdditionsTests : XCTestCase

@end

@implementation NSString_GreatReaderAdditionsTests

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

- (void)test_grt_md5
{
    NSString *text = @"NSString+GreatReaderAdditionsTests.m";
    NSString *md5 = [text grt_md5];
    XCTAssertEqual(md5.length, CC_MD5_DIGEST_LENGTH * 2);
}

@end
