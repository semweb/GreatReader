//
//  PDFRecentDocumentList.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/06.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFDocument;
@class PDFDocumentStore;

@interface PDFRecentDocumentList : NSObject
@property (nonatomic, assign, readonly) NSUInteger count;
@property (nonatomic, strong, readonly) NSArray *documents;
@property (nonatomic, weak, readonly) PDFDocumentStore *store;
- (instancetype)initWithStore:(PDFDocumentStore *)store;
- (PDFDocument *)documentAtIndex:(NSUInteger)index;
- (void)addHistory:(PDFDocument *)document;
- (PDFDocument *)findDocumentAtPath:(NSString *)path;
- (void)removeHistories:(NSArray *)histories;
@end
