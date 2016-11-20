//
//  SJAssetPickerManager.h
//  SJAssetPicker
//
//  Created by zhoushejun on 2016/11/4.
//  Copyright © 2016年 shejun.zhou. All rights reserved.
//

/**
 @header    SJAssetPickerManager.h
 @abstract  选择照片管理者，提供对外的接口
 @author    shejun.zhou
 @version   1.0 15/7/4 Creation
 */

#import <Foundation/Foundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

@class UIViewController;

/** 选择照片完成时回调block */
typedef void(^SelectedAssetsBlock)(NSArray *array);

/**
 @class     SJAssetPickerManager
 @abstract  选择照片管理者
 */
@interface SJAssetPickerManager : NSObject

/**
 @method    shareManager
 @abstract  选择照片管理者单例方法
 */
+ (SJAssetPickerManager *)shareManager;

/**
 @method    isAuthorized
 @abstract  判断是否授权方法，包括第一次时系统弹出窗口和以后的自定义弹出窗口
 @return    YES : 已授权 NO : 未授权
 */
- (BOOL)isAuthorized;

/**
 @method    presentToViewController: completionHandler:
 @abstract  弹出选择照片界面方法
 @param     viewController : 弹出层所在对象 即 从哪个 viewController 里弹出
 @param     handler : 选择照片完成时的回调block
 */
- (void)presentToViewController:(UIViewController *)viewController handler:(SelectedAssetsBlock)block;

/**
 @method    deleteSelectedAssetsIndex: completionHandler:
 @abstract  删除选择的下标的照片
 @param     index : 下标
 @param     completion : 删除完成时的回调block
 */
- (void)deleteSelectedAssetsIndex:(NSInteger)index completionHandler:(void(^)(void))completion;

@end
