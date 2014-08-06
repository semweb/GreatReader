//
//  PDFUtils.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/6/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

// CGPDFDictionaryRef
CGPDFArrayRef PDFDictionaryGetArray(CGPDFDictionaryRef dictionary, const char *key);
CGPDFStreamRef PDFDictionaryGetStream(CGPDFDictionaryRef dictionary, const char *key);
CGPDFDictionaryRef PDFDictionaryGetDictionary(CGPDFDictionaryRef dictionary, const char *key);
CGPDFInteger PDFDictionaryGetInteger(CGPDFDictionaryRef dictionary, const char *key);
void PDFDictionaryLog(CGPDFDictionaryRef D);
const char * PDFDictionaryGetName(CGPDFDictionaryRef d, const char *key);
CGPDFObjectRef PDFDictionaryGetObject(CGPDFDictionaryRef d, const char *key);
NSString * PDFDictionaryGetString(CGPDFDictionaryRef d, const char *key);

// CGPDFArrayRef
CGPDFDictionaryRef PDFArrayGetDictionary(CGPDFArrayRef array, size_t index);
CGPDFArrayRef PDFArrayGetArray(CGPDFArrayRef array, size_t index);
CGPDFInteger PDFArrayGetInteger(CGPDFArrayRef array, size_t index);
CGPDFReal PDFArrayGetNumber(CGPDFArrayRef array, size_t index);
CGPDFObjectRef PDFArrayGetObject(CGPDFArrayRef array, size_t index);
NSString * PDFArrayGetString(CGPDFArrayRef array, size_t index);
