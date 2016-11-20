//
//  SJAssetPickerViewController.m
//  SJAssetPicker
//
//  Created by shejun.zhou on 15/7/4.
//  Copyright (c) 2015年 shejun.zhou. All rights reserved.
//


#import "SJAssetPickerViewController.h"
#import "SJAssetPickerModel.h"

/** @name 获取屏幕 宽度、高度 及 状态栏 高度 */
// @{
#define kSJ_SCREEN_WIDTH  ([UIScreen mainScreen].bounds.size.width)
#define kSJ_SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
// @}end of 获取屏幕 宽度、高度 及 状态栏 高度


@interface SJAssetPickerViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) SJAssetPickerModel *model;                ///< 读取相册model
@property (nonatomic, strong) NSMutableArray *assetsArray;              ///< 当前相册文件夹下的所有照片源
@property (nonatomic, strong) NSMutableArray *selectedAssetsURLString;  ///< 已勾选的照片的URL字符串
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *previewItem;

@end

@implementation SJAssetPickerViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _assetsArray = [[NSMutableArray alloc] init];
    _selectedAssetsURLString = [[NSMutableArray alloc] init];
    _model = [SJAssetPickerModel shareManager];
    _previewItem.hidden = YES;
    for (ALAsset *result in _model.selectedAssetsArrayTemp) {
        [_selectedAssetsURLString addObject:[result defaultRepresentation].url.description];
    }
    [self loadAllPictures];
}

- (void)viewDidDisappear:(BOOL)animated {

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
        for (NSString *p in files) {
            NSError *error;
            NSString *path = [cachPath stringByAppendingPathComponent:p];
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
            }
        }
    });
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_assetsArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellectionViewCellIdentifier" forIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    UIImageView *imgView = (UIImageView *)[cell viewWithTag:101];
    imgView.hidden = YES;
    ALAsset *result = _assetsArray[indexPath.row];
    UIImage *image = [UIImage imageWithCGImage: result.thumbnail];
    imageView.image = image;

    if ([_selectedAssetsURLString containsObject:[result defaultRepresentation].url.description]) {
        imgView.hidden = NO;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ALAsset *result = _assetsArray[indexPath.row];
    if ([_selectedAssetsURLString containsObject:[result defaultRepresentation].url.description]) {
        [_selectedAssetsURLString removeObject:[result defaultRepresentation].url.description];
        for (ALAsset *resultTemp in _model.selectedAssetsArrayTemp) {
            if ([[resultTemp defaultRepresentation].url.description isEqualToString:[result defaultRepresentation].url.description]) {
                [_model.selectedAssetsArrayTemp removeObject:resultTemp];
                break;
            }
        }
    }else {
        [_model.selectedAssetsArrayTemp addObject:result];
        [_selectedAssetsURLString addObject:[result defaultRepresentation].url.description];
    }
    [collectionView reloadData];
    NSLog(@"%@", [result defaultRepresentation].url.description);
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake((kSJ_SCREEN_WIDTH-4)/4.0, (kSJ_SCREEN_WIDTH-4)/4.0);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 1.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}


-(void)loadAllPictures{
    
    void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if(result != nil) {
            if([[result valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
                if (![_assetsArray containsObject:result]) {
                    [_assetsArray addObject:result];
                    [self.collectionView reloadData];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[_assetsArray count]-1 inSection:0];
                    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
                }
            }
        }
    };
    
    void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
        if(group != nil) {
            NSString *strName = [NSString stringWithFormat:@"%@", [group valueForProperty:@"ALAssetsGroupPropertyName"]];
            if ([strName isEqualToString:self.title]) {
                [group enumerateAssetsUsingBlock:assetEnumerator];
            }
        }
    };

    [_model.library enumerateGroupsWithTypes:ALAssetsGroupAll
                            usingBlock:assetGroupEnumerator
                          failureBlock:^(NSError *error) {NSLog(@"There is an error");}];
}

- (IBAction)tappedPreviewButtonAction:(id)sender {
    NSLog(@"tappedPreviewButtonAction");
}

- (IBAction)tappedOKButtonAction:(id)sender {
    _model.selectedAssetsArray = [_model.selectedAssetsArrayTemp mutableCopy];
    [_model.selectedAssetsArrayTemp removeAllObjects];
    [[SJAssetPickerManager shareManager] dismissViewControllerAnimated:_model.selectedAssetsArray];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tappedCancelItemAction:(id)sender {
    [_model.selectedAssetsArrayTemp removeAllObjects];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)tappedPreviewItemAction:(id)sender {
    
}

@end
