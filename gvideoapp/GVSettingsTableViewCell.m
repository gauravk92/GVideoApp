//
//  GVSettingsTableViewCell.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 5/27/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVSettingsTableViewCell.h"
#import "GVTintColorUtility.h"
#import "GVSettingsTableViewCellButtonView.h"


@interface GVSettingsTableViewCell ()



@end


@implementation GVSettingsTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code

        UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
        NSDictionary *attr = @{NSBackgroundColorAttributeName: [UIColor whiteColor],
                               NSFontAttributeName: font};
        self.customTextAttributes = attr;
        //NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:title attributes:attr];

        //[self.textLabel setAttributedText:attrString];
        self.textLabel.layer.shouldRasterize = YES;
        self.textLabel.font = font;
        self.textLabel.layer.needsDisplayOnBoundsChange = NO;
        self.textLabel.backgroundColor = [UIColor whiteColor];
        self.textLabel.layer.opaque = YES;
        self.textLabel.layer.rasterizationScale = [UIScreen mainScreen].scale;
        UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
        aSwitch.backgroundColor = [UIColor whiteColor];
        aSwitch.tintColor = [GVTintColorUtility utilityTintColor];
        aSwitch.onTintColor = [GVTintColorUtility utilityTintColor];
        //[aSwitch addTarget:self action:action forControlEvents:UIControlEventValueChanged];
        self.accessoryView = aSwitch;
        self.uiSwitch = aSwitch;

        //return aSwitch;



        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];


        //UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18.0];
        //NSDictionary *attr = @{NSFontAttributeName: font};

        //NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:title attributes:attr];

        //[button setAttributedTitle:attrString forState:UIControlStateNormal];
        //[button setTitle:title forState:UIControlStateNormal];
//        if (color) {
//            [button setTintColor:color];
//        }
        button.layer.shouldRasterize = YES;
        //button.font = font;
        button.opaque = YES;
        button.backgroundColor = [UIColor whiteColor];
        button.layer.rasterizationScale = [UIScreen mainScreen].scale;
        //[button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        //GVSettingsTableViewCellButtonView *buttonView = [[GVSettingsTableViewCellButtonView alloc] initWithFrame:CGRectZero];
        //[cell addSubview:buttonView];
        [self addSubview:button];
        //buttonView.mainButton = button;
        button.frame = self.bounds;
        
        self.secondButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.secondButton.layer.shouldRasterize = YES;
        self.secondButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.secondButton.opaque = YES;
        self.secondButton.backgroundColor = [UIColor whiteColor];
        self.secondButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.secondButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.secondButton.frame = self.bounds;
        
        
        self.thirdButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.thirdButton.layer.rasterizationScale = [UIScreen mainScreen].scale;
        self.thirdButton.layer.shouldRasterize = YES;
        self.thirdButton.opaque = YES;
        self.thirdButton.backgroundColor = [UIColor whiteColor];
        self.thirdButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.thirdButton.translatesAutoresizingMaskIntoConstraints = NO;
        self.thirdButton.frame = self.bounds;
        

        //cell.mainView = buttonView;
        //button.center = cell.center;
        self.button = button;
    }
    return self;
}
//
//- (void)awakeFromNib
//{
//    // Initialization code
//}
//
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated
//{
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

- (void)prepareForReuse {
    [super prepareForReuse];
    //[self.mainView removeFromSuperview];
    //[self.textLabel setAttributedText:nil];
    self.textLabel.text = nil;
    [self.secondButton removeFromSuperview];
    [self.thirdButton removeFromSuperview];
    //self.button.hidden = YES;
    //self.accessoryView.hidden = YES;
    [self.uiSwitch removeTarget:self action:self.actionSel forControlEvents:UIControlEventAllEvents];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];


    //self.button.center = self.center;
    //self.mainView.frame = CGRectIntegral(self.contentView.bounds);
}

@end
