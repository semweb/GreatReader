//
//  PDFUtils.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/6/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "PDFUtils.h"

// CGPDFDictionaryRef
CGPDFArrayRef PDFDictionaryGetArray(CGPDFDictionaryRef d, const char *key)
{
    CGPDFArrayRef array = NULL;
    CGPDFDictionaryGetArray(d, key, &array);
    return array;
}

CGPDFStreamRef PDFDictionaryGetStream(CGPDFDictionaryRef d, const char *key)
{
    CGPDFStreamRef stream = NULL;
    CGPDFDictionaryGetStream(d, key, &stream);
    return stream;
}

CGPDFDictionaryRef PDFDictionaryGetDictionary(CGPDFDictionaryRef d, const char *key)
{
    CGPDFDictionaryRef dictionary = NULL;
    CGPDFDictionaryGetDictionary(d, key, &dictionary);
    return dictionary;
}

CGPDFInteger PDFDictionaryGetInteger(CGPDFDictionaryRef d, const char *key)
{
    CGPDFInteger integer = -1;
    CGPDFDictionaryGetInteger(d, key, &integer);
    return integer;
}

void PDFDictionaryLogObjectAndKey(const char *key, CGPDFObjectRef object, void *info)
{
    CGPDFObjectType type = CGPDFObjectGetType(object);
    switch(type) {
        case kCGPDFObjectTypeNull:
            NSLog(@"%s: \t(Null)", key);
            break;
        case kCGPDFObjectTypeBoolean:
            NSLog(@"%s: \t(Boolean)", key);            
            break;
        case kCGPDFObjectTypeInteger: {
            CGPDFInteger value = -1;
            CGPDFObjectGetValue(object, type, &value);
            NSLog(@"%s: \t(Integer)%d", key, (int)value);
            break;
        }
        case kCGPDFObjectTypeReal: {
            CGPDFReal value = -1;
            CGPDFObjectGetValue(object, type, &value);
            NSLog(@"%s: \t(Real)%f", key, value);            
            break;
        }
        case kCGPDFObjectTypeName: {
            const char *name = NULL;
            CGPDFObjectGetValue(object, type, &name);
            NSLog(@"%s: \t(Name)%s", key, name);
            break;
        }
        case kCGPDFObjectTypeString:
            NSLog(@"%s: \t(string)", key);            
            break;            
        case kCGPDFObjectTypeArray:
            NSLog(@"%s: \t(Array)", key);        
            break;        
        case kCGPDFObjectTypeDictionary:
            NSLog(@"%s: \t(Dictionary)", key);            
            break;            
        case kCGPDFObjectTypeStream:
            NSLog(@"%s: \t(Stream)", key);            
            break;            
    }
}

void PDFDictionaryLog(CGPDFDictionaryRef d)
{
    CGPDFDictionaryApplyFunction(d,
                                 &PDFDictionaryLogObjectAndKey,
                                 NULL);
}

const char * PDFDictionaryGetName(CGPDFDictionaryRef d, const char *key)
{
    const char *name = NULL;
    if (CGPDFDictionaryGetName(d, key, &name)) {
        return name;
    }
    return name;
}

CGPDFObjectRef PDFDictionaryGetObject(CGPDFDictionaryRef d, const char *key)
{
    CGPDFObjectRef obj = NULL;
    CGPDFDictionaryGetObject(d, key, &obj);
    return obj;
}

NSString * PDFDictionaryGetString(CGPDFDictionaryRef d, const char *key)
{
    CGPDFStringRef string = nil;
    CGPDFDictionaryGetString(d, key, &string);
    return (__bridge_transfer NSString *)CGPDFStringCopyTextString(string);
}

// CGPDFArrayRef
CGPDFDictionaryRef PDFArrayGetDictionary(CGPDFArrayRef a, size_t index)
{
    CGPDFDictionaryRef dictionary = NULL;
    CGPDFArrayGetDictionary(a, index, &dictionary);
    return dictionary;
}

CGPDFArrayRef PDFArrayGetArray(CGPDFArrayRef a, size_t index)
{
    CGPDFArrayRef array = NULL;
    CGPDFArrayGetArray(a, index, &array);
    return array;
}

CGPDFInteger PDFArrayGetInteger(CGPDFArrayRef a, size_t index)
{
    CGPDFInteger integer = -1;
    CGPDFArrayGetInteger(a, index, &integer);
    return integer;
}

CGPDFReal PDFArrayGetNumber(CGPDFArrayRef array, size_t index)
{
    CGPDFReal number = -1;
    CGPDFArrayGetNumber(array, index, &number);
    return number;
}

CGPDFObjectRef PDFArrayGetObject(CGPDFArrayRef a, size_t index)
{
    CGPDFObjectRef object = NULL;
    CGPDFArrayGetObject(a, index, &object);
    return object;
}

NSString * PDFArrayGetString(CGPDFArrayRef array, size_t index)
{
    CGPDFStringRef string = NULL;
    CGPDFArrayGetString(array, index, &string);
    return (__bridge_transfer NSString *)CGPDFStringCopyTextString(string);
}
