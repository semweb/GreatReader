//
//  DocumentModalTransitionAnimator.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 7/19/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocumentModalTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) BOOL presenting;
@end
