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
#import "NSFileManager+TestAdditions.h"

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
    self.tempDirectory = [self.fileManager createTemporaryTestDirectory];
}

- (void)removeTemporaryTestDirectory
{
    [self.fileManager removeTemporaryTestDirectory:self.tempDirectory];
}

- (NSString *)createSubFolderInTemporaryTestDirectory
{
    return [self.fileManager createSubFolderInTemporaryTestDirectory:self.tempDirectory];
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

- (void)testFolderFilesContainsOneSubFolder
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

- (void)testCreateSubFolder
{
    NSString *testSubFolderName = @"Test Sub Folder";
    
    Folder *folder = [[Folder alloc] initWithPath:self.tempDirectory store:nil];
    [folder load];
    
    Folder *subFolder = [folder createSubFolderWithName:testSubFolderName error:nil];
    
    XCTAssertNotNil(subFolder, @"Created sub folder must not be nil");
    XCTAssertTrue([subFolder isKindOfClass:[Folder class]], @"Created sub folder must have right class");
    XCTAssertTrue([self.fileManager fileExistsAtPath:subFolder.path], @"Created sub folder must exists in file system");
}

- (void)testFolderContainsFileOnSimplePath
{
    Folder *fakeFolder = [[Folder alloc] initWithPath:@"fake_folder_path" store:nil];
    
    File *fakeFile = [[File alloc] initWithPath:@"fake_folder_path/file.ext"];
    
    XCTAssertTrue([fakeFolder containsFile:fakeFile], @"Folder must contain file on simple path");
}

- (void)testFolderContainsFileInOneOfSubFolders
{
    Folder *fakeFolder = [[Folder alloc] initWithPath:@"fake_folder_path" store:nil];
    
    File *fakeFile = [[File alloc] initWithPath:@"fake_folder_path/sub_folder/sub_folder/file.ext"];
    
    XCTAssertTrue([fakeFolder containsFile:fakeFile], @"Folder must contain file in one of sub folders");
}

- (void)testFolderContainsFileOnPathWithDoubleSlashes
{
    Folder *fakeFolder = [[Folder alloc] initWithPath:@"fake_root_folder_name/fake_folder_name" store:nil];
    
    File *fakeFile = [[File alloc] initWithPath:@"fake_root_folder_name//fake_folder_name//file.ext"];
    
    XCTAssertTrue([fakeFolder containsFile:fakeFile], @"Folder must contain file on path with double slashes");
}

- (void)testDeleteFolder
{
    NSString *subFolderPath = [self createSubFolderInTemporaryTestDirectory];
    
    Folder *folder = [[Folder alloc] initWithPath:subFolderPath store:nil];
    
    NSError *error = nil;
    BOOL success = [folder deleteWithPossibleError:&error];
    
    XCTAssertTrue(success, @"Delete folder method must return true");
    XCTAssertFalse([self.fileManager fileExistsAtPath:subFolderPath], @"Folder must be deleted");
}

- (void)testFolderDeletedNotificationPosted
{
    Folder *fakeFolder = [[Folder alloc] initWithPath:@"fake_folder_path" store:nil];
    
    id fileManagerClassMock = OCMClassMock([NSFileManager class]);
    OCMStub([fileManagerClassMock removeItemAtPath:fakeFolder.path error:((NSError *__autoreleasing *)[OCMArg anyPointer])]).andReturn(YES);
    
    id observerMock = OCMObserverMock();
    [[NSNotificationCenter defaultCenter] addMockObserver:observerMock name:FolderDeletedNotification object:fakeFolder];
    [[observerMock expect] notificationWithName:FolderDeletedNotification object:fakeFolder];
    
    NSError *error = nil;
    [fakeFolder deleteWithPossibleError:&error];
    
    OCMVerifyAll(observerMock);
    
    [[NSNotificationCenter defaultCenter] removeObserver:observerMock];
    [fileManagerClassMock stopMocking];
}

- (void)testFindSuperFolder
{
    NSString *fakeSuperFolderPath = @"fake_super_folder_path";
    NSString *fakeCurrentFolderPath = [fakeSuperFolderPath stringByAppendingPathComponent:@"fake_folder_name"];
    
    Folder *fakeCurrentFolder = [[Folder alloc] initWithPath:fakeCurrentFolderPath store:nil];
    
    Folder *superFolder = [fakeCurrentFolder findSuperFolder];
    
    XCTAssertTrue([superFolder.path isEqualToString:fakeSuperFolderPath], @"Folder must find super folder");
}

@end
