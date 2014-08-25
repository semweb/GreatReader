//
//  NSFileManager+GreatReaderAdditionsTests.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/22/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSFileManager+GreatReaderAdditions.h"

@interface NSFileManager_GreatReaderAdditionsTests : XCTestCase

@end

@implementation NSFileManager_GreatReaderAdditionsTests

- (void)setUp
{
    [super setUp];

    NSFileManager *fm = [NSFileManager new];
    NSString *path = [NSFileManager grt_privateDocumentsPath];
    if ([fm fileExistsAtPath:path]) {
        [fm removeItemAtPath:path error:NULL];
    }
}

- (void)tearDown
{
    [super tearDown];

    NSFileManager *fm = [NSFileManager new];
    NSString *path = [NSFileManager grt_privateDocumentsPath];
    if ([fm fileExistsAtPath:path]) {
        [fm removeItemAtPath:path error:NULL];
    }    
}

- (void)testSpecialDirectoryPaths
{
    NSArray *expectations = @[@"PrivateDocuments",
                              @"Documents",
                              @"Library",
                              @"Caches"];
    NSArray *results = @[[[NSFileManager grt_privateDocumentsPath] lastPathComponent],
                         [[NSFileManager grt_documentsPath] lastPathComponent],
                         [[NSFileManager grt_libraryPath] lastPathComponent],
                         [[NSFileManager grt_cachePath] lastPathComponent]];
    XCTAssertTrue([expectations isEqual:results]);
}

- (void)test_grt_createPrivateDocumentsDirectory
{
    NSFileManager *fm = [NSFileManager new];
    NSString *path = [NSFileManager grt_privateDocumentsPath];
    // file does not exist currently
    XCTAssertFalse([fm fileExistsAtPath:path]);

    // private documents has created
    [fm grt_createPrivateDocumentsDirectory];
    XCTAssertTrue([fm fileExistsAtPath:path]);

    // noop
    [fm grt_createPrivateDocumentsDirectory];
    XCTAssertTrue([fm fileExistsAtPath:path]);    
}

- (void)test_grt_incrementURLIfNecessary
{
    NSFileManager *fm = [NSFileManager new];
    NSString *dirPath = [NSFileManager grt_privateDocumentsPath];
    NSURL *URL = [NSURL fileURLWithPath:[dirPath stringByAppendingPathComponent:@"Dir.pdf"]];

    NSURL *result1 = [fm grt_incrementURLIfNecessary:URL];
    XCTAssertEqualObjects(URL, result1);

    [fm createDirectoryAtURL:URL
 withIntermediateDirectories:YES
                  attributes:nil
                       error:NULL];
    NSURL *result2 = [fm grt_incrementURLIfNecessary:URL];
    NSURL *expectation2 = [NSURL fileURLWithPath:[dirPath stringByAppendingPathComponent:@"Dir-1.pdf"]];
    XCTAssertEqualObjects(result2, expectation2);

    [fm createDirectoryAtURL:result2
 withIntermediateDirectories:YES
                  attributes:nil
                       error:NULL];
    NSURL *result3 = [fm grt_incrementURLIfNecessary:URL];
    NSURL *expectation3 = [NSURL fileURLWithPath:[dirPath stringByAppendingPathComponent:@"Dir-2.pdf"]];
    XCTAssertEqualObjects(result3, expectation3);
}

@end
