//
//  GVTokenViewController.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 4/26/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVTokenViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *tokenTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (nonatomic, copy) NSString *emailAddress;

@end
