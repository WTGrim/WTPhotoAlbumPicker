//
//  PhotoPreviewCell.h
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/5/3.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PhotoSelectModel;
@class PHAsset;

typedef void(^SelectBtnBlock)(NSArray<PhotoSelectModel *> *selectPhotos);
@interface PhotoPreviewCell : UICollectionViewCell

@property(nonatomic, copy)SelectBtnBlock selectBtnBlock;

- (void)setCellWithAsset:(PHAsset *)asset selectPhotos:(NSArray <PhotoSelectModel *> *)selectPhotos maxSelectCount:(NSInteger)maxSelectCount indexPath:(NSIndexPath *)indexPath;

@end
