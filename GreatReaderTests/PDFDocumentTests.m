//
//  PDFDocumentTests.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 6/16/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSFileManager+GreatReaderAdditions.h"
#import "PDFDocument.h"

@interface PDFDocumentTests : XCTestCase
@property (nonatomic, strong) PDFDocument *document;
@end

@implementation PDFDocumentTests

- (void)setUp
{
    [super setUp];

    NSString *resourcePath = [[NSBundle bundleForClass:[self class]]
                                 pathForResource:@"Test"
                                          ofType:@"pdf"];
    NSString *path = [[NSFileManager grt_documentsPath] stringByAppendingPathComponent:@"Test.pdf"];
    NSFileManager *fm = [NSFileManager new];
    [fm copyItemAtPath:resourcePath toPath:path error:NULL];
    self.document = [[PDFDocument alloc] initWithPath:path];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEncodeAndDecode
{
    NSString *path = [[NSFileManager grt_documentsPath] stringByAppendingPathComponent:@"Document"];
    XCTAssertTrue([NSKeyedArchiver archiveRootObject:self.document toFile:path], @"");
    PDFDocument *doc = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
    XCTAssertTrue([self.document.path isEqual:doc.path], @"");
}

- (void)testWriteAndLoadThumbnailImage
{
    XCTAssertNil(self.document.thumbnailImage, @"");    
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    XCTAssertNotNil(self.document.thumbnailImage, @"");
}

@end
