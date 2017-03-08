//
//  BlueViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/7/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "BlueViewController.h"

@implementation BlueViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor blueColor];
}

- (CGSize)preferredContentSize {
    return self.view.bounds.size;
}

@end
