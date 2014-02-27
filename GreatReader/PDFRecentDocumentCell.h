//
//  PDFRecentDocumentCell.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2014/02/07.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFDocument;

@interface PDFRecentDocumentCell : UICollectionViewCell
@property (nonatomic, strong) PDFDocument *document;
@end
