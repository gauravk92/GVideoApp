//
//  GVSplitTableView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/6/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVSplitTableView.h"


const CGFloat splitTableHeader = 0;


@implementation GVSplitTableView

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}
//
//- (void)setupCameraViewController:(UIViewController*)cameraVC {
//    if (self.cameraViewController) {
//        [self.cameraViewController.view removeFromSuperview];
//        self.cameraViewController = nil;
//    }
//    self.cameraViewController = cameraVC;
//    [self addSubview:self.cameraViewController.view];
//}
//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//
//    CGFloat heightOfTopPane = self.frame.size.height - splitTableHeader - splitTablePaneHeight;
//    CGFloat contentOffset = self.bounds.origin.y;
//
//    CGRect topRect = self.cameraViewController.view.frame;
//
//    [self bringSubviewToFront:self.cameraViewController.view];

//    if (!self.layoutCameraFullscreen) {
//        if (contentOffset < 0) {
//            topRect.origin.y = 0;
//            topRect.size.height = self.frame.size.height - 100 + (-1*contentOffset);
//        } else {
//            topRect.origin.y = contentOffset;
//            topRect.size.height = self.frame.size.height - 100 - contentOffset;
//        }
//    } else {
//        topRect.origin.y = contentOffset;
//        topRect.size.height = self.frame.size.height + (contentOffset*-1) - 110;
////        if (contentOffset > 0) {
////            topRect.origin.y = (-1*contentOffset);
////            topRect.size.height = heightOfTopPane + (contentOffset);
////
////        } else {
////            topRect.origin.y = contentOffset*-1;
////            topRect.size.height = self.bounds.size.height - splitTableHeader + (-1*contentOffset);
////            //topRect.origin.y = 0;
////            //topRect.size.height = self.cameraViewController.view.bounds.size.height;
////        }
//    }

    //UITableViewCell *cell = [self cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    //[self sendSubviewToBack:cell.contentView];
    //[self sendSubviewToBack:self.cameraViewController.view];

    //if (!self.layoutCameraFullscreen) {
    //  self.cameraViewController.view.frame = topRect;
    //[self.cameraViewController.view setNeedsLayout];
    //[self.cameraViewController.view layoutIfNeeded];
    //}
    //}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
//
//- (void)layoutSubviews {
//    [super layoutSubviews];
//
//    for(UITableViewCell *cell in self.visibleCells) {
//        for (UIView *subview in cell.contentView.subviews) {
//            subview.frame = cell.contentView.bounds;
//        }
//    }
//}

@end
