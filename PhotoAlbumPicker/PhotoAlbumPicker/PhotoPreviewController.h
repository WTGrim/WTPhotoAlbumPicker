//
//  PhotoPreviewController.h
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/5/2.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhotoSelectModel;
@class PHAssetCollection;
@class PhotoAlbumListController;

typedef void(^CompletedBlock)(NSArray<PhotoSelectModel *> *selectedPhotos, BOOL isSeletedOrigin);
typedef void(^CancelBlock)();

@interface PhotoPreviewController : UIViewController

@property(nonatomic, strong)NSMutableArray<PhotoSelectModel *> *selectedPhotos;
@property(nonatomic, assign)NSInteger maxSelectedCount;
@property(nonatomic, strong)PHAssetCollection *assetCollection;
@property(nonatomic, assign)BOOL isSelectedOrigin;
@property(nonatomic, weak)PhotoAlbumListController *listVC;
@property(nonatomic, copy)CompletedBlock completedBlock;
@property(nonatomic, copy)CancelBlock cancelBlock;

@end
