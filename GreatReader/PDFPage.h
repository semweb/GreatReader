//
//  PDFPage.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/01/12.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PDFDocumentCrop;
@class PDFPageLink;
@class PDFPageLinkList;
@class PDFRenderingCharacter;

@interface PDFPage : NSObject
@property (nonatomic, assign) CGPDFPageRef CGPDFPage;
@property (nonatomic, readonly) NSUInteger index;
@property (nonatomic, readonly) CGRect rect;
@property (nonatomic, readonly) CGRect croppedRect;
@property (nonatomic, weak) PDFDocumentCrop *crop;
@property (nonatomic, strong) PDFPageLinkList *linkList;
@property (nonatomic, strong) NSArray *characters;
@property (nonatomic, readonly) NSArray *selectedFrames;
@property (nonatomic, readonly) NSArray *selectedCharacters;
@property (nonatomic, readonly) NSString *selectedString;
@property (nonatomic, strong, readonly) NSArray *characterFrames;
- (instancetype)initWithCGPDFPage:(CGPDFPageRef)CGPDFPage;
- (UIImage *)thumbnailImageWithSize:(CGSize)size cropping:(BOOL)cropping;
- (void)drawInRect:(CGRect)rect inContext:(CGContextRef)context cropping:(BOOL)cropping;
- (PDFRenderingCharacter *)characterAtPoint:(CGPoint)point;
- (PDFRenderingCharacter *)nearestCharacterAtPoint:(CGPoint)point;
- (void)selectWordForCharacter:(PDFRenderingCharacter *)character;
- (void)selectCharactersFrom:(PDFRenderingCharacter *)fromCharacter
                          to:(PDFRenderingCharacter *)toCharacter;
- (void)unselectCharacters;
- (PDFPageLink *)linkAtPoint:(CGPoint)point;
@end
