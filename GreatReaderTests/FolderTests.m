//
//  FolderTests.m
//  GreatReader
//
//  Created by Malmygin Anton on 09.12.15.
//  Copyright © 2015 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#import "Folder.h"
#import "PDFDocument+TestAdditions.h"
#import "PDFDocumentStore.h"

@interface FolderTests : XCTestCase
@property (nonatomic, strong) NSFileManager *fileManager;
@property (nonatomic, strong) NSString *tempDirectory;
@end

@implementation FolderTests

#pragma mark - SetUp / TearDown

- (void)setUp
{
    [super setUp];
    
    self.fileManager = [[NSFileManager alloc] init];

    [self createTemporaryTestDirectory];
}

- (void)tearDown
{
    [self removeTemporaryTestDirectory];
    
    self.tempDirectory = nil;
    self.fileManager = nil;
    
    [super tearDown];
}

#pragma mark - Helpers

- (void)createTemporaryTestDirectory
{
    self.tempDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    [self.fileManager createDirectoryAtPath:self.tempDirectory withIntermediateDirectories:YES attributes:nil error:nil];
}

- (void)removeTemporaryTestDirectory
{
    [self.fileManager removeItemAtPath:self.tempDirectory error:nil];
}

#pragma mark - Tests

- (void)testFolderFilesContainsOnePDFDocument
{
    NSString *resourcePath = [[NSBundle bundleForClass:[self class]]
                              pathForResource:@"Test"
                              ofType:@"pdf"];
    NSString *path = [self.tempDirectory stringByAppendingPathComponent:@"Test.pdf"];
    [self.fileManager copyItemAtPath:resourcePath toPath:path error:nil];
    
    PDFDocument *document = [[PDFDocument alloc] initWithPath:path];
    
    id documentStoreMock = OCMClassMock([PDFDocumentStore class]);
    OCMStub([documentStoreMock documentAtPath:[OCMArg any]]).andReturn(document);
    
    Folder *folder = [[Folder alloc] initWithPath:self.tempDirectory store:documentStoreMock];
    [folder load];
    
    XCTAssertEqual([folder.files count], 1, @"Folder must contains only one file");
    XCTAssertTrue([folder.files containsObject:document], @"Folder files must contains test PDF document");
}

@end
