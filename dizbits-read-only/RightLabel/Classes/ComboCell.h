//
//  ComboCell.h
//  ComboCell
//
//  Created by Dmitry Stadnik on 1/20/10.
//  Copyright www.dimzzy.com 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

#define kComboCellSpacing 5
#define kComboCellSubtextBorder 3
#define kComboCellTextFont [UIFont systemFontOfSize:14]
#define kComboCellSubtextFont [UIFont boldSystemFontOfSize:12]
#define kComboCellLightBackgroundColor [UIColor colorWithRed:0.492 green:0.579 blue:0.695 alpha:1.000]
#define kComboCellDarkBackgroundColor [UIColor colorWithRed:0.236 green:0.353 blue:0.524 alpha:1.000]

@interface ComboCell : UITableViewCell {
    UIView *cellContentView;
	NSString *text;
	NSString *subtext;
}

@property(nonatomic, retain) NSString *text;
@property(nonatomic, retain) NSString *subtext;

+ (CGFloat)cellHeightWithText:(NSString *)text subtext:(NSString *)subtext width:(CGFloat)width;

@end

static __inline__ void CGContextAddRoundedRect(CGContextRef c, CGRect rect, int corner_radius) {
    CGFloat x_left = rect.origin.x;
    CGFloat x_left_center = rect.origin.x + corner_radius;
    CGFloat x_right_center = rect.origin.x + rect.size.width - corner_radius;
    CGFloat x_right = rect.origin.x + rect.size.width;
    CGFloat y_top = rect.origin.y;
    CGFloat y_top_center = rect.origin.y + corner_radius;
    CGFloat y_bottom_center = rect.origin.y + rect.size.height - corner_radius;
    CGFloat y_bottom = rect.origin.y + rect.size.height;
    CGContextBeginPath(c);
    CGContextMoveToPoint(c, x_left, y_top_center);
    CGContextAddArcToPoint(c, x_left, y_top, x_left_center, y_top, corner_radius);
    CGContextAddLineToPoint(c, x_right_center, y_top);
    CGContextAddArcToPoint(c, x_right, y_top, x_right, y_top_center, corner_radius);
    CGContextAddLineToPoint(c, x_right, y_bottom_center);
    CGContextAddArcToPoint(c, x_right, y_bottom, x_right_center, y_bottom, corner_radius);
    CGContextAddLineToPoint(c, x_left_center, y_bottom);
    CGContextAddArcToPoint(c, x_left, y_bottom, x_left, y_bottom_center, corner_radius);
    CGContextAddLineToPoint(c, x_left, y_top_center);
    CGContextClosePath(c);
}

static __inline__ BOOL EmptyString(NSString *s) {
	return s ? [s length] == 0 : YES;
}
