//
//  UILabel+AutoShrink.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/16/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "UILabel+AutoShrink.h"

@implementation UILabel (AutoShrink)

-(void)adjustFontSizeToFit
{
    self.text = [self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    UIFont *font = self.font;
    CGSize size = self.frame.size;

    for (CGFloat maxSize = self.font.pointSize; maxSize >= self.minimumScaleFactor; maxSize -= 1.f)
    {
        font = [font fontWithSize:maxSize];
        CGSize constraintSize = CGSizeMake(size.width, MAXFLOAT);
        CGSize labelSize = [self.text sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
        if(labelSize.height <= size.height)
        {
            self.font = font;
            [self setNeedsLayout];
            break;
        }
    }
    // set the font to the minimum size anyway
    self.font = font;
    [self setNeedsLayout];
}

@end
