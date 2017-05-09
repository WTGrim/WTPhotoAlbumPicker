//
//  PhotoDetailViewController.h
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/5/5.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class PhotoSelectModel;

typedef void(^BackBtnBlock)(NSArray<PhotoSelectModel *>* selectPhotos, BOOL isSelectOrigin);
typedef void(^CompletedBtnBlock)(NSArray<PhotoSelectModel *>* selectPhotos, BOOL isSelectOrigin);
@interface PhotoDetailViewController : UIViewController

@property(nonatomic, assign)NSInteger selectIndex;
@property(nonatomic, assign)BOOL isSelectedOrigin;

@property(nonatomic, assign)NSInteger maxSelectCount;
@property(nonatomic, strong)NSArray <PHAsset *> *asset;
@property(nonatomic, strong)NSMutableArray <PhotoSelectModel *> *selectPhotos;
@property(nonatomic, copy)BackBtnBlock backBtnBlock;
@property(nonatomic, copy)CompletedBtnBlock completedBtnBlock;

@end
