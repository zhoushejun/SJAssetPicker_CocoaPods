//
//  SJAssetPickerModel.m
//  SJAssetPicker
//
//  Created by shejun.zhou on 15/7/20.
//  Copyright (c) 2015年 shejun.zhou. All rights reserved.
//

#import "SJAssetPickerModel.h"

@implementation SJAssetPickerModel


+ (SJAssetPickerModel *)shareManager {
    static SJAssetPickerModel *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[[self class] alloc] init];
    });
    return manager;
}

- (instancetype)init {
    if (self = [super init]) {
        _selectedAssetsArray = [[NSMutableArray alloc] init];
        _selectedAssetsArrayTemp = [[NSMutableArray alloc] init];
        _library = [[ALAssetsLibrary alloc] init];
    }
    return self;
}

- (void)deleteSelectedAssetsIndex:(NSInteger)index {
    if (index < [_selectedAssetsArray count]) {
        [_selectedAssetsArray removeObjectAtIndex:index];
    }
    
    if ([_selectedAssetsArray count] == 0) {
        [_selectedAssetsArray removeAllObjects];
        [_selectedAssetsArrayTemp removeAllObjects];
    }
}

@end
