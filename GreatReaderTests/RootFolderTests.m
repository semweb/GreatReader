//
//  RootFolderTests.m
//  GreatReader
//
//  Created by Malmygin Anton on 14.12.15.
//  Copyright © 2015 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "Folder.h"
#import "RootFolder.h"

@interface RootFolderTests : XCTestCase

@end

@implementation RootFolderTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testFindSuperFolderForRootFolderMustReturnNil
{
    RootFolder *fakeRootFolder = [[RootFolder alloc] initWithPath:@"fake_root_folder_path" store:nil];
    
    Folder *superFolder = [fakeRootFolder findSuperFolder];
    
    XCTAssertNil(superFolder, @"RootFolder must not find super folder");
}

@end
