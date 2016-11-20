//
//  SJAssetPickerManager.m
//  SJAssetPicker
//
//  Created by zhoushejun on 2016/11/4.
//  Copyright © 2016年 shejun.zhou. All rights reserved.
//

#import "SJAssetPickerManager.h"
#import "SJAssetPickerModel.h"
#import "SJAssetGroupsTableViewController.h"


@interface SJAssetPickerManager ()

@property (nonatomic, strong) SelectedAssetsBlock assetsBlock;

@end

@implementation SJAssetPickerManager

+ (SJAssetPickerManager *)shareManager {
    static SJAssetPickerManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {

    }
    return self;
}


- (BOOL)isAuthorized {
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if (authStatus == ALAuthorizationStatusRestricted ||
        authStatus == ALAuthorizationStatusDenied){//无权限
        UIAlertAction *cancleAlertAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点击拒绝");
        }];
        UIAlertAction *okAlertAction = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"点击去设置");
            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url];
            }
        }];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"温馨提示"
                                                                                 message:@"添加照片需要得到您的授权"
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:cancleAlertAction];
        [alertController addAction:okAlertAction];
        UIWindow *win = [UIApplication sharedApplication].keyWindow;
        [win.rootViewController presentViewController:alertController animated:YES completion:nil];
        return NO;
    }
    
    return YES;
}

- (void)presentToViewController:(UIViewController *)viewController handler:(SelectedAssetsBlock)block{
    if (block) {
        _assetsBlock = block;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"SJAssetPicker" bundle:nil];
    UINavigationController *groupsVC = [storyboard instantiateViewControllerWithIdentifier:@"SJAssetPickerNavigationController"];
    [viewController presentViewController:groupsVC animated:YES completion:nil];
}

- (void)dismissViewControllerAnimated: (NSArray *)selectedAssets {
    if (_assetsBlock) {
        _assetsBlock(selectedAssets);
    }
}

- (void)deleteSelectedAssetsIndex:(NSInteger)index completionHandler:(void(^)(void))completion {
    [[SJAssetPickerModel shareManager] deleteSelectedAssetsIndex:index];
    if (completion) {
        completion();
    }
}

@end
