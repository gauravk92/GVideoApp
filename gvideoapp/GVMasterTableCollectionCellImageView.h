//
//  GVMasterTableCollectionCellImageView.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/5/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GVDelegateImageView.h"

@interface GVMasterTableCollectionCellImageView : UIView


@property (nonatomic, weak) UIView *displayDelegate;

@property (nonatomic, strong) GVDelegateImageView *imageView;



@end
