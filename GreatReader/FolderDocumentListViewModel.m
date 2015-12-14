//
//  FolderDocumentListViewModel.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "FolderDocumentListViewModel.h"

#import "Folder.h"
#import "RootFolder.h"
#import "PDFDocument.h"
#import "PDFDocumentStore.h"
#import "PDFRecentDocumentList.h"

@interface FolderDocumentListViewModel ()
@property (nonatomic, strong, readwrite) Folder *folder;
@end

@implementation FolderDocumentListViewModel

- (instancetype)initWithFolder:(Folder *)folder
{
    self = [super init];
    if (self) {
        _folder = folder;
    }
    return self;
}

- (NSString *)title
{
    if ([self.folder isKindOfClass:[RootFolder class]]) {
        return LocalizedString(@"home.all-documents");
    } else {
        return self.folder.name;
    }
}

- (NSUInteger)count
{
    return self.folder.files.count;
}

- (PDFDocument *)documentAtIndex:(NSUInteger)index
{
    return self.folder.files[index];
}

- (void)reload
{
    [self.folder load];
}

- (BOOL)deleteDocuments:(NSArray *)documents error:(NSError **)error
{
    return [self.folder.store deleteDocuments:documents error:error];
}

- (Folder *)createFolderInCurrentFolderWithName:(NSString *)folderName error:(NSError **)error
{
    return [self.folder createSubFolderWithName:folderName error:error];
}

- (BOOL)moveDocuments:(NSArray *)documents toFolder:(Folder *)folder error:(NSError **)error
{
    return [self.folder.store moveDocuments:documents toFolder:folder error:error];
}

- (BOOL)findSuperFolderAndMoveDocuments:(NSArray *)documents error:(NSError **)error
{
    Folder *superFolder = [self.folder findSuperFolder];
    if (superFolder)
    {
        return [self moveDocuments:documents toFolder:superFolder error:error];
    }
    
    return NO;
}

- (BOOL)createFolderInCurrentFolderWithName:(NSString *)folderName andMoveDocuments:(NSArray *)documents error:(NSError **)error
{
    Folder *newFolder = [self createFolderInCurrentFolderWithName:folderName error:error];
    if (newFolder) {
        return [self moveDocuments:documents toFolder:newFolder error:error];
    }
    
    return NO;
}

- (BOOL)checkIfCurrentFolderIsRootFolder
{
    return [self.folder isKindOfClass:[RootFolder class]];
}

- (BOOL)checkIfHasFolderInDocuments:(NSArray *)documents
{
    __block BOOL hasFolder = NO;
    
    [documents enumerateObjectsUsingBlock:^(File *file, NSUInteger index, BOOL *stop) {
        if ([file isKindOfClass:[Folder class]]) {
            hasFolder = YES;
            *stop = YES;
            return;
        }
    }];
    
    return hasFolder;
}

@end
