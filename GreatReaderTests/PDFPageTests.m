//
//  PDFPageTests.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/5/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#import "PDFPage.h"
#import "PDFRenderingCharacter.h"

@interface PDFPageTests : XCTestCase

@end

@implementation PDFPageTests

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

- (void)testNearestCharacterAtPoint
{
    PDFPage *page = PDFPage.new;
    id mock = OCMPartialMock(page);

    NSArray *frames = @[
        [NSValue valueWithCGRect:CGRectMake(0, 0, 50, 50)],
        [NSValue valueWithCGRect:CGRectMake(60, 0, 50, 50)],
        [NSValue valueWithCGRect:CGRectMake(20, 100, 50, 50)],
        [NSValue valueWithCGRect:CGRectMake(200, 200, 50, 50)]
    ];
    NSArray *characters = @[
        PDFRenderingCharacter.new,
        PDFRenderingCharacter.new,
        PDFRenderingCharacter.new,
        PDFRenderingCharacter.new,
    ];
    OCMStub([mock characterFrames]).andReturn(frames);
    OCMStub([mock characters]).andReturn(characters);

    // contains
    XCTAssertEqual(characters[0], [mock nearestCharacterAtPoint:CGPointMake(25, 25)], @"");
    XCTAssertEqual(characters[1], [mock nearestCharacterAtPoint:CGPointMake(85, 25)], @"");
    XCTAssertEqual(characters[2], [mock nearestCharacterAtPoint:CGPointMake(45, 125)], @"");
    XCTAssertEqual(characters[3], [mock nearestCharacterAtPoint:CGPointMake(225, 225)], @"");

    // nearest
    XCTAssertEqual(characters[0], [mock nearestCharacterAtPoint:CGPointMake(54, 25)], @"");

    // distant
    XCTAssertNil([mock nearestCharacterAtPoint:CGPointMake(500, 500)], @"");    
}

@end
