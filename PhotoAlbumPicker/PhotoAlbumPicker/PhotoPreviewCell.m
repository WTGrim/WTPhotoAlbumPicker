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

@end

@implementation PhotoPreviewCell


- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setup];
    }
    return self;
}

- (void)setup{
    
    self.headImageView = [UIImageView new];
    self.headImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.headImageView.clipsToBounds = true;
    [self.contentView addSubview:self.headImageView];
    
    self.selectBtn = [UIButton new];
    [self.contentView addSubview:self.selectBtn];
    
    [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"btn_unselected"] forState:UIControlStateNormal];
    [self.selectBtn setBackgroundImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateSelected];
    self.selectBtn.selected = NO;

}


- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.headImageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.selectBtn.frame = CGRectMake(CGRectGetWidth(self.frame) - 25 - kMinMargin, kMinMargin, 25, 25);
}


@end
