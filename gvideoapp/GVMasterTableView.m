//
//  GVMasterTableView.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/15/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVMasterTableView.h"

@implementation GVMasterTableView

//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        // Initialization code
//    }
//    return self;
//}

//+ (Class)layerClass {
//    return [CATransformLayer class];
//}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style {
    self = [super initWithFrame:frame style:UITableViewStyleGrouped];
    if (self) {
        self.clipsToBounds = YES;
        self.autoresizesSubviews = NO;
        self.opaque = YES;
        self.layer.needsDisplayOnBoundsChange = NO;
    }
    return self;
}


//- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view {
//    BOOL begin = [super touchesShouldBegin:touches withEvent:event inContentView:view];
//
//
//    return NO;
//    return begin;
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
