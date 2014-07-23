//
//  PDFDocumentCropTests.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PDFDocumentCrop.h"

@interface PDFDocumentCropTests : XCTestCase

@end

@implementation PDFDocumentCropTests

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

- (void)testEncodeAndDecode
{
    PDFDocumentCrop *crop = [PDFDocumentCrop new];
    crop.oddCropRect = CGRectMake(0, 0, 100, 100);
    crop.evenCropRect = CGRectMake(10, 10, 80, 80);
    crop.mode = PDFDocumentCropModeNone;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:crop];
    PDFDocumentCrop *decodedCrop = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertTrue(crop != decodedCrop);
    XCTAssertTrue(CGRectEqualToRect(crop.oddCropRect, decodedCrop.oddCropRect));
    XCTAssertTrue(CGRectEqualToRect(crop.evenCropRect, decodedCrop.evenCropRect));    
    XCTAssertTrue(crop.mode == decodedCrop.mode);
}

- (void)testCropRectAtPage
{
    PDFDocumentCrop *crop = [PDFDocumentCrop new];
    crop.oddCropRect = CGRectMake(0, 0, 100, 100);
    crop.evenCropRect = CGRectMake(10, 10, 80, 80);
    crop.mode = PDFDocumentCropModeNone;

    XCTAssertTrue(CGRectEqualToRect([crop cropRectAtPage:0], crop.evenCropRect));
    XCTAssertTrue(CGRectEqualToRect([crop cropRectAtPage:2], crop.evenCropRect));
    XCTAssertTrue(CGRectEqualToRect([crop cropRectAtPage:10000], crop.evenCropRect));
    XCTAssertTrue(CGRectEqualToRect([crop cropRectAtPage:333], crop.oddCropRect));    
}

- (void)testEnabled
{
    PDFDocumentCrop *crop = [PDFDocumentCrop new];

    // initial true
    XCTAssertTrue(crop.enabled);

    crop.mode = PDFDocumentCropModeNone;
    XCTAssertFalse(crop.enabled);

    crop.mode = PDFDocumentCropModeSame;
    XCTAssertTrue(crop.enabled);    
}

@end
