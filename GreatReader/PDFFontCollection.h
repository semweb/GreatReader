//
//  PDFFontCollection.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/5/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFFont;

@interface PDFFontCollection : NSObject
- (instancetype)initWithCGPDFPage:(CGPDFPageRef)CGPDFPage;
- (PDFFont *)fontForName:(NSString *)name;
@end
