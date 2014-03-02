//
//  FolderTableDataSource.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/19.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "FolderTableDataSource.h"

#import "Folder.h"

@interface FolderTableDataSource ()
@property (nonatomic, strong) Folder *folder;
@end

@implementation FolderTableDataSource

- (instancetype)initWithFolder:(Folder *)folder
{
    self = [super init];
    if (self) {
        _folder = folder;
    }
    return self;
}

- (NSUInteger)numberOfSections
{
    return 1;
}

- (NSUInteger)numberOfFilesInSection:(NSInteger)section
{
    return self.folder.files.count;
}

- (File *)fileAtIndexPath:(NSIndexPath *)indexPath
{
    return self.folder.files[indexPath.row];
}

- (NSString *)titleInSection:(NSUInteger)section
{
    return nil;
}

- (NSString *)title
{
    return self.folder.name;
}

- (BOOL)removeItemAtIndexPath:(NSIndexPath *)indexPath
                        error:(NSError **)error
{
    return [self.folder removeItemAtIndex:indexPath.row
                                    error:error];
}

@end
