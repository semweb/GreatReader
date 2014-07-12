//
//  PDFDocumentBackForwardListTests.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/12/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PDFDocumentBackForwardList.h"

@interface PDFDocumentBackForwardListTests : XCTestCase

@end

@implementation PDFDocumentBackForwardListTests

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

- (void)testGoBackForward
{
    PDFDocumentBackForwardList *list = [[PDFDocumentBackForwardList alloc]
                                           initWithCurrentPage:10];

    // (10)
    XCTAssertTrue(list.currentPage == 10, @"");
    XCTAssertTrue(!list.canGoBack, @"");
    XCTAssertTrue(!list.canGoForward, @"");

    // (11)
    [list goTo:11 addHistory:NO];
    XCTAssertTrue(list.currentPage == 11, @"");
    XCTAssertTrue(!list.canGoBack, @"");
    XCTAssertTrue(!list.canGoForward, @"");
    // (12)
    [list goTo:12 addHistory:NO];
    XCTAssertTrue(list.currentPage == 12, @"");
    XCTAssertTrue(!list.canGoBack, @"");
    XCTAssertTrue(!list.canGoForward, @"");

    // 12, (100)
    [list goTo:100 addHistory:YES];
    XCTAssertTrue(list.currentPage == 100, @"");
    XCTAssertTrue(list.canGoBack, @"");
    XCTAssertTrue(!list.canGoForward, @"");

    // (12), 100
    [list goBack];
    XCTAssertTrue(list.currentPage == 12, @"");
    XCTAssertTrue(!list.canGoBack, @"");
    XCTAssertTrue(list.canGoForward, @"");

    // 12, (100)
    [list goForward];
    XCTAssertTrue(list.currentPage == 100, @"");
    XCTAssertTrue(list.canGoBack, @"");
    XCTAssertTrue(!list.canGoForward, @"");

    // 12, 100, 150, 5, (200)
    [list goTo:150 addHistory:YES];
    [list goTo:5 addHistory:YES];
    [list goTo:200 addHistory:YES];
    XCTAssertTrue(list.currentPage == 200, @"");
    XCTAssertTrue(list.canGoBack, @"");

    // 12, 100, 150, (5), 200
    [list goBack];
    XCTAssertTrue(list.currentPage == 5, @"");
    XCTAssertTrue(list.canGoBack, @"");

    // 12, 100, (150), 5, 200    
    [list goBack];
    XCTAssertTrue(list.currentPage == 150, @"");
    XCTAssertTrue(list.canGoBack, @"");

    // 12, (100), 150, 5, 200
    [list goBack];
    XCTAssertTrue(list.currentPage == 100, @"");
    XCTAssertTrue(list.canGoBack, @"");

    // (12), 100, 150, 5, 200
    [list goBack];
    XCTAssertTrue(list.currentPage == 12, @"");
    XCTAssertTrue(!list.canGoBack, @"");

    // 12, 100, 150, 5, (201)
    [list goForward];
    [list goForward];
    [list goForward];
    [list goForward];
    [list goTo:201 addHistory:NO];
    XCTAssertTrue(list.currentPage == 201, @"");
    XCTAssertTrue(list.canGoBack, @"");
    XCTAssertTrue(!list.canGoForward, @"");

    // 201, (50)
    [list goTo:50 addHistory:YES];
    XCTAssertTrue(list.currentPage == 50, @"");
    XCTAssertTrue(list.canGoBack, @"");
    XCTAssertTrue(!list.canGoForward, @"");    
}

@end
