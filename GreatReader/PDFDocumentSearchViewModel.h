//
//  PDFDocumentSearchViewModel.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/9/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFDocumentSearch;

@interface PDFDocumentSearchViewModel : NSObject
- (instancetype)initWithSearch:(PDFDocumentSearch *)search;
- (void)startSearchWithKeyword:(NSString *)keyword;
@property (nonatomic, strong, readonly) NSArray *results;
@end
