//
//  ComboCell.m
//  ComboCell
//
//  Created by Dmitry Stadnik on 1/20/10.
//  Copyright www.dimzzy.com 2010. All rights reserved.
//

#import "ComboCell.h"
#import "TextSizeCache.h"

@interface ComboCellContentView : UIView {
    ComboCell *_cell;
    BOOL _highlighted;
}

@end

@implementation ComboCellContentView

- (id)initWithFrame:(CGRect)frame cell:(ComboCell *)cell {
    if (self = [super initWithFrame:frame]) {
        _cell = cell;
        self.opaque = YES;
        self.backgroundColor = _cell.backgroundColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	if (!EmptyString(_cell.text)) {
		[[UIColor blackColor] set];
		const CGFloat textWidth = self.bounds.size.width - kComboCellSpacing * 2;
		const CGSize textSize = [_cell.text sizeWithFont:kComboCellTextFont
									   constrainedToSize:CGSizeMake(textWidth, CGFLOAT_MAX / 2)
										   lineBreakMode:UILineBreakModeWordWrap];
		const CGFloat textHeight = textSize.height;
		[_cell.text drawInRect:CGRectMake(kComboCellSpacing, kComboCellSpacing, textWidth, textHeight)
					  withFont:kComboCellTextFont
				 lineBreakMode:UILineBreakModeTailTruncation];
		if (!EmptyString(_cell.subtext)) {
			const CGSize subtextSize = [_cell.subtext sizeWithFont:kComboCellSubtextFont
												 constrainedToSize:CGSizeMake(textWidth - kComboCellSubtextBorder * 2, CGFLOAT_MAX / 2)
													 lineBreakMode:UILineBreakModeTailTruncation];
			const CGFloat subtextWidth = subtextSize.width + kComboCellSubtextBorder * 2;
			const CGFloat subtextHeight = subtextSize.height +  + kComboCellSubtextBorder * 2;
			CGFloat subtextTop = self.bounds.size.height - kComboCellSpacing - subtextHeight;
			const CGFloat subtextLeft = self.bounds.size.width - kComboCellSpacing - subtextWidth;
			CGRect subtextRect = CGRectMake(subtextLeft, subtextTop, subtextWidth, subtextHeight);
			[kComboCellLightBackgroundColor set];
			CGContextRef ctx = UIGraphicsGetCurrentContext();
			CGContextAddRoundedRect(ctx, subtextRect, kComboCellSubtextBorder);
			CGContextFillPath(ctx);
			[[UIColor whiteColor] set];
			[_cell.subtext drawInRect:CGRectInset(subtextRect, kComboCellSubtextBorder, kComboCellSubtextBorder)
							 withFont:kComboCellSubtextFont
						lineBreakMode:UILineBreakModeTailTruncation];
		}
	}
}

- (void)setHighlighted:(BOOL)highlighted {
    _highlighted = highlighted;
    [self setNeedsDisplay];
}

- (BOOL)isHighlighted {
    return _highlighted;
}

@end

@implementation ComboCell

@synthesize text;
@synthesize subtext;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        cellContentView = [[ComboCellContentView alloc] initWithFrame:self.contentView.bounds cell:self];
        cellContentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        cellContentView.contentMode = UIViewContentModeRedraw;
        [self.contentView addSubview:cellContentView];
    }
    return self;
}

- (void)dealloc {
	[text release];
	[subtext release];
    [cellContentView release];
    [super dealloc];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    cellContentView.backgroundColor = backgroundColor;
}

+ (CGFloat)cellHeightWithText:(NSString *)text subtext:(NSString *)subtext width:(CGFloat)width {
	if (EmptyString(text)) {
		return 0;
	}
	const CGFloat textWidth = width - kComboCellSpacing * 2;
	CGSize textSize = [text sizeWithFont:kComboCellTextFont
					   constrainedToSize:CGSizeMake(textWidth, CGFLOAT_MAX / 2)
						   lineBreakMode:UILineBreakModeWordWrap];
	CGFloat height = textSize.height;
	if (!EmptyString(subtext)) {
		CGSize subtextSize = [subtext sizeWithFont:kComboCellSubtextFont
								 constrainedToSize:CGSizeMake(textWidth - kComboCellSubtextBorder * 2, CGFLOAT_MAX / 2)
									 lineBreakMode:UILineBreakModeTailTruncation];
		const CGFloat subtextWidth = subtextSize.width + kComboCellSubtextBorder * 2;
		const CGFloat subtextHeight = subtextSize.height + kComboCellSubtextBorder * 2;

		// Here is the trick: add shortest string wider then rendered subtext to the text and if the
		// text height remains the same then subtext can be submerged in the last line of the text
		NSString *subtextSuffix = [[TextSizeCache sharedCache] shortestTextWiderThan:subtextWidth ofFont:kComboCellSubtextFont];
		CGSize combinedTextSize = [[text stringByAppendingString:subtextSuffix] sizeWithFont:kComboCellTextFont
																		   constrainedToSize:CGSizeMake(textWidth, CGFLOAT_MAX / 2)
																			   lineBreakMode:UILineBreakModeWordWrap];
		if (combinedTextSize.height == textSize.height) {
			const CGFloat textLineHeight = [text sizeWithFont:kComboCellTextFont].height;
			if (textLineHeight == textSize.height) {
				height = MAX(height, subtextHeight);
			} else if (subtextHeight + kComboCellSpacing > textLineHeight) {
				height += subtextHeight + kComboCellSpacing - textLineHeight;
			}
		} else {
			height += kComboCellSpacing + subtextHeight;
		}
	}
	return height + kComboCellSpacing * 2;
}

@end
