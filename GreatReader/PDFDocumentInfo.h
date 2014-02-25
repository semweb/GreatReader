//
//  PDFDocumentInfo.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/17.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFDocument;

@interface PDFDocumentInfo : NSObject
- (instancetype)initWithDocument:(PDFDocument *)document;
@property (nonatomic, readonly) NSString *pageDescription;
@property (nonatomic, readonly) NSString *sectionTitle;
@property (nonatomic, readonly) NSString *title;
@end
