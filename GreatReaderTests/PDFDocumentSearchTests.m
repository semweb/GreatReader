//
//  PDFDocumentSearchTests.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/7/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "NSFileManager+GreatReaderAdditions.h"
#import "PDFDocument.h"
#import "PDFDocumentSearch.h"
#import "PDFDocumentSearch+TestAdditions.h"
#import "PDFDocumentSearchResult.h"

@interface PDFDocumentSearchTests : XCTestCase <PDFDocumentSearchDelegate>
@property (nonatomic, strong) PDFDocumentSearch *search;
@property (nonatomic, strong) NSArray *expectations;
@property (nonatomic, copy) void (^block)(PDFDocumentSearch *, PDFDocumentSearchResult *);
@end

@implementation PDFDocumentSearchTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)wait
{
    BOOL finished = NO;
    while (!finished) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        XCTAssertTrue(self.expectations != nil, @"");
        finished = (self.expectations.count == 0);
    }
}

- (void)testSearchWithString
{
    __weak typeof(self) wself = self;
    wself.block = ^(PDFDocumentSearch *search, PDFDocumentSearchResult *result) {
        NSString *expectation = [wself.expectations firstObject];
        wself.expectations = [wself.expectations subarrayWithRange:NSMakeRange(1, wself.expectations.count - 1)];
        XCTAssertTrue([expectation isEqual:result.surroundingText], @"");
        XCTAssertTrue(result.page == 1, @"");        
    };
    
    {
        PDFDocumentSearch *search = [PDFDocumentSearch test_searchWithPDFName:@"PDFDocumentSearchTests1"];
        search.delegate = self;
        self.expectations = @[@"oooooooooooooxxxoooooooooooooo"];
        [search searchWithString:@"xxx"];
        [self wait];
    }
    {
        PDFDocumentSearch *search = [PDFDocumentSearch test_searchWithPDFName:@"PDFDocumentSearchTests2"];
        search.delegate = self;        
        self.expectations = @[@"oooooooooooooxxxoooooooooooooo"];
        [search searchWithString:@"xxx"];
        [self wait];        
    }
    {
        PDFDocumentSearch *search = [PDFDocumentSearch test_searchWithPDFName:@"PDFDocumentSearchTests3"];
        search.delegate = self;        
        self.expectations = @[@"oooooooooooooxxxoooooooooooooo",
                              @"oooooooooooooxxxoooooooooooooo"];
        [search searchWithString:@"xxx"];
        [self wait];        
    }
    {
        PDFDocumentSearch *search = [PDFDocumentSearch test_searchWithPDFName:@"PDFDocumentSearchTests4"];
        search.delegate = self;        
        self.expectations = @[@"oooooooooooooxxxooxxxooooooooo",
                              @"ooooooooxxxooxxxoooooooooooooo"];
        [search searchWithString:@"xxx"];
        [self wait];        
    }
    {
        PDFDocumentSearch *search = [PDFDocumentSearch test_searchWithPDFName:@"PDFDocumentSearchTests5"];
        search.delegate = self;        
        self.expectations = @[@"oooooooooooooooooooooooooxxxoo"];
        [search searchWithString:@"xxx"];
        [self wait];        
    }
}

- (void)search:(PDFDocumentSearch *)search
 didFindString:(PDFDocumentSearchResult *)result
{
    if (self.block) {
        self.block(search, result);
    }
}

- (void)testCancel
{  
    PDFDocumentSearch *search = [PDFDocumentSearch test_searchWithPDFName:@"PDFDocumentSearchTests3"];
    search.delegate = self;        
    [search searchWithString:@"xxx"];
    XCTAssertTrue(search.searching, @"");
    [search cancelSearch];
    XCTAssertTrue(!search.searching, @"");    
}

@end
