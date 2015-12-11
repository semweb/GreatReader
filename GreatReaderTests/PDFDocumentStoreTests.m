//
//  PDFDocumentStoreTests.m
//  GreatReader
//
//  Created by Malmygin Anton on 11.12.15.
//  Copyright © 2015 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <OCMock/OCMock.h>

#import "PDFDocumentStore.h"
#import "PDFDocument.h"
#import "Folder.h"

@interface PDFDocumentStoreTests : XCTestCase
@property (nonatomic, strong) PDFDocumentStore *pdfDocumentStore;
@property (nonatomic, strong) Folder *fakeFolder;
@end

@implementation PDFDocumentStoreTests

#pragma mark - SetUp / TearDown

- (void)setUp
{
    [super setUp];
    
    self.pdfDocumentStore = [[PDFDocumentStore alloc] init];
    self.fakeFolder = [[Folder alloc] initWithPath:@"fake_folder_path"];
}

- (void)tearDown
{
    self.fakeFolder = nil;
    self.pdfDocumentStore = nil;
    
    [super tearDown];
}

#pragma mark - Helpers

- (void)stubMoveToDirectoryCallForPDFDocumentMock:(PDFDocument *)pdfDocumentMock
{
    [self stubMoveToDirectoryCallForPDFDocumentMock:pdfDocumentMock
                                   andReturnSuccess:YES];
}

- (void)stubMoveToDirectoryCallForPDFDocumentMock:(PDFDocument *)pdfDocumentMock andReturnSuccess:(BOOL)success
{
    OCMStub([pdfDocumentMock moveToDirectory:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]).andReturn(success);
}

- (void)rejectMoveToDirectoryCallForPDFDocumentMock:(PDFDocument *)pdfDocumentMock
{
    // as OCMock doesnt have good implementation of 'reject', just throw uncaught exception for moveToDirectory:error: method
    OCMStub([pdfDocumentMock moveToDirectory:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]).andThrow([NSException new]);
}

- (void)verifyMoveToDirectoryCallForPDFDocumentMock:(PDFDocument *)pdfDocumentMock
{
    OCMVerify([pdfDocumentMock moveToDirectory:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]);
}

#pragma mark - Tests

- (void)testMoveToDirectoryCalledForOneDocument
{
    PDFDocument *fakePdfDocument = [[PDFDocument alloc] initWithPath:@"fake_pdf_path"];
    id fakePdfDocumentMock = OCMPartialMock(fakePdfDocument);
    
    [self stubMoveToDirectoryCallForPDFDocumentMock:fakePdfDocumentMock];
    
    NSError *error = nil;
    [self.pdfDocumentStore moveDocument:fakePdfDocument toFolder:self.fakeFolder error:&error];
    
    [self verifyMoveToDirectoryCallForPDFDocumentMock:fakePdfDocumentMock];
}

- (void)testMoveToDirectoryCalledForTwoDocuments
{
    PDFDocument *fakePdfDocumentOne = [[PDFDocument alloc] initWithPath:@"fake_pdf_path_1"];
    id fakePdfDocumentOneMock = OCMPartialMock(fakePdfDocumentOne);
    
    PDFDocument *fakePdfDocumentTwo = [[PDFDocument alloc] initWithPath:@"fake_pdf_path_2"];
    id fakePdfDocumentTwoMock = OCMPartialMock(fakePdfDocumentTwo);
    
    [self stubMoveToDirectoryCallForPDFDocumentMock:fakePdfDocumentOneMock];
    [self stubMoveToDirectoryCallForPDFDocumentMock:fakePdfDocumentTwoMock];
    
    NSError *error = nil;
    NSArray *documents = @[fakePdfDocumentOne, fakePdfDocumentTwo];
    [self.pdfDocumentStore moveDocuments:documents toFolder:self.fakeFolder error:&error];
    
    [self verifyMoveToDirectoryCallForPDFDocumentMock:fakePdfDocumentOneMock];
    [self verifyMoveToDirectoryCallForPDFDocumentMock:fakePdfDocumentTwoMock];
}

- (void)testStoppingOfMovingIfOneDocumentFailedToMove
{
    PDFDocument *fakePdfDocumentOne = [[PDFDocument alloc] initWithPath:@"fake_pdf_path_1"];
    id fakePdfDocumentOneMock = OCMPartialMock(fakePdfDocumentOne);
    
    PDFDocument *fakePdfDocumentTwo = [[PDFDocument alloc] initWithPath:@"fake_pdf_path_2"];
    id fakePdfDocumentTwoMock = OCMPartialMock(fakePdfDocumentTwo);
    
    [self stubMoveToDirectoryCallForPDFDocumentMock:fakePdfDocumentOneMock andReturnSuccess:NO];
    [self rejectMoveToDirectoryCallForPDFDocumentMock:fakePdfDocumentTwoMock];
    
    NSError *error = nil;
    NSArray *documents = @[fakePdfDocumentOne, fakePdfDocumentTwo];
    XCTAssertFalse([self.pdfDocumentStore moveDocuments:documents toFolder:self.fakeFolder error:&error], @"Method must return NO if moving failed");
}

@end
