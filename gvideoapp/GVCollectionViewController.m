//
//  GVCollectionViewController.m
//  gvideoapp
//
//  Created by Gaurav Khanna on 6/9/14.
//  Copyright (c) 2014 Gapps. All rights reserved.
//

#import "GVCollectionViewController.h"
#import "GVThreadBackgroundView.h"
#import "GVCollectionViewCell.h"
#import "GVSectionHeaderView.h"

NSString *const GVCollectionViewControllerCellIdentifier = @"GVCollectionViewControllerCellIdentifier";
NSString *const GVCollectionViewControllerSectionHeaderViewIdentifier = @"GVCollectionViewControllerSectionHeaderViewIdentifier";

@interface GVCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionViewFlowLayout *portraitLayout;
@property (nonatomic, strong) UICollectionViewFlowLayout *landscapeLayout;

@end

@implementation GVCollectionViewController

- (instancetype)initWithCollectionViewLayout:(UICollectionViewLayout *)layout {
    self = [super initWithCollectionViewLayout:layout];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.navigationBarHidden = YES;

    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.backgroundView = [GVThreadBackgroundView new];
    self.collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.collectionView.translatesAutoresizingMaskIntoConstraints = NO;

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.portraitLayout.itemSize = CGSizeMake(self.collectionView.frame.size.width, 500);
        self.landscapeLayout = [[UICollectionViewFlowLayout alloc] init];
        self.landscapeLayout.itemSize = CGSizeMake(703, 300);
    } else {
        self.portraitLayout.itemSize = CGSizeMake(self.collectionView.frame.size.width, 320);
        self.landscapeLayout = [[UICollectionViewFlowLayout alloc] init];
        self.landscapeLayout.itemSize = CGSizeMake(self.collectionView.frame.size.height, 320);
    }

    [self.collectionView registerClass:[GVCollectionViewCell class] forCellWithReuseIdentifier:GVCollectionViewControllerCellIdentifier];
    [self.collectionView registerClass:[GVSectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:GVCollectionViewControllerSectionHeaderViewIdentifier];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Collection View Data Source


- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    GVSectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:GVCollectionViewControllerSectionHeaderViewIdentifier forIndexPath:indexPath];

    return headerView;
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GVCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:GVCollectionViewControllerCellIdentifier forIndexPath:indexPath];

    return cell;
}

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
