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

@interface FolderDocumentListViewModelTests : XCTestCase

@end

@implementation FolderDocumentListViewModelTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testCreateFolderInCurrentFolderCalled
{
    Folder *fakeFolder = [[Folder alloc] initWithPath:@"fake_folder_path"];
    id fakeFolderMaock = OCMPartialMock(fakeFolder);
    
    OCMStub([fakeFolderMaock createSubFolderWithName:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]).andReturn(nil);
    
    FolderDocumentListViewModel *folderViewModel = [[FolderDocumentListViewModel alloc] initWithFolder:fakeFolder];
    
    NSError *error = nil;
    [folderViewModel createFolderInCurrentFolderWithName:@"fake_name" error:&error];
    
    OCMVerify([fakeFolderMaock createSubFolderWithName:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]);
}

@end
