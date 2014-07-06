//
//  PDFRecentDocumentList.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/06.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GRTArrayController;
@class PDFDocument;
@class PDFDocumentStore;

@interface PDFRecentDocumentList : NSObject
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly, strong) NSArray *documents;
@property (nonatomic, readonly, weak) PDFDocumentStore *store;
- (instancetype)initWithStore:(PDFDocumentStore *)store;
- (PDFDocument *)documentAtIndex:(NSUInteger)index;
- (void)addHistory:(PDFDocument *)document;
- (PDFDocument *)findDocumentAtPath:(NSString *)path;
- (void)removeHistories:(NSArray *)histories;
@end
