//
//  GVReactionsTableViewCell.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/3/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *GVInternetRequestNotification;
extern NSString *GVSaveMovieNotification;

@interface GVReactionsTableViewCell : UITableViewCell


@property (nonatomic, copy) NSString *contentURL;

- (void)removeAllSubImageViews;

- (void)setUsernameString:(NSString*)text;
- (void)setTimeString:(NSString*)text;

- (void)setThumbImageView:(UIImageView*)imageView;

@end
