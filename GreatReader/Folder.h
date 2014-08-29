//
//  Folder.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/17.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "File.h"

@class PDFDocumentStore;

extern NSString * const FolderFileRemovedNotification;

@interface Folder : File
@property (nonatomic, strong) NSArray *files;
@property (nonatomic, weak, readonly) PDFDocumentStore *store;
- (instancetype)initWithPath:(NSString *)path
                       store:(PDFDocumentStore *)store;
- (void)load;
- (BOOL)removeItemAtIndex:(NSUInteger)index error:(NSError **)error;
@end
