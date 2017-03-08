//
//  RightLabelViewController.m
//  RightLabel
//
//  Created by Dmitry Stadnik on 1/20/10.
//  Copyright www.dimzzy.com 2010. All rights reserved.
//

#import "RightLabelViewController.h"
#import "ComboCell.h"

@implementation RightLabelViewController

- (void)viewDidLoad {
	data = [[NSArray alloc] initWithObjects:
			@"Short text", @"abc",
			@"This text takes exactly two full lines so the subtext can not be submerged into the last line", @"subtext",
			@"Long text that should wrap to the second line of the table cell", @"123",
			nil];
}

- (void)dealloc {
	[data release];
	[super dealloc];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [data count] / 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ComboCell";
    ComboCell *cell = (ComboCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[ComboCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	cell.text = [data objectAtIndex:(indexPath.row * 2)];
	cell.subtext = [data objectAtIndex:(indexPath.row * 2 + 1)];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return [ComboCell cellHeightWithText:[data objectAtIndex:(indexPath.row * 2)]
								 subtext:[data objectAtIndex:(indexPath.row * 2 + 1)]
								   width:tableView.bounds.size.width];
}

@end
