//
//  PhotoAlbumTool.m
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/4/25.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "PhotoAlbumTool.h"
#import "PhotoAlbumPickerDefine.h"
#import "PhotoAlbumCommonModel.h"


@implementation AlbumList


@end


@implementation PhotoAlbumTool


+ (instancetype)shareInstance{
    
    static PhotoAlbumTool *photoAlbumTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        photoAlbumTool = [[PhotoAlbumTool alloc]init];
    });
    return photoAlbumTool;
}

- (void)saveImageToAlbum:(UIImage *)image compeletd:(void (^)(BOOL, PHAsset *))completed{
    
//    PHAuthorizationStatus stauts = [PHPhotoLibrary authorizationStatus];

}

#pragma mark - 获取专辑列表
- (NSArray<AlbumList *> *)getAlbumList{
    
    NSMutableArray <AlbumList *>*listArr = [NSMutableArray array];
    PHFetchResult *userAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbum enumerateObjectsUsingBlock:^(PHAssetCollection *  _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSArray <PHAsset *>*asset = [self getPhotosInAsset:collection timeAsc:NO];
        if (asset.count > 0) {
            AlbumList *list = [[AlbumList alloc]init];
            list.title = collection.localizedTitle;
            list.photoCount = asset.count;
            list.firstImageAsset = asset.firstObject;
            list.assetCollection = collection;
            [listArr addObject:list];
        }
    }];
    
    PHFetchResult *smartAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smartAlbum enumerateObjectsUsingBlock:^(PHAssetCollection *  _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
       
        if (collection.assetCollectionSubtype != 202 || collection.assetCollectionSubtype < 212) {//视频和最近删除除外
            NSArray <PHAsset *>* asset = [self getPhotosInAsset:collection timeAsc:NO];
            AlbumList *list = [[AlbumList alloc]init];
            list.title = collection.localizedTitle;
            list.photoCount = asset.count;
            list.firstImageAsset = asset.firstObject;
            list.assetCollection = collection;
            [listArr addObject:list];
        }
    }];
    return listArr;
}

#pragma mark - 获取全部照片
- (NSArray<PHAsset *> *)getAllPhotosWithTimeAsc:(BOOL)timeAsc{
    
    NSMutableArray <PHAsset *> *assets = [NSMutableArray array];
    PHFetchOptions *option = [[PHFetchOptions alloc]init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:timeAsc]];
    PHFetchResult *result = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:option];
    [result enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset *asset = (PHAsset *)obj;
        [assets addObject:asset];
    }];
    return assets;
}


#pragma mark - 获取指定专辑里的照片
- (NSArray<PHAsset *> *)getPhotosInAsset:(PHAssetCollection *)collection timeAsc:(BOOL)timeAsc{
    
    NSMutableArray <PHAsset *>*asset = [NSMutableArray array];
    PHFetchResult *result = [self getAssetsInCollection:collection timeAsc:timeAsc];
    [result enumerateObjectsUsingBlock:^(PHAsset *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.mediaType == PHAssetMediaTypeImage) {
            [asset addObject:obj];
        }
    }];
    return asset;
}

#pragma mark - 获取asset对应的相片
- (void)getImageByAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completed:(void (^)(UIImage *, NSDictionary *))completed{
    
    static PHImageRequestID requestID = -1;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = MIN(ScreenWidth, kMaxImageWidth);
    //取消上一张图片的请求，节省流量
    if (requestID >= 1 && size.width / width == scale) {
        [[PHCachingImageManager defaultManager]cancelImageRequest:requestID];
    }
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.resizeMode = resizeMode;
    options.networkAccessAllowed = true;
    
    requestID = [[PHCachingImageManager defaultManager]requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
       
        BOOL success = ![info objectForKey:PHImageCancelledKey] && ![info objectForKey:PHImageErrorKey];
        if (success && completed) {
            completed(image, info);
        }
    }];
}

#pragma mark - 点击确定获取对应的相片
- (void)getImageByAsset:(PHAsset *)asset scale:(CGFloat)scale resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completed:(void (^)(UIImage *))completed{
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.resizeMode = resizeMode;
    options.networkAccessAllowed = true;
    [[PHCachingImageManager defaultManager]requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
       
        BOOL success = ![info objectForKey:PHImageCancelledKey] && ![info objectForKey:PHImageErrorKey] && ![info objectForKey:PHImageResultIsDegradedKey];
        if (success && completed) {
            CGFloat length = imageData.length / (CGFloat)UIImageJPEGRepresentation([UIImage imageWithData:imageData], 1).length;
            NSData *data = UIImageJPEGRepresentation([UIImage imageWithData:imageData], scale == 1?length:length * 0.5);
            completed([UIImage imageWithData:data]);
        }
    }];
}


#pragma mark - 获取选中相片大小
- (void)getPhotosBytes:(NSArray *)photos completed:(void (^)(NSString *))completed{
    
    __block NSInteger storage = 0;
    __block NSInteger count = photos.count;
    weakify(self);
    for (int i = 0; i < photos.count; i++) {
        PhotoSelectModel *model = [[PhotoSelectModel alloc]init];
        [[PHCachingImageManager defaultManager]requestImageDataForAsset:model.asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
            strongify(weakSelf);
            storage += imageData.length;
            count -- ;
            if (count <= 0) {
                if (completed) {
                    completed([strongSelf translateLength:storage]);
                }
            }
        }];
    }
}


- (BOOL)isLocalForAsset:(PHAsset *)asset{
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc]init];
    options.networkAccessAllowed = NO;
    options.synchronous = YES;
    __block BOOL isLocal = YES;
    [[PHCachingImageManager defaultManager]requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        isLocal = imageData ? YES : NO;
    }];
    return isLocal;
}

- (NSString *)translateLength:(NSInteger)length{
    
    NSString *bytes = @"";
    if (length >= 0.1 * (1024 * 1024)) {
        bytes = [NSString stringWithFormat:@"%.1fM", length / (1024 * 1024.0)];
    }else if(length >= 1024){
        bytes = [NSString stringWithFormat:@"%.0fK", length / 1024.0];
    }else{
        bytes = [NSString stringWithFormat:@"%zdB", length];
    }
    return bytes;
}

- (PHFetchResult *)getAssetsInCollection:(PHAssetCollection *)collection timeAsc:(BOOL)timeAsc{
    
    PHFetchOptions *option = [[PHFetchOptions alloc]init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:timeAsc]];
    PHFetchResult *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
    return result;
}

@end
