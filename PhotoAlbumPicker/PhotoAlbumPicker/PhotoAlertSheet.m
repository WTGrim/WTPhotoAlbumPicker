//
//  PhotoAlertSheet.m
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/4/28.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "PhotoAlertSheet.h"
#import "PhotoAlbumPickerDefine.h"
#import  <Photos/Photos.h>
#import <objc/runtime.h>

typedef void(^CallBack)(NSArray <UIImage *>* photos, NSArray <PhotoSelectModel *>* selectedModels);

@interface PhotoAlertSheet ()<UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPhotoLibraryChangeObserver, CAAnimationDelegate>

@property(nonatomic, copy)CallBack callBack;
@property(nonatomic, assign)BOOL preview;
@property(nonatomic, assign)BOOL animate;
@property(nonatomic, assign)UIStatusBarStyle previousStatusBarStyle;
@property(nonatomic, strong)NSMutableArray<PhotoSelectModel *> *seletedPhotos;
@property(nonatomic, strong)NSMutableArray<PHAsset *> *assetDataSource;
@property(nonatomic, assign)BOOL isSelectedOriginPhoto;

@end

@implementation PhotoAlertSheet

- (NSMutableArray<PhotoSelectModel *> *)seletedPhotos{
    if (!_seletedPhotos) {
        _seletedPhotos = [NSMutableArray array];
    }
    return _seletedPhotos;
}

- (NSMutableArray<PHAsset *> *)assetDataSource{
    if (_assetDataSource) {
        _assetDataSource = [NSMutableArray array];
    }
    return _assetDataSource;
}

- (instancetype)init{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        self.maxPreviewCount = 20;
        self.maxAllowedSelectCount = 10;
    }
    return self;
}

- (void)showPhotosInAllAlbumWithRoot:(UIViewController *)root lastSelectedModels:(NSArray<PhotoSelectModel *> *)lastSeletedModels completed:(void (^)(NSArray<UIImage *> *, NSArray<PhotoSelectModel *> *))completed{
    [self showPreview:NO root:root lastSelectedModels:lastSeletedModels completed:completed];
}

- (void)showPreview:(BOOL)preview root:(UIViewController *)root lastSelectedModels:(NSArray<PhotoSelectModel *> *)lastSeletedModels completed:(void (^)(NSArray<UIImage *> *, NSArray<PhotoSelectModel *> *))completed{
    
    self.callBack = completed;
    self.root = root;
    self.preview = preview;
    self.previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    [self.seletedPhotos removeAllObjects];
    [self.seletedPhotos addObjectsFromArray:lastSeletedModels];
    
    [self addAssociatedWithRoot];
    if ([self hasPhotoAblumAuthority]) {
        if (preview) {
            
        }else{//直接进入相册
            [self presentPhotoLibrary];
        }
    }else{//没有权限的情况
        
    }
}

- (void)presentPhotoLibrary{
    
    self.animate = false;
    
}

- (void)addAssociatedWithRoot{
    
    BOOL selfInstanceIsClassVar = false;
    unsigned int count = 0;
    Ivar *vars = class_copyIvarList(self.root.class, &count);
    for (int i = 0; i < count; i++) {
        Ivar var = vars[i];
        const char *type = ivar_getTypeEncoding(var);
        NSString *className = [NSString stringWithUTF8String:type];
        if ([className isEqualToString:[NSString stringWithFormat:@"@\"%@\"", NSStringFromClass(self.class)]]) {
            selfInstanceIsClassVar = YES;
        }
    }
    if (!selfInstanceIsClassVar) {
        objc_setAssociatedObject(self.root, _cmd, self, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (BOOL)hasPhotoAblumAuthority{
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        return true;
    }
    return false;
}

@end
