//
//  ComplementaryHeadersViewController.m
//  ComplementaryHeaders
//
//  Created by Dmitry Stadnik on 1/22/10.
//  Copyright www.dimzzy.com 2010. All rights reserved.
//

#import "ComplementaryHeadersViewController.h"
#import "HeaderView.h"

@implementation ComplementaryHeadersViewController

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
	HeaderView *view = [[[HeaderView alloc] initWithFrame:CGRectZero] autorelease];
	view.text = @"Header";
	view.subtext = @"This is a primary header";
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
