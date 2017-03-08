#import <UIKit/UIKit.h>
#import "ZZPageControl.h"

@interface PageControlViewController : UIViewController {
	IBOutlet ZZPageControl *_pageControl1;
	IBOutlet ZZPageControl *_pageControl2;
	IBOutlet ZZPageControl *_pageControl3;
	IBOutlet ZZPageControl *_pageControl4;
	IBOutlet ZZPageControl *_pageControl5;
	IBOutlet ZZPageControl *_pageControl6;
}

- (IBAction)addPage;
- (IBAction)removePage;

@end

