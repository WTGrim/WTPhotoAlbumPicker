//
//  PhotoDetailCell.m
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/5/6.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "PhotoDetailCell.h"
#import "PhotoAlbumTool.h"
#import <Photos/Photos.h>
#import "PhotoAlbumPickerDefine.h"

@interface PhotoDetailCell ()<UIScrollViewDelegate>

@property(nonatomic, strong)UIView *containerView;
@property(nonatomic, strong)UIScrollView *scrollView;
@property(nonatomic, strong)UIImageView *detailImageView;
@property(nonatomic, strong)UIActivityIndicatorView *indicator;

@end

@implementation PhotoDetailCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    [self.contentView addSubview:self.scrollView];
    [self.scrollView addSubview:self.containerView];
    [self.scrollView addSubview:self.detailImageView];
    [self.contentView addSubview:self.indicator];
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        _scrollView.maximumZoomScale = 3.0;
        _scrollView.minimumZoomScale = 1.0;
        _scrollView.multipleTouchEnabled = true;
        _scrollView.delegate = self;
        _scrollView.scrollsToTop = false;
        _scrollView.showsHorizontalScrollIndicator = false;
        _scrollView.showsVerticalScrollIndicator = false;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(singleTapAction:)];
        [_scrollView addGestureRecognizer:singleTap];
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        [_scrollView addGestureRecognizer:doubleTap];
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return _scrollView;
}

- (UIView *)containerView{
    if (!_containerView) {
        _containerView = [[UIView alloc]init];
    }
    return _containerView;
}

- (UIImageView *)detailImageView{
    if (!_detailImageView) {
        _detailImageView = [[UIImageView alloc]init];
        _detailImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _detailImageView;
}

- (UIActivityIndicatorView *)indicator{
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.hidesWhenStopped = true;
        _indicator.center = self.contentView.center;
    }
    return _indicator;
}

- (void)setAsset:(PHAsset *)asset{
    _asset = asset;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat width = MIN(ScreenWidth, kMaxImageWidth);
    CGSize size = CGSizeMake(width * scale, width * scale * asset.pixelHeight / asset.pixelWidth);
    
    [self.indicator startAnimating];
    weakify(self);
    [[PhotoAlbumTool shareInstance] getImageByAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast completed:^(UIImage *image, NSDictionary *info) {
        strongify(weakSelf);
        strongSelf.detailImageView.image = image;
        [strongSelf setSubviewFrame];
        if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
            [strongSelf.indicator stopAnimating];
        }
    }];
}

- (void)setSubviewFrame{
    
    CGRect rect = CGRectZero;
    UIImage *image = self.detailImageView.image;
    CGFloat imageRatio = image.size.height / image.size.width;
    CGFloat screenRatio = ScreenHeight / ScreenWidth;
    if (image.size.width <= CGRectGetWidth(self.frame) && image.size.height <= CGRectGetHeight(self.frame)) {
        rect.size.width = image.size.width;
        rect.size.height = image.size.height;
    }else{
        if (imageRatio > screenRatio) {
            rect.size.width = self.frame.size.height / imageRatio;
            rect.size.height = self.frame.size.height;
        }else{
            rect.size.width = self.frame.size.width;
            rect.size.height = self.frame.size.width * imageRatio;
        }
    }
    
    self.scrollView.zoomScale = 1;
    self.scrollView.contentSize = rect.size;
    [self.scrollView scrollRectToVisible:self.bounds animated:false];
    self.containerView.frame = rect;
    self.containerView.center = self.scrollView.center;
    self.detailImageView.frame = self.containerView.frame;    
}

- (void)singleTapAction:(UITapGestureRecognizer *)singleTap{
    if (self.tapBlock) {
        self.tapBlock();
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)doubleTap{
    
    UIScrollView *scrollView = (UIScrollView *)doubleTap.view;
    CGFloat scale = 1.0;
    if (scrollView.zoomScale != 3) {
        scale = 3;
    }else{
        scale = 1;
    }
    CGRect zoom = [self zoomWithScale:scale center:[doubleTap locationInView:doubleTap.view]];
    [scrollView zoomToRect:zoom animated:true];
}

- (CGRect)zoomWithScale:(CGFloat)scale center:(CGPoint)center{
    
    CGRect zoom ;
    zoom.size.height = self.scrollView.frame.size.height / scale;
    zoom.size.width = self.scrollView.frame.size.width / scale;
    zoom.origin.x = center.x - (zoom.size.width * 0.5);
    zoom.origin.y = center.y - (zoom.size.height * 0.5);
    return zoom;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return scrollView.subviews[0];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    CGFloat offsetX = scrollView.frame.size.width > scrollView.contentSize.width?(scrollView.frame.size.width - scrollView.contentSize.width) * 0.5 :0.0;
    CGFloat offsetY = scrollView.frame.size.height > scrollView.contentSize.height ? (scrollView.frame.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    self.containerView.center = CGPointMake(scrollView.contentSize.width * .5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    self.detailImageView.frame = self.containerView.frame;
}

@end
