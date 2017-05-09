//
//  PhotoDetailCell.h
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/5/6.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PHAsset;
@interface PhotoDetailCell : UICollectionViewCell

@property(nonatomic, strong)PHAsset *asset;
@property(nonatomic, copy)void (^tapBlock)();

@end
