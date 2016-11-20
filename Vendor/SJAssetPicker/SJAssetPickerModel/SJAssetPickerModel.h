//
//  SJAssetPickerModel.h
//  SJAssetPicker
//
//  Created by shejun.zhou on 15/7/20.
//  Copyright (c) 2015年 shejun.zhou. All rights reserved.
//

/**
 @file      SJAssetPickerModel.h
 @abstract  读取相册model，同步已选择的相片对象
 @author    shejun.zhou
 @version   1.0 15/7/20 Creation
 */
#import <Foundation/Foundation.h>
#import "SJAssetPickerManager.h"

/**
 @class     SJAssetPickerModel
 @abstract  读取相册model
 */
@interface SJAssetPickerModel : NSObject

@property (nonatomic, strong) NSMutableArray *selectedAssetsArray;      ///< 确认选择的照片
@property (nonatomic, strong) NSMutableArray *selectedAssetsArrayTemp;  ///< 临时选择的照片
@property (nonatomic, strong) ALAssetsLibrary *library;                 ///< 相册库对象

/**
 @method    shareManager
 @abstract  读取相册管理者单例方法
 */
+ (SJAssetPickerModel *)shareManager;

/**
 @method    deleteSelectedAssetsIndex
 @abstract  删除选择的下标的照片
 @param     index : 下标
 */
- (void)deleteSelectedAssetsIndex:(NSInteger)index;

@end


// 选择照片管理者类别，添加一个从选择照片界面选择完成后返回时的回调方法
@interface SJAssetPickerManager (SJAssetPickerModel)

/**
 @method    dismissViewControllerAnimated
 @abstract  选择照片完成后视图移除时的回调方法
 @param     selectedAssets : 已选择的照片
 */
- (void)dismissViewControllerAnimated: (NSArray *)selectedAssets;

@end
