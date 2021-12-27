//
//  TZAssetModel.m
//  TZImagePickerController
//
//  Created by 谭真 on 15/12/24.
//  Copyright © 2015年 谭真. All rights reserved.
//

#import "TZAssetModel.h"
#import "TZImageManager.h"

@implementation TZAssetModel

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(TZAssetModelMediaType)type{
    TZAssetModel *model = [[TZAssetModel alloc] init];
    model.asset = asset;
    model.isSelected = NO;
    model.type = type;
    model.isHidden = model.asset.isHidden;
    model.isFavorite = model.asset.isFavorite;
    return model;
}

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(TZAssetModelMediaType)type timeLength:(NSString *)timeLength {
    TZAssetModel *model = [self modelWithAsset:asset type:type];
    model.timeLength = timeLength;
    return model;
}

- (BOOL)isEdit {
    return [NSFileManager.defaultManager fileExistsAtPath:self.thumbPath];
}

- (UIImage *)thumbImage {
    if (_thumbImage == nil && self.isEdit) {
        _thumbImage = [UIImage imageWithContentsOfFile:self.thumbPath];
    }
    return _thumbImage;
}

- (NSString *)thumbPath {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg", [self.asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"_"]]];
}

- (NSString *)jsonPath {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json", [self.asset.localIdentifier stringByReplacingOccurrencesOfString:@"/" withString:@"_"]]];
}

@end



@implementation TZAlbumModel

- (void)setResult:(PHFetchResult *)result needFetchAssets:(BOOL)needFetchAssets {
    _result = result;
    if (needFetchAssets) {
        [[TZImageManager manager] getAssetsFromFetchResult:result completion:^(NSArray<TZAssetModel *> *models) {
            self->_models = models;
            if (self->_selectedModels) {
                [self checkSelectedModels];
            }
        }];
    }
}

- (void)refreshFetchResult {
    PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:self.collection options:self.options];
    self.count = fetchResult.count;
    [self setResult:fetchResult];
}

- (void)setSelectedModels:(NSArray *)selectedModels {
    _selectedModels = selectedModels;
    if (_models) {
        [self checkSelectedModels];
    }
}

- (void)checkSelectedModels {
    self.selectedCount = 0;
    NSMutableSet *selectedAssets = [NSMutableSet setWithCapacity:_selectedModels.count];
    for (TZAssetModel *model in _selectedModels) {
        [selectedAssets addObject:model.asset];
    }
    for (TZAssetModel *model in _models) {
        if ([selectedAssets containsObject:model.asset]) {
            self.selectedCount ++;
        }
    }
}

- (NSString *)name {
    if (_name) {
        return _name;
    }
    return @"";
}

@end
