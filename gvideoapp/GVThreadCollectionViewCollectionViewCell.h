//
//  GVThreadCollectionViewCollectionViewCell.h
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/20/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GVThreadCollectionViewCollectionViewCell : UICollectionViewCell <UIToolbarDelegate>

@property (nonatomic, strong) UIImageView *thumbnailImageView;
@property (nonatomic, strong) UIToolbar *detailToolbar;

- (void)removeAllSubImageViews;

@property (nonatomic, assign) BOOL displaySendMessage;

@end
