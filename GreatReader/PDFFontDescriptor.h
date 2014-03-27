//
//  PDFFontDescriptor.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/11/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFFontDescriptor : NSObject
- (instancetype)initWithFontDescriptorDictionary:(CGPDFDictionaryRef)dictionary;
- (instancetype)initWithBaseFont:(NSString *)baseFont;
@property (nonatomic, assign, readonly) CGFloat descent;
@property (nonatomic, assign, readonly) CGFloat ascent;
@end
