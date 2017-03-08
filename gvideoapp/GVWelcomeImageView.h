//
//  GVWelcomeImageView.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 7/24/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVWelcomeImageView : UIImageView

@property (nonatomic, assign) CGFloat lowOpacity;
@property (nonatomic, assign) CGFloat highOpacity;
@property (nonatomic, assign) CGFloat fadeInDuration;
@property (nonatomic, assign) CGFloat fadeOutDuration;


- (void)animateMaskFadeIn;
- (void)animateMaskFadeOut;

- (CGSize)realSize;
- (void)setFrameAndShadowPath:(CGRect)frame;

/*
 *  MUST BE CALLED BEFORE setFirstBubble:secondBubble:
 */
- (void)setFirstBubbleRounding:(BOOL)round secondBubbleRounding:(BOOL)round1;

- (void)setFirstBubble:(CGRect)rect secondBubble:(CGRect)rect1;
- (void)addThirdRegion:(CGRect)region fourthRegion:(CGRect)region1;

@end
