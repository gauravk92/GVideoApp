//
//  GVRecordAnimatingMiniDotView.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/5/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVRecordMiniDotView.h"

@interface GVRecordAnimatingMiniDotView : UIView

@property (nonatomic, strong) GVRecordMiniDotView *miniDotView;

- (void)startAnimatingDots;

@end
