//
//  PDFDocumentTests.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 6/16/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSFileManager+GreatReaderAdditions.h"
#import "NSFileManager+TestAdditions.h"
#import "PDFDocument.h"

@interface PDFDocument ()
- (NSString *)imagePath;
@end

@interface PDFDocumentTests : XCTestCase
@property (nonatomic, strong) PDFDocument *document;
@property (nonatomic, strong) NSFileManager *fileManager;
@end

@implementation PDFDocumentTests

- (void)setUp
{
    [super setUp];

    NSString *resourcePath = [[NSBundle bundleForClass:[self class]]
                                 pathForResource:@"Test"
                                          ofType:@"pdf"];
    NSString *path = [[NSFileManager grt_documentsPath] stringByAppendingPathComponent:@"Test.pdf"];
    self.fileManager = [NSFileManager new];
    [self.fileManager copyItemAtPath:resourcePath toPath:path error:NULL];
    self.document = [[PDFDocument alloc] initWithPath:path];
}

- (void)tearDown
{
    [self.fileManager removeItemAtPath:self.document.path error:nil];
    
    self.document = nil;
    self.fileManager = nil;
    
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

- (void)testMovingPDFDocumentToAnotherDirectory
{
    NSString *temporaryDirectoryPath = [self.fileManager createTemporaryTestDirectory];
    
    NSString *oldDocumentPath = [self.document.path copy];
    NSString *oldImagePath = [self.document.imagePath copy];
    
    // wait in order to be sure what thumbnail image is generated
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
    
    [self.document moveToDirectory:temporaryDirectoryPath error:nil];
    
    XCTAssertNotEqual(self.document.path, oldDocumentPath, @"PDF document must be moved to new folder");
    XCTAssertTrue([self.fileManager fileExistsAtPath:self.document.path], @"PDF document must exists at new path in file system");
    
    XCTAssertNotEqual(self.document.imagePath, oldImagePath, @"Thumbnail image related to PDF document must be moved to new place in caches");
    XCTAssertTrue([self.fileManager fileExistsAtPath:self.document.imagePath], @"Thumbnail image related to PDF document must exists at new path in file system");
    
    [self.fileManager removeTemporaryTestDirectory:temporaryDirectoryPath];
}

@end
