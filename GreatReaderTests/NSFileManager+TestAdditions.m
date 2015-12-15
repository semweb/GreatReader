//
//  NSFileManager+TestAdditions.m
//  GreatReader
//
//  Created by Malmygin Anton on 10.12.15.
//  Copyright © 2015 MIYAMOTO Shohei. All rights reserved.
//

#import "NSFileManager+TestAdditions.h"

@implementation NSFileManager (TestAdditions)

- (NSString *)createTemporaryTestDirectory
{
    NSString *tempDirectoryPath = [NSTemporaryDirectory() stringByAppendingPathComponent:[[NSProcessInfo processInfo] globallyUniqueString]];
    
    if ([self createDirectoryAtPath:tempDirectoryPath withIntermediateDirectories:YES attributes:nil error:nil]) {
        return tempDirectoryPath;
    }
    
    return nil;
}

- (BOOL)removeTemporaryTestDirectory:(NSString *)testDirectoryPath
{
    return [self removeItemAtPath:testDirectoryPath error:nil];
}

- (NSString *)createSubFolderInTemporaryTestDirectory:(NSString *)testDirectoryPath
{
    NSString *subFolderName = @"Test Folder";
    NSString *subFolderPath = [testDirectoryPath stringByAppendingPathComponent:subFolderName];
    
    if ([self createDirectoryAtPath:subFolderPath withIntermediateDirectories:YES attributes:nil error:nil]) {
        return subFolderPath;
    }
    
    return nil;
}

@end
