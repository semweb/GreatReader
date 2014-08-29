//
//  NSFileManager+GreatReaderAdditions.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/10.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "NSFileManager+GreatReaderAdditions.h"

static NSString * const kPrivateDocuments = @"PrivateDocuments";

@implementation NSFileManager (GreatReaderAdditions)

+ (NSString *)grt_privateDocumentsPath
{
    return [self.grt_libraryPath stringByAppendingPathComponent:kPrivateDocuments];
}

+ (NSString *)grt_libraryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    return paths.firstObject;
}

+ (NSString *)grt_documentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    return paths.firstObject;
}

+ (NSString *)grt_cachePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    return paths.firstObject;    
}

- (void)grt_createPrivateDocumentsDirectory
{
    NSString *path = [[self class] grt_privateDocumentsPath];
    NSError *error = nil;
    BOOL result = [self createDirectoryAtPath:path
                        withIntermediateDirectories:NO
                                   attributes:nil
                                        error:&error];
    if (!result) {
        NSLog(@"%@", error);
    }
}

- (NSURL *)grt_incrementURLIfNecessary:(NSURL *)URL
{
    NSString *path = [URL path];
    int inc = 1;
    NSString *dirPath = [path stringByDeletingLastPathComponent];
    NSString *name = [[path lastPathComponent] stringByDeletingPathExtension];
    NSString *extension = [path pathExtension];
    while ([self fileExistsAtPath:path]) {
        path = [dirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%d", name, inc++]];
        if (extension.length > 0) {
            path = [path stringByAppendingPathExtension:extension];
        }
    }
    return [NSURL fileURLWithPath:path];
}

@end
