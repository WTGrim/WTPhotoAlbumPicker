//
//  PhotoPreviewController.m
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/4/28.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "PhotoAlbumListController.h"
#import "PhotoAlbumTool.h"

@interface PhotoAlbumListController ()

@property(nonatomic, strong)NSMutableArray<AlbumList *> *dataArray;

@end

@implementation PhotoAlbumListController

- (NSMutableArray<AlbumList *> *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI{
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
}


@end
