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
@end

@implementation PDFDocumentStoreTests

#pragma mark - SetUp / TearDown

- (void)setUp
{
    [super setUp];
    
    self.pdfDocumentStore = [[PDFDocumentStore alloc] init];
}

- (void)tearDown
{
    self.pdfDocumentStore = nil;
    
    [super tearDown];
}

#pragma mark - Tests

- (void)testMoveToDirectoryCalledForOneDocument
{
    PDFDocument *fakePdfDocument = [[PDFDocument alloc] initWithPath:@"fake_pdf_path"];
    id fakePdfDocumentMock = OCMPartialMock(fakePdfDocument);
    
    Folder *fakeFolder = [[Folder alloc] initWithPath:@"fake_folder_path"];
    
    OCMStub([fakePdfDocumentMock moveToDirectory:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]).andReturn(YES);
    
    NSError *error = nil;
    [self.pdfDocumentStore moveDocument:fakePdfDocument toFolder:fakeFolder error:&error];
    
    OCMVerify([fakePdfDocumentMock moveToDirectory:[OCMArg any] error:((NSError *__autoreleasing *)[OCMArg anyPointer])]);
}

@end
