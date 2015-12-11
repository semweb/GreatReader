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

@end
