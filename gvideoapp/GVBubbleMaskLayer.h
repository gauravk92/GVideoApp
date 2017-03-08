//
//  GVBubbleMaskLayer.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 7/24/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface GVBubbleMaskLayer : CALayer

@property (nonatomic, copy) NSNumber *firstBubbleRounding;
@property (nonatomic, copy) NSNumber *secondBubbleRounding;

@property (nonatomic, copy) NSValue *firstBubble;
@property (nonatomic, copy) NSValue *secondBubble;

@property (nonatomic, copy) NSValue *thirdBubble;
@property (nonatomic, copy) NSValue *fourthBubble;

@end
