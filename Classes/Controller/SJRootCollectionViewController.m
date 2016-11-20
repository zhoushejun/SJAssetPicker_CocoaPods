//
//  SJRootCollectionViewController.m
//  SJAssetPicker
//
//  Created by shejun.zhou on 15/7/4.
//  Copyright (c) 2015年 shejun.zhou. All rights reserved.
//

#import "SJRootCollectionViewController.h"
#import "SJAssetPickerManager.h"

@interface SJRootCollectionViewController ()

@property (nonatomic, strong) NSMutableArray *arrayAssets; ///< 已选择的照片，界面展示的数据源

@end

@implementation SJRootCollectionViewController

static NSString * const SJCollectionViewPhotoCellReuseIdentifier = @"SJCollectionViewPhotoCell";
static NSString * const SJCollectionViewAddCellReuseIdentifier = @"SJCollectionViewAddCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    
    // Register cell classes
    _arrayAssets = [[NSMutableArray alloc] init];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_arrayAssets count] + 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = nil;
    if (indexPath.row == _arrayAssets.count) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:SJCollectionViewAddCellReuseIdentifier forIndexPath:indexPath];

    }else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:SJCollectionViewPhotoCellReuseIdentifier forIndexPath:indexPath];
        ALAsset *result = [_arrayAssets objectAtIndex:indexPath.row];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
        imageView.image = [UIImage imageWithCGImage:result.thumbnail];
    }
    
    // Configure the cell
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == _arrayAssets.count) {
        SJAssetPickerManager *assetPickerManager = [SJAssetPickerManager shareManager];
        if ([assetPickerManager isAuthorized]) {
            __weak typeof(self) weakSelf = self;
            [assetPickerManager presentToViewController:self handler:^(NSArray *array) {
                [weakSelf.arrayAssets removeAllObjects];
                weakSelf.arrayAssets = [[NSMutableArray alloc] initWithArray:array];
                [weakSelf.collectionView reloadData];
            }];
        }
    }
    else {
        __weak typeof(self) weakSelf = self;
        [[SJAssetPickerManager shareManager] deleteSelectedAssetsIndex:indexPath.row completionHandler:^{
            [weakSelf.arrayAssets removeObjectAtIndex:indexPath.row];
            NSArray *paths = [NSArray arrayWithObject:[NSIndexPath indexPathForItem:indexPath.row inSection:indexPath.section]];
            [weakSelf.collectionView performBatchUpdates:^{
                [weakSelf.collectionView deleteItemsAtIndexPaths:paths];
            } completion:^(BOOL finished) {
                [weakSelf.collectionView reloadData];
            }];
        }];
    }
}

#pragma mark - private


@end
