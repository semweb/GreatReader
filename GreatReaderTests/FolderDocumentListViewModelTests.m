//
//  FolderDocumentListViewModelTests.m
//  GreatReader
//
//  Created by Malmygin Anton on 11.12.15.
//  Copyright © 2015 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#import "FolderDocumentListViewModel.h"
#import "Folder.h"
#import "RootFolder.h"
#import "PDFDocumentStore.h"
#import "PDFDocument.h"

@interface FolderDocumentListViewModelTests : XCTestCase

@end

@implementation FolderDocumentListViewModelTests

#pragma mark - SetUp / TearDown

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

#pragma mark - Tests

#pragma mark SubFolder

- (void)testCreateSubFolderCalledOnFolder
{
    Folder *fakeFolder = [[Folder alloc] initWithPath:@"fake_folder_path" store:nil];
    id fakeFolderMock = OCMPartialMock(fakeFolder);
    
    OCMStub([fakeFolderMock createSubFolderWithName:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]).andReturn(nil);
    
    FolderDocumentListViewModel *folderViewModel = [[FolderDocumentListViewModel alloc] initWithFolder:fakeFolder];
    
    NSError *error = nil;
    [folderViewModel createFolderInCurrentFolderWithName:@"fake_name" error:&error];
    
    OCMVerify([fakeFolderMock createSubFolderWithName:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]);
}

#pragma mark Folder Title

- (void)testRightTitleProvidedForRootFolder
{
    RootFolder *fakeRootFolder = [[RootFolder alloc] initWithPath:@"fake_root_folder_path" store:nil];
    
    FolderDocumentListViewModel *folderViewModel = [[FolderDocumentListViewModel alloc] initWithFolder:fakeRootFolder];
    
    XCTAssertTrue([folderViewModel.title isEqualToString:LocalizedString(@"home.all-documents")], @"ViewModel must provide right localaized title for root folder");
}

- (void)testRightTitleProvidedForOrdinaryFolder
{
    Folder *fakeFolder = [[Folder alloc] initWithPath:@"fake_folder_path" store:nil];
    
    FolderDocumentListViewModel *folderViewModel = [[FolderDocumentListViewModel alloc] initWithFolder:fakeFolder];
    
    XCTAssertTrue([folderViewModel.title isEqualToString:fakeFolder.name], @"ViewModel must provide right title for ordinary folder");
}

#pragma mark Move Documents

- (void)testMoveDocumentsCalledOnPDFDocumentStore
{
    PDFDocumentStore *fakePDFDocumentStore = [[PDFDocumentStore alloc] init];
    
    Folder *fakeFolder = [[Folder alloc] initWithPath:@"fake_folder_path" store:fakePDFDocumentStore];
    
    id fakePDFDocumentStoreMock = OCMPartialMock(fakePDFDocumentStore);
    OCMStub([fakePDFDocumentStoreMock moveDocuments:[OCMArg any] toFolder:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]).andReturn(YES);
    
    FolderDocumentListViewModel *folderViewModel = [[FolderDocumentListViewModel alloc] initWithFolder:fakeFolder];
    
    NSError *error = nil;
    [folderViewModel moveDocuments:nil toFolder:nil error:&error];
    
    OCMVerify([fakePDFDocumentStoreMock moveDocuments:[OCMArg any] toFolder:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]);
}

#pragma mark Create Folder and Move Documents

- (void)testCreateFolderAndMoveDocumentsCallsCreateFolder
{
    FolderDocumentListViewModel *folderViewModel = [[FolderDocumentListViewModel alloc] initWithFolder:nil];
    
    id folderViewModelMock = OCMPartialMock(folderViewModel);
    OCMStub([folderViewModelMock createFolderInCurrentFolderWithName:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]);
    
    NSError *error = nil;
    [folderViewModel createFolderInCurrentFolderWithName:nil andMoveDocuments:nil error:&error];
    
    OCMVerify([folderViewModelMock createFolderInCurrentFolderWithName:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]);
}

- (void)testCreateFolderAndMoveDocumentsCallsMoveDocuments
{
    FolderDocumentListViewModel *folderViewModel = [[FolderDocumentListViewModel alloc] initWithFolder:nil];
    
    id folderMock = OCMClassMock([Folder class]);
    
    id folderViewModelMock = OCMPartialMock(folderViewModel);
    OCMStub([folderViewModelMock createFolderInCurrentFolderWithName:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]).andReturn(folderMock);
    
    OCMStub([folderViewModelMock moveDocuments:[OCMArg any] toFolder:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]);
    
    NSError *error = nil;
    [folderViewModel createFolderInCurrentFolderWithName:nil andMoveDocuments:nil error:&error];
    
    OCMVerify([folderViewModelMock moveDocuments:[OCMArg any] toFolder:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]);
}

#pragma mark Find Super Folder and Move Documents

- (void)testFindSuperFolderAndMoveDocumentsCallsFindSuperFolderOnCurrentFolder
{
    Folder *fakeFolder = [[Folder alloc] initWithPath:@"fake_folder_path" store:nil];
    
    FolderDocumentListViewModel *folderViewModel = [[FolderDocumentListViewModel alloc] initWithFolder:fakeFolder];
    
    id fakeFolderMock = OCMPartialMock(fakeFolder);
    OCMStub([fakeFolderMock findSuperFolder]);
    
    NSError *error = nil;
    [folderViewModel findSuperFolderAndMoveDocuments:nil error:&error];
    
    OCMVerify([fakeFolderMock findSuperFolder]);
}

- (void)testFindSuperFolderAndMoveDocumentsCallsMoveDocumentsToFolder
{
    Folder *fakeFolder = [[Folder alloc] initWithPath:@"fake_folder_path" store:nil];
    
    FolderDocumentListViewModel *folderViewModel = [[FolderDocumentListViewModel alloc] initWithFolder:fakeFolder];
    
    id folderMock = OCMClassMock([Folder class]);
    
    id fakeFolderMock = OCMPartialMock(fakeFolder);
    OCMStub([fakeFolderMock findSuperFolder]).andReturn(folderMock);
    
    id folderViewModelMock = OCMPartialMock(folderViewModel);
    OCMStub([folderViewModelMock moveDocuments:[OCMArg any] toFolder:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]);
    
    NSError *error = nil;
    [folderViewModel findSuperFolderAndMoveDocuments:nil error:&error];
    
    OCMVerify([folderViewModelMock moveDocuments:[OCMArg any] toFolder:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]);
}

#pragma mark Has Folder in Documents

- (void)testCheckIfHasFolderInDocumentsReturnFalseForDocumentsWithoutFolder
{
    PDFDocument *fakeFirstDocument = [[PDFDocument alloc] initWithPath:@"fake_first_document_path"];
    PDFDocument *fakeSecondDocument = [[PDFDocument alloc] initWithPath:@"fake_second_document_path"];
    NSArray *documents = @[fakeFirstDocument, fakeSecondDocument];

    FolderDocumentListViewModel *folderViewModel = [[FolderDocumentListViewModel alloc] initWithFolder:nil];
    
    XCTAssertFalse([folderViewModel checkIfHasFolderInDocuments:documents], @"Must return false for two PDF documents");
}

- (void)testCheckIfHasFolderInDocumentsReturnTrueForDocumentsWithFolder
{
    PDFDocument *fakeDocument = [[PDFDocument alloc] initWithPath:@"fake_document_path"];
    Folder *fakeFolder = [[Folder alloc] initWithPath:@"fake_folder_path" store:nil];
    NSArray *documents = @[fakeDocument, fakeFolder];
    
    FolderDocumentListViewModel *folderViewModel = [[FolderDocumentListViewModel alloc] initWithFolder:nil];
    
    XCTAssertTrue([folderViewModel checkIfHasFolderInDocuments:documents], @"Must return true for PDF document and folder");
}

#pragma mark - Type of Current Folder

- (void)testCurrentFolderIsOrdinaryFolder
{
    Folder *fakeFolder = [[Folder alloc] initWithPath:@"fake_folder_path" store:nil];
    
    FolderDocumentListViewModel *folderViewModel = [[FolderDocumentListViewModel alloc] initWithFolder:fakeFolder];
    
    XCTAssertFalse([folderViewModel checkIfCurrentFolderIsRootFolder], @"Current folder must not be RootFolder");
}

- (void)testCurrentFolderIsRootFolder
{
    RootFolder *fakeRootFolder = [[RootFolder alloc] initWithPath:@"fake_root_folder_path" store:nil];
    
    FolderDocumentListViewModel *folderViewModel = [[FolderDocumentListViewModel alloc] initWithFolder:fakeRootFolder];
    
    XCTAssertTrue([folderViewModel checkIfCurrentFolderIsRootFolder], @"Current folder must be RootFolder");
}

@end
