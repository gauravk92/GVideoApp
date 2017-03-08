//
//  ViewsCacheViewController.m
//  ViewsCache
//
//  Created by Dmitry Stadnik on 1/21/10.
//  Copyright www.dimzzy.com 2010. All rights reserved.
//

#import "ViewsCacheViewController.h"
#import "HeaderView.h"

@implementation ViewsCacheViewController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 30;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 4;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	NSString *ViewIdentifier = @"HeaderView";
	HeaderView *view = (HeaderView *)[[ViewsCache sharedCache] dequeueReusableViewWithIdentifier:ViewIdentifier];
	if (!view) {
		view = [[[HeaderView alloc] initWithFrame:CGRectZero] autorelease];
		view.reuseIdentifier = ViewIdentifier;
	}
	view.textLabel.text = [NSString stringWithFormat:@"Header %d", section + 1];
	view.subtextLabel.text = @"This is an orange header";
	view.iconView.image = [UIImage imageNamed:@"dizzy.png"];
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	cell.textLabel.text = [NSString stringWithFormat:@"Cell %d", indexPath.row + 1];
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	return cell;
}

@end
