//
//  RootFolder.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/29/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "RootFolder.h"

#import "NSArray+GreatReaderAdditions.h"

@interface RootFolder ()
@property (nonatomic, strong, readwrite) NSArray *files;
@end

@implementation RootFolder

- (void)load
{
    [super load];

    [self filterInboxFolder];
    [self deleteAllFilesInInbox];
}

- (void)filterInboxFolder
{
    self.files = [self.files grt_filter:^(File *file) {
        return (BOOL)![file.name isEqualToString:@"Inbox"];
    }];
}

- (void)deleteAllFilesInInbox
{
    NSFileManager *fm = [NSFileManager new];
    NSString *path = [self.path stringByAppendingPathComponent:@"Inbox"];
    if ([fm fileExistsAtPath:path]) {
        NSArray *contents = [fm contentsOfDirectoryAtPath:path error:NULL];
        for (NSString *p in contents) {
            [fm removeItemAtPath:[path stringByAppendingPathComponent:p] error:NULL];
        }
    }
}

@end
