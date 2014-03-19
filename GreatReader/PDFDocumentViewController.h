//
//  PDFDocumentViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 2013/12/17.
//  Copyright (c) 2013 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PDFDocumentPageSlider.h"

@class PDFDocument;
@class PDFRecentDocumentList;

extern NSString * const PDFDocumentViewControllerSegueCropOdd;
extern NSString * const PDFDocumentViewControllerSegueCropEven;

@interface PDFDocumentViewController : UIViewController <PDFDocumentPageSliderDelegate,
                                                         PDFDocumentPageSliderDataSource>
@property (nonatomic, strong) PDFDocument *document;
@property (nonatomic, strong) PDFRecentDocumentList *documentList;

- (IBAction)exitCrop:(UIStoryboardSegue *)segue;
- (IBAction)exitSetting:(UIStoryboardSegue *)segue;
- (IBAction)exitOutline:(UIStoryboardSegue *)segue;
- (IBAction)exitBookmark:(UIStoryboardSegue *)segue;

- (IBAction)toggleRibbon:(id)sender;

- (void)goAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)openDocument:(PDFDocument *)document;
    
@end
