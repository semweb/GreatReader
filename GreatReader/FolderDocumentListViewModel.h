//
//  FolderDocumentListViewModel.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/23/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "DocumentListViewModel.h"

@class Folder;

@interface FolderDocumentListViewModel : DocumentListViewModel
- (instancetype)initWithFolder:(Folder *)folder;
@property (nonatomic, strong, readonly) Folder *folder;
@end
