//
//  GRTModalTransitionAnimator.h
//  GreatReader
//
//  Created by MIYAMOTO Shohei on 5/2/14.
//  Copyright (c) 2014 MIYAMOTO Shohei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GRTModalTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>
@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, assign) CGFloat presentedContentHeight;
@end


@interface GRTModalDismissButton : UIButton
@property (nonatomic, copy) void (^tapped)(void);
@end
