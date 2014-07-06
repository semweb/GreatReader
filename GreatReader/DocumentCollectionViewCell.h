//
//  DocumentCollectionViewCell.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/6/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFDocument;

@interface DocumentCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) PDFDocument *document;
@end
