//
//  Folder.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/17.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "Folder.h"

#import "File.h"
#import "NSArray+GreatReaderAdditions.h"
#import "PDFDocument.h"

@interface Folder ()
@property (nonatomic, strong, readwrite) NSArray *files;
@end

@implementation Folder

+ (Folder *)rootFolder
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    Folder *folder = [[Folder alloc] initWithPath:paths.firstObject];
    [folder load];
    [folder filterInboxFolder];
    [folder deleteAllFilesInInbox];
    return folder;
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

- (void)load
{
    NSFileManager *fm = [[NSFileManager alloc] init];
    NSArray *contents = [fm contentsOfDirectoryAtPath:self.path
                                                error:NULL];
    self.files = [contents grt_map:^(NSString *p) {
        NSString *absPath = [NSString stringWithFormat:@"%@/%@", self.path, p];
        BOOL isDirectory;
        [fm fileExistsAtPath:absPath isDirectory:&isDirectory];
        File *file = nil;
        if (isDirectory) {
            file = [[Folder alloc] initWithPath:absPath];
        } else {
            file = [[PDFDocument alloc] initWithPath:absPath];
        }
        return file;
    }];
}

- (UIImage *)iconImage
{
    return [UIImage imageNamed:@"Folder.png"];
}

- (BOOL)removeItemAtIndex:(NSUInteger)index error:(NSError **)error
{
    NSFileManager *fileManager = [NSFileManager new];
    File *file = self.files[index];
    if ([fileManager removeItemAtPath:file.path error:error]) {
        NSMutableArray *mFiles = self.files.mutableCopy;
        [mFiles removeObject:file];
        self.files = mFiles.copy;
        return YES;
    }
    return NO;
}

@end
