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
@end

@implementation RootFolder

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)initWithPath:(NSString *)path
                       store:(PDFDocumentStore *)store
{
    self = [super initWithPath:path
                         store:store];
    if (self) {
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(didEnterBackground:)
                                                   name:UIApplicationDidEnterBackgroundNotification
                                                 object:nil];      
    }
    return self;
}

- (void)load
{
    [super load];

    [self filterInboxFolder];
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

#pragma mark -

- (void)didEnterBackground:(NSNotification *)notification
{
    [self deleteAllFilesInInbox];
}

@end
