//
//  PDFDocumentViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2013/12/17.
//  Copyright (c) 2013年 semwebapp. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PDFDocumentPageSlider.h"

@class PDFDocument;
@class PDFRecentDocumentList;

@interface PDFDocumentViewController : UIViewController <PDFDocumentPageSliderDelegate,
                                                         PDFDocumentPageSliderDataSource>
@property (nonatomic, strong) PDFDocument *document;
@property (nonatomic, strong) PDFRecentDocumentList *documentList;

- (IBAction)exitCrop:(UIStoryboardSegue *)segue;
- (IBAction)exitOutline:(UIStoryboardSegue *)segue;
- (IBAction)exitHistory:(UIStoryboardSegue *)segue;

- (void)goAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)openDocument:(PDFDocument *)document;
    
@end
