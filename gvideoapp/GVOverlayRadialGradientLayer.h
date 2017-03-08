//
//  GVOverlayRadialGradientLayer.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/11/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GVRadialGradientLayer.h"
#import "GVSmoothRadialGradientLayer.h"

@interface GVOverlayRadialGradientLayer : CAShapeLayer

@property (nonatomic, strong) CAShapeLayer *overlayLayer;
@property (nonatomic, strong) GVSmoothRadialGradientLayer *contentLayer;

@end
