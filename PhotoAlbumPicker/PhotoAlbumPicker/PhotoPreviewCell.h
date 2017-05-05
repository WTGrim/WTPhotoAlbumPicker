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

@interface PhotoPreviewCell : UICollectionViewCell

@property(nonatomic, strong)UIImageView *headImageView;
@property(nonatomic, strong)UIButton *selectBtn;


@end
