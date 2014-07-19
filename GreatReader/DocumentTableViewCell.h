//
//  DocumentTableViewCell.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/6/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DocumentCell.h"

@class PDFDocument;

@interface DocumentTableViewCell : UITableViewCell <DocumentCell>
@property (nonatomic, strong) PDFDocument *document;
@end
