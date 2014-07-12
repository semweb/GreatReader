//
//  PDFDocumentPageSliderModel.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/12/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFDocumentPageSliderModel.h"

#import "PDFDocument.h"
#import "PDFDocumentBackForwardList.h"

@interface PDFDocumentPageSliderModel ()
@property (nonatomic, strong) PDFDocument *document;
@end

@implementation PDFDocumentPageSliderModel

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key
{
    if ([key isEqualToString:@"currentPage"]) {
        return [NSSet setWithObjects:@"document.currentPage", nil];
    } else if ([key isEqualToString:@"canGoBack"]) {
        return [NSSet setWithObjects:@"document.backForwardList.canGoBack", nil];
    } else if ([key isEqualToString:@"canGoForward"]) {
        return [NSSet setWithObjects:@"document.backForwardList.canGoForward", nil];
    }
    return NSSet.set;
}

- (instancetype)initWithDocument:(PDFDocument *)document
{
    self = [super init];
    if (self) {
        _document = document;
    }
    return self;
}

- (NSUInteger)currentPage
{
    return self.document.currentPage;
}

- (NSUInteger)numberOfPages
{
    return self.document.numberOfPages;
}

- (BOOL)canGoBack
{
    return self.document.backForwardList.canGoBack;
}

- (BOOL)canGoForward
{
    return self.document.backForwardList.canGoForward;
}

@end
