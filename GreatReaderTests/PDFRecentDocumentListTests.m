//
//  PDFRecentDocumentListTests.m
//  GreatReader
//
//  Created by Malmygin Anton on 12.12.15.
//  Copyright © 2015 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#import "Folder.h"
#import "PDFRecentDocumentList.h"

@interface PDFRecentDocumentList ()
- (void)folderDeleted:(NSNotification *)notification;
@end

@interface PDFRecentDocumentListTests : XCTestCase

@end

@implementation PDFRecentDocumentListTests

#pragma mark - SetUp / TearDown

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

#pragma mark - Tests

- (void)testFolderDeletedNotificationObserved
{
    PDFRecentDocumentList *fakePDFRecentDocumentList = [[PDFRecentDocumentList alloc] initWithStore:nil];
    
    NSNotification *folderDeletedNotification = [NSNotification notificationWithName:FolderDeletedNotification object:nil];
    
    id fakePDFRecentDocumentListMock = OCMPartialMock(fakePDFRecentDocumentList);
    OCMStub([fakePDFRecentDocumentListMock folderDeleted:folderDeletedNotification]);
    
    [[NSNotificationCenter defaultCenter] postNotification:folderDeletedNotification];
    
    OCMVerify([fakePDFRecentDocumentListMock folderDeleted:folderDeletedNotification]);
}

@end
