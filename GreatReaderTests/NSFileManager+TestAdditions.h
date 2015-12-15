//
//  NSFileManager+TestAdditions.h
//  GreatReader
//
//  Created by Malmygin Anton on 10.12.15.
//  Copyright © 2015 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (TestAdditions)

- (NSString *)createTemporaryTestDirectory;
- (BOOL)removeTemporaryTestDirectory:(NSString *)testDirectoryPath;

- (NSString *)createSubFolderInTemporaryTestDirectory:(NSString *)testDirectoryPath;

@end
