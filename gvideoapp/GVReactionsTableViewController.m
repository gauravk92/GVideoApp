//
//  GVReactionsTableViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/3/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVReactionsTableViewController.h"
#import "GVReactionsTableViewCell.h"
#import "GVParseObjectUtility.h"

NSString *const GVReactionsTableViewControllerCellIdentifier = @"GVReactionsTableViewControllerCellIdentifier";

@interface GVReactionsTableViewController ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation GVReactionsTableViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Reactions";

        [self setTableViewRowHeight];
        
    }
    return self;
}

- (void)setTableViewRowHeight {
    //if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
    //    self.tableView.rowHeight = 250;
    //} else {
        self.tableView.rowHeight = 120;
    //}
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.tableView.separatorColor = [UIColor clearColor];
    self.tableView.contentInset = UIEdgeInsetsMake(16, 0, 16, 0);
    self.tableView.scrollsToTop = YES;

    [self.tableView registerClass:[GVReactionsTableViewCell class] forCellReuseIdentifier:GVReactionsTableViewControllerCellIdentifier];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    self.operationQueue = [NSOperationQueue new];
    self.operationQueue.maxConcurrentOperationCount = 1;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self.operationQueue cancelAllOperations];
    self.operationQueue = nil;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.modelObject reactionsViewControllerRowCount:self.threadId threadIndexPath:self.indexPath];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(GVReactionsTableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {

    PFObject *activity = [self.modelObject reactionsViewControllerDataAtIndexPath:indexPath thread:self.threadId threadIndexPath:self.indexPath];

    PFFile *videoThumb = [activity objectForKey:kGVActivityVideoThumbnailKey];
    NSString *videoThumbUrl = [videoThumb url];

    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.backgroundColor = [UIColor whiteColor];
    imageView.opaque = YES;

    PFUser *sendUser = [activity objectForKey:kGVActivityUserKey];
    NSString *sendusername = [sendUser username];

    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, DEGREES_TO_RADIANS(90));
    imageView.layer.shouldRasterize = YES;
    imageView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    //[[GVCache sharedCache] setAttributesForImageView:imageView url:videoThumbUrl];

    PFFile *video = [activity objectForKey:kGVActivityVideoKey];
    cell.contentURL = [video url];

    NSDateFormatterStyle dateStyle = NSDateFormatterMediumStyle;
    NSDateFormatterStyle timeStyle = NSDateFormatterShortStyle;
    NSDate *threadUpdatedAt = [activity createdAt];
//    if ([NSDate daysBetweenDate:threadUpdatedAt andDate:[NSDate date]] > 0) {
//        dateStyle = NSDateFormatterShortStyle;
//        timeStyle = NSDateFormatterNoStyle;
//    }

    NSString *timeLabel = [NSDateFormatter localizedStringFromDate:threadUpdatedAt dateStyle:dateStyle timeStyle:timeStyle];

    [imageView sd_setImageWithURL:[NSURL URLWithString:videoThumbUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

        NSLog(@"created a new imageview");

        dispatch_async(dispatch_get_main_queue(), ^{
            [cell setNeedsLayout];
            [cell layoutIfNeeded];
        });

    }];
    [cell setThumbImageView:imageView];


    [cell setUsernameString:sendusername];
    [cell setTimeString:timeLabel];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GVReactionsTableViewCell *cell = (GVReactionsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:GVReactionsTableViewControllerCellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...

    [cell removeAllSubImageViews];


    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PFObject *activity = [self.modelObject reactionsViewControllerDataAtIndexPath:indexPath thread:self.threadId threadIndexPath:self.indexPath];

    PFFile *video = [activity objectForKey:kGVActivityVideoKey];
    NSString *url = [video url];
    NSDictionary *dict = @{@"URL": url};
    [[NSNotificationCenter defaultCenter] postNotificationName:GVPlayMovieNotification object:nil userInfo:dict];
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
