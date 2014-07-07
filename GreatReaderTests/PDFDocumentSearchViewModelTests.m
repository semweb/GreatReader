//
//  PDFDocumentSearchViewModelTests.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/10/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PDFDocumentSearch+TestAdditions.h"
#import "PDFDocumentSearch.h"
#import "PDFDocumentSearchViewModel.h"

@interface PDFDocumentSearchViewModelTests : XCTestCase
@property (nonatomic, assign) NSUInteger observationCount;
@end

@implementation PDFDocumentSearchViewModelTests

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

- (void)testStartSearchWithKeyword
{
    PDFDocumentSearch *search = [PDFDocumentSearch test_searchWithPDFName:@"PDFDocumentSearchTests3"];
    PDFDocumentSearchViewModel *viewModel = [[PDFDocumentSearchViewModel alloc] initWithSearch:search];
    XCTAssertTrue(viewModel.results.count == 0, @"");

    [viewModel startSearchWithKeyword:@"xxx"];
    CGFloat timeout = 0;
    while (viewModel.results.count != 2) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        timeout += 0.1;
        XCTAssertTrue(timeout < 2, @"");
    }
}

- (void)testObservation
{
    PDFDocumentSearch *search = [PDFDocumentSearch test_searchWithPDFName:@"PDFDocumentSearchTests3"];
    PDFDocumentSearchViewModel *viewModel = [[PDFDocumentSearchViewModel alloc] initWithSearch:search];
    XCTAssertTrue(viewModel.results.count == 0, @"");

    [viewModel addObserver:self
                forKeyPath:@"results"
                   options:0
                   context:NULL];

    [viewModel startSearchWithKeyword:@"xxx"];

    self.observationCount = 0;
    CGFloat timeout = 0;
    while (viewModel.results.count != 2) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        timeout += 0.1;
        XCTAssertTrue(timeout < 2, @"");
    }

    XCTAssertTrue(self.observationCount == 2, @"");

    [viewModel removeObserver:self forKeyPath:@"results"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    self.observationCount++;
}

@end
