//
//  PDFDocumentInfoTests.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <KVOController/FBKVOController.h>

#import "PDFDocument.h"
#import "PDFDocumentInfo.h"

@interface PDFDocumentInfoTests : XCTestCase

@end

@implementation PDFDocumentInfoTests

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

- (void)testInfo
{
    NSString *resourcePath = [[NSBundle bundleForClass:self.class]
                                 pathForResource:@"OutlineTests"
                                          ofType:@"pdf"];
    PDFDocument *document = [[PDFDocument alloc] initWithPath:resourcePath];
    PDFDocumentInfo *info = [[PDFDocumentInfo alloc] initWithDocument:document];
    FBKVOController *kvoController = [FBKVOController controllerWithObserver:self];
    __block NSUInteger count = 0;
    [kvoController observe:info
                   keyPath:@"pageDescription"
                   options:0
                     block:^(id tests, id info, NSDictionary *change) {
        count++; 
    }];

    // test sectionTitle
    [document goTo:2 addHistory:NO];
    XCTAssertTrue([info.sectionTitle isEqualToString:@"Section2"]);
    [document goTo:1 addHistory:NO];
    XCTAssertTrue([info.sectionTitle isEqualToString:@"Section1"]);
    [document goTo:3 addHistory:NO];
    XCTAssertTrue([info.sectionTitle isEqualToString:@"Section3"]);

    // test pageDescription is observable
    XCTAssertTrue(count == 3);
}

@end
