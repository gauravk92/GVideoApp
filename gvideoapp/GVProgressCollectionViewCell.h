//
//  GVProgressCollectionViewCell.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/16/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVProgressCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) BOOL showsImage;

- (void)setupImageView:(UIImageView*)imageView;
- (void)setupUsernameLabel:(UILabel*)usernameLabel;

@end
