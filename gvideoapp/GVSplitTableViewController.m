//
//  GVSplitTableViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/6/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVSplitTableViewController.h"
#import "GVModalCameraVideoController.h"
#import "GVMasterViewController.h"
#import "GVTintColorUtility.h"
#import "GVSplitTableView.h"



NSString * const GVSplitTableViewControllerCellIdentifier = @"GVSplitTableViewControllerCellIdentifier";

@interface GVSplitTableViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) GVSplitTableView *view;

@property (nonatomic, assign) BOOL showingCameraFullscreen;
@property (nonatomic, strong) UINavigationBar *headerBar;

@end

@implementation GVSplitTableViewController




- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        // Custom initialization
        self.automaticallyAdjustsScrollViewInsets = NO;


    }
    return self;
}

- (BOOL)shouldAutorotate {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return NO;
}

- (BOOL)shouldAutomaticallyForwardRotationMethods {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return YES;
    }
    return NO;
}

//- (NSUInteger)supportedInterfaceOrientations {
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        return UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeLeft | UIInterfaceOrientationLandscapeRight;
//    }
//    return UIInterfaceOrientationPortrait;
//}

//- (void)dealloc {
//
//}

//- (void)pullUp {
//    //if (!self.showingCameraFullscreen) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//        //self.tableView.userInteractionEnabled = NO;
//        //[self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
//            if ([self.splitScrollDelegate respondsToSelector:@selector(goToFullscreen)]) {
//                [self.splitScrollDelegate performSelector:@selector(goToFullscreen)];
//            }
//        });
//    //}
//}

//- (void)loadView {
//    self.view = [[GVSplitTableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
//}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.bounces = NO;
    self.tableView.layer.shouldRasterize = YES;
    self.tableView.exclusiveTouch = NO;
    self.tableView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:GVSplitTableViewControllerCellIdentifier];
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //self.tableView.rowHeight = self.view.bounds.size.height - splitTableHeader;


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        //if (self.showingCameraFullscreen) {
        //    return self.view.frame.size.height - splitTableHeader;
        //}
        return self.view.frame.size.height;
    }
    return self.view.frame.size.height - splitTablePaneHeight;
    //return self.view.frame.size.height - splitTableHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return splitTableHeader;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (!self.headerBar) {
        UINavigationBar *headerBar = [[UINavigationBar alloc] initWithFrame:CGRectZero];
        headerBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        headerBar.translatesAutoresizingMaskIntoConstraints = NO;
        [GVTintColorUtility applyNavigationBarTintColor:headerBar];
        self.headerBar = headerBar;
    }
    return self.headerBar;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

//    for (UIView *subview in cell.subviews) {
//        [subview removeFromSuperview];
//    }

    switch (indexPath.section) {
        case 0: {
            cell.contentView.backgroundColor = [UIColor clearColor];
            cell.hidden = YES;

            if ([self.splitScrollDelegate respondsToSelector:@selector(willDisplay)]) {
                [self.splitScrollDelegate performSelector:@selector(willDisplay)];
            }
            break;
        }
        case 1: {
            [cell.contentView addSubview:self.bottomViewController.view];
            cell.contentView.layer.opaque = YES;
            //self.bottomViewController.view.layer.shouldRasterize = YES;
            //self.bottomViewController.view.layer.rasterizationScale = [UIScreen mainScreen].scale;
            self.bottomViewController.view.frame = cell.contentView.bounds;
            [self addChildViewController:self.bottomViewController];
            cell.contentView.backgroundColor = [UIColor whiteColor];
            [self.bottomViewController didMoveToParentViewController:self];
            cell.hidden = NO;
        }
        default: {
            break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if ([self.splitScrollDelegate respondsToSelector:@selector(didEndDisplay)]) {
            [self.splitScrollDelegate performSelector:@selector(didEndDisplay)];
        }
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    @weakify(self);
    //dispatch_async(dispatch_get_main_queue(), ^{
    //  @strongify(self);
    //NSIndexPath *cameraRow = [NSIndexPath indexPathForRow:0 inSection:0];

    

    if (scrollView.contentOffset.y < 60) {
        if (!self.showingCameraFullscreen) {
            self.showingCameraFullscreen = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);

            //self.view.layoutCameraFullscreen = YES;
                if ([self.splitScrollDelegate respondsToSelector:@selector(goToFullscreen)]) {
                    [self.splitScrollDelegate performSelector:@selector(goToFullscreen)];
                }
            });
//            [self.topViewController.view.layer addAnimation:[self animationGroupPushedBackward] forKey:@"animate"];
//            [UIView animateWithDuration:kModalSeguePushedBackAnimationDuration animations:^{
//                self.topViewController.view.alpha = 0.7;
//            }];
            //[self.tableView reloadData];
            //[self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
        } else {
//            if ([self.splitScrollDelegate respondsToSelector:@selector(endFullscreen)]) {
//                [self.splitScrollDelegate performSelector:@selector(endFullscreen)];
//            }
        }
    } else {
        if (self.showingCameraFullscreen) {
                    self.showingCameraFullscreen = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                @strongify(self);

            //self.view.layoutCameraFullscreen = NO;
            if ([self.splitScrollDelegate respondsToSelector:@selector(endFullscreen)]) {
                [self.splitScrollDelegate performSelector:@selector(endFullscreen)];
            }
            });
            //[self.tableView reloadData];
        } else {
//            if ([self.splitScrollDelegate respondsToSelector:@selector(goToFullscreen)]) {
//                [self.splitScrollDelegate performSelector:@selector(goToFullscreen)];
//            }
        }
        //}
//    if (scrollView.contentOffset.y > 120) {
//        if (self.showingCameraFullscreen) {
//            self.showingCameraFullscreen = NO;
//            //self.view.layoutCameraFullscreen = NO;
//            if ([self.splitScrollDelegate respondsToSelector:@selector(endFullscreen)]) {
//                [self.splitScrollDelegate performSelector:@selector(endFullscreen)];
//            }
//            //[self.tableView reloadData];
//            //[self.tableView setContentOffset:CGPointMake(0, 0) animated:YES];
//        }
//    } else {
//        if (!self.showingCameraFullscreen) {
//            self.showingCameraFullscreen = YES;
//            //self.view.layoutCameraFullscreen = YES;
//            if ([self.splitScrollDelegate respondsToSelector:@selector(goToFullscreen)]) {
//                [self.splitScrollDelegate performSelector:@selector(goToFullscreen)];
//            }
//            //[self.tableView reloadData];
//            //[self.tableView setContentOffset:CGPointMake(0, <#CGFloat y#>) animated:<#(BOOL)#>]
//        }
    }

    if ([self.splitScrollDelegate respondsToSelector:@selector(tellContentOffset:)]) {
        [self.splitScrollDelegate tellContentOffset:self.tableView.contentOffset];
    }
//});

}

//- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//
//    for (UIView *subview in cell.subviews) {
//        [subview removeFromSuperview];
//    }
//
//    if (indexPath.section == 0) {
//        [self.topViewController removeFromParentViewController];
//        [self.topViewController didMoveToParentViewController:nil];
//    } else {
//        [self.bottomViewController removeFromParentViewController];
//        [self.bottomViewController didMoveToParentViewController:nil];
//    }
//
//
//}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.splitScrollDelegate respondsToSelector:@selector(endedDragging)]) {
        [self.splitScrollDelegate performSelector:@selector(endedDragging)];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:GVSplitTableViewControllerCellIdentifier forIndexPath:indexPath];

    // Configure the cell...
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
