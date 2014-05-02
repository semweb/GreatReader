//
//  PDFRecentDocumentListViewModel.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/2/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFDocument;
@class PDFRecentDocumentList;

@interface PDFRecentDocumentListViewModel : NSObject
- (id)initWithDocumentList:(PDFRecentDocumentList *)documentList
             withoutActive:(BOOL)withoutActive;
@property (nonatomic, readonly) NSArray *documents;
@property (nonatomic, strong, readonly) PDFRecentDocumentList *documentList;
@end
