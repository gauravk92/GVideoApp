//
//  GVRadialGradientLayer.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/11/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface GVRadialGradientLayer : CAShapeLayer


@property (nonatomic, copy) NSArray *colorValues; // defaults to @[clearColor, whiteColor]

@property (nonatomic, copy) NSNumber *toRadius; // defaults to 10
@property (nonatomic, copy) NSNumber *fromRadius; // defaults to 0

@property (nonatomic, copy) NSValue *contentsOriginPoint; // CGPoint [0,1] default is center (0.5,0.5)
@property (nonatomic, copy) NSValue *contentsDrawRectFrame; // default is bounds
@property (nonatomic, copy) NSValue *contentsOffset; // CGPoint [0, bounds] default is (0,0)

@property (nonatomic, assign, readonly) BOOL animateShine;

//// any additional offsets
//@property (nonatomic, strong) NSValue *startEdgeInsets;
//@property (nonatomic, strong) NSValue *endEdgeInsets;
//
//// defaults to 0.5, 0.5 (center x, center y) in bounds
//@property (nonatomic, strong) NSValue *startOffset;
//@property (nonatomic, strong) NSValue *endOffset;

- (void)setupAnimateShine;
- (void)animateShineNow;

@end
