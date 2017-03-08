//
//  GVRecordMiniDotView.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/5/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVRecordMiniDotView : UIView

@property (nonatomic, strong) UIView *colorView;

- (void)startAnimatingScaling;

- (CGFloat)cornerRadius;
- (void)setCornerRadius:(CGFloat)cornerRadius;

@end
