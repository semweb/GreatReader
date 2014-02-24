//
//  PDFDocumentBookmarkList.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2/24/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFDocumentBookmarkList : NSObject
@property (nonatomic, readonly) NSArray *bookmarkList;
- (void)bookmarkAtPage:(NSUInteger)page;
- (void)unbookmarkAtPage:(NSUInteger)page;
- (BOOL)bookmarkedAtPage:(NSUInteger)page;
- (void)toggleBookmarkAtPage:(NSUInteger)page;
@end
