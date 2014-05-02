//
//  PDFRecentDocumentListViewModel.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/2/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFRecentDocumentListViewModel.h"

#import "PDFRecentDocumentList.h"
#import "PDFDocument.h"

@interface PDFRecentDocumentListViewModel ()
@property (nonatomic, assign) BOOL withoutActive;
@property (nonatomic, strong, readwrite) PDFRecentDocumentList *documentList;
@end

@implementation PDFRecentDocumentListViewModel

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"documents"]) {
        return [NSSet setWithObjects:@"documentList.documents", nil];
    }
    return NSSet.set;
}

- (id)initWithDocumentList:(PDFRecentDocumentList *)documentList
             withoutActive:(BOOL)withoutActive
{
    self = [super init];
    if (self) {
        _documentList = documentList;
        _withoutActive = withoutActive;
    }
    return self;
}

- (PDFDocument *)documentAtIndex:(NSUInteger)index
{
    return self.documents[index];
}

- (NSUInteger)count
{
    return self.documents.count;
}

- (NSArray *)documents
{
    NSArray *list = self.documentList.documents;
    if (self.withoutActive && list.count > 0) {
        return [list subarrayWithRange:NSMakeRange(1, list.count - 1)];
    } else {
        return list;
    }
}

@end
