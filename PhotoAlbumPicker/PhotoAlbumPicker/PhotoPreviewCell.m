//
//  PhotoPreviewCell.m
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/5/3.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "PhotoPreviewCell.h"
#import "PhotoAlbumTool.h"
#import "PhotoAlbumPickerDefine.h"
#import "PhotoAlbumCommonModel.h"

#define kMinMargin 5
#define kAddTag 100
@interface PhotoPreviewCell ()

@property(nonatomic, strong)UIImageView *headImageView;
@property(nonatomic, strong)UIButton *selectBtn;
@property(nonatomic, strong)NSMutableArray<PhotoSelectModel *> *selectedPhotos;
@property(nonatomic, assign)NSInteger maxSelectedCount;
@property(nonatomic, strong)PHAsset *asset;

@end

@implementation PhotoPreviewCell

- (NSMutableArray<PhotoSelectModel *> *)selectedPhotos{
    if (!_selectedPhotos) {
        _selectedPhotos = [NSMutableArray array];
    }
    return _selectedPhotos;
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    self.headImageView = [UIImageView new];
    self.headImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.headImageView.clipsToBounds = true;
    [self.contentView addSubview:self.headImageView];
    
    self.selectBtn = [UIButton new];
    [self.contentView addSubview:self.selectBtn];
    [self.selectBtn setImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
    [self.selectBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateSelected];
    [self.selectBtn addTarget:self action:@selector(selectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setCellWithAsset:(PHAsset *)asset selectPhotos:(NSArray<PhotoSelectModel *> *)selectPhotos maxSelectCount:(NSInteger)maxSelectCount indexPath:(NSIndexPath *)indexPath{
    
    self.selectedPhotos = self.selectedPhotos.mutableCopy;
    self.maxSelectedCount = maxSelectCount;
    self.asset = asset;
    
    self.selectBtn.selected = NO;
    CGSize size = self.frame.size;
    size.width *= 2.5;
    size.height *= 2.5;
    weakify(self);
    [[PhotoAlbumTool shareInstance]getImageByAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeExact completed:^(UIImage *image, NSDictionary *info) {
        strongify(weakSelf);
        strongSelf.headImageView.image = image;
        for (PhotoSelectModel *model in selectPhotos) {
            if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
                strongSelf.selectBtn.selected = YES;
                break;
            }
        }
    }];
    self.selectBtn.tag = indexPath.row + kAddTag;
}

- (void)selectBtnAction:(UIButton *)btn{
    
    if (_selectedPhotos.count > self.maxSelectedCount && btn.selected == false) {
        NSLog(@"最大选择数为%ld", self.maxSelectedCount);
        return;
    }
    
    if (!btn.selected) {
        [btn.layer addAnimation:GetSelectBtnAnimation() forKey:nil];
        if (![[PhotoAlbumTool shareInstance]isLocalForAsset:self.asset]) {
            NSLog(@"%@", GetLocalziedString(PhotoAlbumPickeriCloudPhoto));
            return;
        }
        PhotoSelectModel *model = [[PhotoSelectModel alloc]init];
        model.asset = self.asset;
        model.localIdentifier = self.asset.localIdentifier;
        [self.selectedPhotos addObject:model];

    }else{
        for (PhotoSelectModel *model in self.selectedPhotos) {
            if ([model.localIdentifier isEqualToString:self.asset.localIdentifier]) {
                [self.selectedPhotos removeObject:model];
                break;
            }
        }
    }
    btn.selected = !btn.selected;
    if (_selectBtnBlock) {
        _selectBtnBlock(self.selectedPhotos);
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.headImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.selectBtn.frame = CGRectMake(CGRectGetWidth(self.frame) - 30 - kMinMargin, kMinMargin, 30, 30);
}


@end
