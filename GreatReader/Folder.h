//
//  Folder.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/17.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "File.h"

@interface Folder : File
@property (nonatomic, strong, readonly) NSArray *files;
+ (Folder *)rootFolder;
@end
