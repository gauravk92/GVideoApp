//
//  HeaderView.h
//  ComplementaryHeaders
//
//  Created by Dmitry Stadnik on 1/22/10.
//  Copyright www.dimzzy.com 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HeaderView : UIView {
	NSString *text;
	NSString *subtext;
	BOOL complementaryHeader;
}

@property(retain) NSString *text;
@property(retain) NSString *subtext;
@property(assign) BOOL complementaryHeader;

@end

static __inline__ BOOL EqualStrings(NSString *s1, NSString *s2) {
	return s1 ? [s1 isEqualToString:s2] : !s2;
}
