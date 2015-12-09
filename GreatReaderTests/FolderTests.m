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

- (NSString *)createSubFolderInTemporaryTestDirectory
{
    NSString *subFolderName = @"Test Folder";
    NSString *subFolderPath = [self.tempDirectory stringByAppendingPathComponent:subFolderName];
    [self.fileManager createDirectoryAtPath:subFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    
    return subFolderPath;
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

- (void)testFolderFilesContainsOneSubFodler
{
    NSString *subFolderPath = [self createSubFolderInTemporaryTestDirectory];
    
    Folder *folder = [[Folder alloc] initWithPath:self.tempDirectory store:nil];
    [folder load];
    
    XCTAssertEqual([folder.files count], 1, @"Folder files must contains only one folder item");
    
    id subFolder = [folder.files firstObject];
    XCTAssertTrue([subFolder isKindOfClass:[Folder class]], @"Folder item must be instance of Folder class");
    
    XCTAssertTrue([((Folder *)subFolder).path isEqualToString:subFolderPath], @"Sub folder path must be consistent");
}

- (void)testDocumentStorePropagatesToSubFolder
{
    [self createSubFolderInTemporaryTestDirectory];
    
    PDFDocumentStore *documentStore = [[PDFDocumentStore alloc] init];
    
    Folder *folder = [[Folder alloc] initWithPath:self.tempDirectory store:documentStore];
    [folder load];
    
    Folder *subFolder = [folder.files firstObject];
    
    XCTAssertEqual(subFolder.store, documentStore, @"Sub folder must points to same document store");
}

@end
