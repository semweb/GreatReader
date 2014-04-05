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

@interface PDFRecentDocumentList : NSObject
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly, strong) NSArray *documents;
- (PDFDocument *)documentAtIndex:(NSUInteger)index;
- (PDFDocument *)open:(PDFDocument *)document;
@end
