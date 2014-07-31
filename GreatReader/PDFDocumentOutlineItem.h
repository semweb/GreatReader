//
//  PDFDocumentOutlineItem.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFDocumentOutlineItem : NSObject
@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, assign, readonly) NSUInteger pageNumber;
@property (nonatomic, assign, readonly) CGPDFObjectRef destination;
@property (nonatomic, strong, readonly) NSArray *children;
- (instancetype)initWithTitle:(NSString *)title
                   pageNumber:(NSUInteger)pageNumber
                  destination:(CGPDFObjectRef)destination
                     children:(NSArray *)children;
@end
