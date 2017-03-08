#import "PageControlViewController.h"

@implementation PageControlViewController

- (void)pageDidChange:(ZZPageControl *)pageControl {
	NSInteger page = pageControl.currentPage;
	self.view.backgroundColor = [UIColor colorWithRed:(page % 2)
												green:(page % 3)
												 blue:(page == 0 ? 1 : 0)
												alpha:1];
}

- (void)addPage {
	_pageControl1.numberOfPages++;
}

- (void)removePage {
	_pageControl1.numberOfPages--;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	_pageControl1.numberOfPages = 6;
	[_pageControl1 addTarget:self
					  action:@selector(pageDidChange:)
			forControlEvents:UIControlEventValueChanged];
	_pageControl2.activeColor = [UIColor redColor];
	_pageControl2.inactiveColor = [UIColor blueColor];
	_pageControl2.numberOfPages = 6;
	[_pageControl2 addTarget:self
					  action:@selector(pageDidChange:)
			forControlEvents:UIControlEventValueChanged];
	_pageControl3.primaryMode = ZZPageControlModeBlocks;
	_pageControl3.numberOfPages = 6;
	[_pageControl3 addTarget:self
					  action:@selector(pageDidChange:)
			forControlEvents:UIControlEventValueChanged];
	_pageControl4.primaryMode = ZZPageControlModeProgress;
	_pageControl4.inset = 120;
	_pageControl4.numberOfPages = 6;
	[_pageControl4 addTarget:self
					  action:@selector(pageDidChange:)
			forControlEvents:UIControlEventValueChanged];
	_pageControl5.primaryMode = ZZPageControlModeBlock;
	_pageControl5.inset = 120;
	_pageControl5.numberOfPages = 6;
	[_pageControl5 addTarget:self
					  action:@selector(pageDidChange:)
			forControlEvents:UIControlEventValueChanged];
	_pageControl6.primaryMode = ZZPageControlModePill;
	_pageControl6.inset = 120;
	_pageControl6.numberOfPages = 6;
	[_pageControl6 addTarget:self
					  action:@selector(pageDidChange:)
			forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidUnload {
	[super viewDidUnload];
	[_pageControl1 release];
	_pageControl1 = nil;
	[_pageControl2 release];
	_pageControl2 = nil;
	[_pageControl3 release];
	_pageControl3 = nil;
	[_pageControl4 release];
	_pageControl4 = nil;
	[_pageControl5 release];
	_pageControl5 = nil;
	[_pageControl6 release];
	_pageControl6 = nil;
}

- (void)dealloc {
	[_pageControl1 release];
	[_pageControl2 release];
	[_pageControl3 release];
	[_pageControl4 release];
	[_pageControl5 release];
	[_pageControl6 release];
	[super dealloc];
}

@end
