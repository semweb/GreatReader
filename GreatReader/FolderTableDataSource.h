//
//  FolderTableDataSource.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/19.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class File;
@class Folder;

@interface FolderTableDataSource : NSObject
- (instancetype)initWithFolder:(Folder *)folder;
- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfFilesInSection:(NSInteger)section;
- (File *)fileAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)titleInSection:(NSUInteger)section;
- (NSString *)title;
- (BOOL)removeItemAtIndexPath:(NSIndexPath *)indexPath
                        error:(NSError **)error;
@end
