//
//  PhotoAlertSheet.h
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/4/28.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoSelectModel;
@interface PhotoAlertSheet : UIView

@property(nonatomic, weak)UIViewController *root;
@property(nonatomic, assign)NSInteger maxAllowedSelectCount;
@property(nonatomic, assign)NSInteger maxPreviewCount;

//提供全部图片的选择
- (void)showPhotosInAllAlbumWithRoot:(UIViewController *)root lastSelectedModels:(NSArray <PhotoSelectModel *>*)lastSeletedModels completed:(void(^)(NSArray <UIImage *>* photos, NSArray <PhotoSelectModel *>* selectedModels))completed;
//提供部分预览图片
- (void)showPreviewPhotosWithRoot:(UIViewController *)root lastSelectedModels:(NSArray <PhotoSelectModel *>*)lastSeletedModels completed:(void(^)(NSArray <UIImage *>* photos, NSArray <PhotoSelectModel *>* selectedModels))completed;

@end


@interface PhotoNavigateController : UINavigationController

@property(nonatomic, assign)UIStatusBarStyle previousStatusBarStyle;

@end
