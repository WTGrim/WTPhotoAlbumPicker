//
//  PhotoAlbumCommonModel.h
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/4/27.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>


@interface PhotoAlbumCommonModel : NSObject

@end


@interface PhotoSelectModel : NSObject

@property(nonatomic, copy)NSString *localIdentifier;
@property(nonatomic, strong)PHAsset *asset;

@end
