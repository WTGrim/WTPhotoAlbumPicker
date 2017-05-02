//
//  PhotoAlbumTool.h
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/4/25.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>


@interface AlbumList : NSObject
/**相册名字*/
@property(nonatomic, strong)NSString *title;
/**相片数量*/
@property(nonatomic, assign)NSInteger photoCount;
/**第一张*/
@property(nonatomic, strong)PHAsset *firstImageAsset;
/**相册集*/
@property(nonatomic, strong)PHAssetCollection *assetCollection;

@end

@interface PhotoAlbumTool : NSObject

+ (instancetype)shareInstance;
//保存图片
- (void)saveImageToAlbum:(UIImage *)image compeletd:(void(^)(BOOL success, PHAsset *asset))completed;
//获取相册列表
- (NSArray <AlbumList *>*)getAlbumList;
//获取全部照片
- (NSArray <PHAsset *>*)getAllPhotosWithTimeAsc:(BOOL)timeAsc;
//获取专辑对应的全部照片
- (NSArray <PHAsset *>*)getPhotosInAsset:(PHAssetCollection *)collection timeAsc:(BOOL)timeAsc;

- (void)getImageByAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completed:(void(^)(UIImage *image, NSDictionary *info))completed;
- (void)getImageByAsset:(PHAsset *)asset scale:(CGFloat)scale resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completed:(void(^)(UIImage *image))completed;
- (void)getPhotosBytes:(NSArray *)photos completed:(void(^)(NSString *bytes))completed;
- (BOOL)isLocalForAsset:(PHAsset *)asset;

@end
