//
//  File.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/17.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface File : NSObject
@property (nonatomic, readonly) NSString *path;
@property (nonatomic, readonly) NSString *name;
@property (nonatomic, strong) UIImage *iconImage;
@property (nonatomic, assign) BOOL fileNotExist;
- (instancetype)initWithPath:(NSString *)path;
@end
