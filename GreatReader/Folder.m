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
#import "PDFDocumentStore.h"

NSString * const FolderFileRemovedNotification = @"FolderFileRemovedNotification";
NSString * const FolderDeletedNotification = @"FolderDeletedNotification";

@interface Folder ()
@property (nonatomic, weak, readwrite) PDFDocumentStore *store;
@end

@implementation Folder

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithPath:(NSString *)path
                       store:(PDFDocumentStore *)store
{
    self = [super initWithPath:path];
    if (self) {
        _store = store;

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fileDeleted:)
                                                     name:PDFDocumentDeletedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(fileDeleted:)
                                                     name:FolderDeletedNotification
                                                   object:nil];
    }
    return self;
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
            file = [[Folder alloc] initWithPath:absPath store:self.store];
        } else {
            file = [self.store documentAtPath:absPath];
        }
        return file.fileNotExist ? nil : file;
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
        [NSNotificationCenter.defaultCenter
            postNotificationName:FolderFileRemovedNotification
                          object:self
                        userInfo:@{
                                     @"Files": @[file]
                                  }];
        return YES;
    }
    return NO;
}

- (Folder *)findSuperFolder
{
    NSString *superFolderPath = [self.path stringByDeletingLastPathComponent];
    return [[Folder alloc] initWithPath:superFolderPath store:self.store];
}

- (Folder *)createSubFolderWithName:(NSString *)subFolderName error:(NSError **)error
{
    subFolderName = [self clearFolderName:subFolderName];
    
    if ([subFolderName length] > 0) {
        NSString *fullSubFolderPath = [self.path stringByAppendingPathComponent:subFolderName];
        
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        if ([fileManager createDirectoryAtPath:fullSubFolderPath withIntermediateDirectories:YES attributes:nil error:error]) {
            return [[Folder alloc] initWithPath:fullSubFolderPath store:self.store];
        }
    } else {
        if (error != NULL) {
            *error = [[NSError alloc] initWithDomain:@"GRT_Folder_Errors"
                                                code:-1
                                            userInfo:@{ NSLocalizedDescriptionKey : @"Incorrect new folder name" }];
        }
    }
    
    return nil;
}

- (NSString *)clearFolderName:(NSString *)folderName
{
    folderName = [folderName stringByTrimmingCharactersInSet:[NSCharacterSet controlCharacterSet]];
    folderName = [folderName stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    folderName = [folderName stringByTrimmingCharactersInSet:[NSCharacterSet illegalCharacterSet]];
    folderName = [folderName stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@":/"]];
    
    return folderName;
}

- (BOOL)containsFile:(File *)file
{
    NSString *standardFilePath = [file.path stringByStandardizingPath];
    NSString *standardFolderPath = [self.path stringByStandardizingPath];
    
    return [standardFilePath hasPrefix:standardFolderPath];
}

- (BOOL)deleteWithPossibleError:(NSError **)error
{
    // post notification before actual deletion of folder, because we want to delete some files
    // like generated pdf document thumbnails, which are stored in caches
    // (btw thumbnails cannot be deleted directly without implicit deletion of pdf document)
    [[NSNotificationCenter defaultCenter]
        postNotificationName:FolderDeletedNotification
                      object:self];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    return [fileManager removeItemAtPath:self.path error:error];
}

#pragma mark - PDFDocumentDeletedNotification and FolderDeletedNotification

- (void)fileDeleted:(NSNotification *)notification
{
    File *deletedFile = notification.object;
    for (File *file in [self.files copy]) {
        if (deletedFile == file) {
            NSMutableArray *mFiles = self.files.mutableCopy;
            [mFiles removeObject:file];
            self.files = mFiles.copy;
        }
    }
}

@end
