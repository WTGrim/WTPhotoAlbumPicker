//
//  PhotoPreviewController.h
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/4/28.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PhotoSelectModel;
typedef void(^CompletedBlock)(NSArray<PhotoSelectModel *> *selectedPhotos, BOOL isSeletedOrigin);
typedef void(^CancelBlock)();
@interface PhotoAlbumListController : UITableViewController

@property(nonatomic, assign)NSInteger maxSelectCount;
@property(nonatomic, assign)BOOL isSelectOrigin;
@property(nonatomic, strong)NSMutableArray<PhotoSelectModel *> *selectPhotos;
@property(nonatomic, copy)CancelBlock cancelBlock;
@property(nonatomic, copy)CompletedBlock completedBlock;

@end

@interface AlbumListCell : UITableViewCell

@property(nonatomic, strong)UIImageView *headImageView;
@property(nonatomic, strong)UILabel *titleInfo;
@property(nonatomic, strong)UILabel *count;

@end
