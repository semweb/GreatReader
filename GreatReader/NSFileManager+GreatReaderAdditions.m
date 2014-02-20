//
//  NSFileManager+GreatReaderAdditions.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/10.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "NSFileManager+GreatReaderAdditions.h"

NSString * const kPrivateDocuments = @"PrivateDocuments";

@implementation NSFileManager (GreatReaderAdditions)

+ (NSString *)grt_privateDocumentsPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    return [NSString stringWithFormat:@"%@%@", paths[0], kPrivateDocuments];
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

@end
