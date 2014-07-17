//
//  PDFDocumentSearchViewModelTests.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/10/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "FBKVOController.h"
#import "PDFDocument.h"
#import "PDFDocumentSearch+TestAdditions.h"
#import "PDFDocumentSearch.h"
#import "PDFDocumentSearchViewModel.h"

@interface PDFDocumentSearchViewModelTests : XCTestCase
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
    PDFDocumentSearchViewModel *viewModel = [[PDFDocumentSearchViewModel alloc] initWithSearch:search
                                                                                       outline:[[search document] outline]];
    XCTAssertTrue(viewModel.sections.count == 0, @"");

    [viewModel startSearchWithKeyword:@"xxx"];
    CGFloat timeout = 0;
    PDFDocumentSearchViewSection *section = nil;
    while (section.results.count != 2) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        timeout += 0.1;
        XCTAssertTrue(timeout < 2, @"");
        if (timeout >= 2) break;        
        section = [viewModel.sections firstObject];        
    }
}

- (void)testObservation
{
    PDFDocumentSearch *search = [PDFDocumentSearch test_searchWithPDFName:@"PDFDocumentSearchTests3"];
    PDFDocumentSearchViewModel *viewModel = [[PDFDocumentSearchViewModel alloc] initWithSearch:search
                                                                                       outline:[[search document] outline]];
    XCTAssertTrue(viewModel.sections.count == 0, @"");

    FBKVOController *kvoController = [FBKVOController controllerWithObserver:self];
    __block int count = 0;
    [kvoController observe:viewModel
                   keyPath:@"sections"
                   options:0
                     block:^(id tests, PDFDocumentSearchViewModel *vm, NSDictionary *change) {
        count++;
    }];

    [viewModel startSearchWithKeyword:@"xxx"];

    CGFloat timeout = 0;
    PDFDocumentSearchViewSection *section = nil;
    while (section.results.count != 2) {
        [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
        timeout += 0.1;
        XCTAssertTrue(timeout < 2, @"");
        if (timeout >= 2) break;
        section = [viewModel.sections firstObject];
    }

    XCTAssertTrue(count == 2, @"");
}

@end
