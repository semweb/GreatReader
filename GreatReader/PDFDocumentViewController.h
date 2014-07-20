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
@class PDFPageViewController;

@interface PDFDocumentViewController : UIViewController <PDFDocumentPageSliderDelegate>
@property (nonatomic, strong) PDFDocument *document;
@property (nonatomic, readonly) PDFPageViewController *currentPageViewController;

- (IBAction)exitCrop:(UIStoryboardSegue *)segue;
- (IBAction)exitBrightness:(UIStoryboardSegue *)segue;
- (IBAction)exitOutline:(UIStoryboardSegue *)segue;
- (IBAction)exitBookmark:(UIStoryboardSegue *)segue;
- (IBAction)exitHistory:(UIStoryboardSegue *)segue;
- (IBAction)exitSearch:(UIStoryboardSegue *)segue;

- (IBAction)toggleRibbon:(id)sender;

- (void)goAtIndex:(NSUInteger)index animated:(BOOL)animated;
- (void)openDocument:(PDFDocument *)document;
    
@end
