//
//  PDFPageScanner.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/2/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFPageScanner : NSObject
@property (nonatomic, assign) CGPDFPageRef CGPDFPage;
- (instancetype)initWithCGPDFPage:(CGPDFPageRef)CGPDFPage;
- (NSArray *)scanStringContents;
- (NSArray *)scanAnchors;
@end
