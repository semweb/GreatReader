//
//  LibraryUtils.m
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 3/30/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import "LibraryUtils.h"

BOOL CrashlyticsEnabled()
{
    return GetCrashlyticsAPIKey().length > 0;
}

NSString * GetCrashlyticsAPIKey()
{
    NSString *path = [NSBundle.mainBundle pathForResource:@"API_KEY"
                                                   ofType:@"plist"];
    NSDictionary *keys = [NSDictionary dictionaryWithContentsOfFile:path];
    return keys[@"CRASHLYTICS_API_KEY1"];
}
