//
//  GVCircleThumbnailInnerShadowView.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/5/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVCircleThumbnailInnerShadowView : UIView

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIToolbar *detailToolbar;

- (void)animateBorder;
- (void)arrangeSubviews;

@end
