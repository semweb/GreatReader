//
//  PDFDocumentBrightnessViewController.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/17/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PDFDocument;

extern NSString * const PDFDocumentSettingSegueExit;

@interface PDFDocumentBrightnessViewController : UIViewController
@property (nonatomic, strong) PDFDocument *document;
@end


@interface PDFDocumentSettingSegue : UIStoryboardSegue
@end

@interface PDFDocumentExitSettingSegue : UIStoryboardSegue
@end
