//
//  PDFDocumentBackForwardList.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/11/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFDocumentBackForwardList : NSObject
@property (nonatomic, readonly) BOOL canGoBack;
@property (nonatomic, readonly) BOOL canGoForward;
// - (NSUInteger)goBackFrom:(NSUInteger)page;
// - (NSUInteger)goForwardFrom:(NSUInteger)page;
// - (void)addHistory:(NSUInteger)page;
@property (nonatomic, readonly) NSUInteger currentPage;

- (instancetype)initWithCurrentPage:(NSUInteger)currentPage;
- (void)goBack;
- (void)goForward;
- (void)goTo:(NSUInteger)page
  addHistory:(BOOL)addHistory;
@end
