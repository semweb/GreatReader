//
//  PDFPageLink.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/30/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFPageLink : NSObject
@property (nonatomic, readonly, assign) NSUInteger pageNumber;
@property (nonatomic, readonly, assign) CGRect rect;

- (instancetype)initWithPageNumber:(NSUInteger)pageNumber
                              rect:(CGRect)rect;
@end
