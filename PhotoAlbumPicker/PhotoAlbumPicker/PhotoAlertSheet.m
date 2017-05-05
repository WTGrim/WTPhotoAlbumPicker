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
#import "PhotoAlbumListController.h"
#import "PhotoAlbumTool.h"
#import "PhotoAlbumCommonModel.h"

#define kScalePhotoWidth 1000
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
    
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    [self addAssociatedWithRoot];
    if (preview) {
//        if (status == PHAuthorizationStatusAuthorized) {
//            [self presentPhotoLibrary];
//            [self show];
//        } else if (status == PHAuthorizationStatusRestricted ||
//                   status == PHAuthorizationStatusDenied) {
//            NSLog(@"没有权限");
//        }
    } else {
//        if (status == PHAuthorizationStatusAuthorized) {
//            [self presentPhotoLibrary];
//        } else if (status == PHAuthorizationStatusRestricted ||
//                   status == PHAuthorizationStatusDenied) {
//            [self presentPhotoLibrary];
//        }
        [self presentPhotoLibrary];
    }
}

- (void)presentPhotoLibrary{
    
    self.animate = false;
    PhotoAlbumListController *list = [[PhotoAlbumListController alloc]initWithStyle:UITableViewStylePlain];
    list.maxSelectCount = self.maxAllowedSelectCount;
    list.selectPhotos = self.seletedPhotos.mutableCopy;
    weakify(self);
    __weak typeof(list)weakList = list;
    [list setCompletedBlock:^(NSArray<PhotoSelectModel *> *selectedPhotos, BOOL isSeletedOrigin){
        strongify(weakSelf);
        __strong typeof(weakList)strongList = weakList;
        strongSelf.isSelectedOriginPhoto = isSeletedOrigin;
        [strongSelf.seletedPhotos removeAllObjects];
        [strongSelf.seletedPhotos addObjectsFromArray:selectedPhotos];
        [strongSelf getSelectedPhotos:strongList];
    }];
    
    [self presentVc:list];
}

- (void)presentVc:(UIViewController *)vc{
    
    PhotoNavigateController *nav = [[PhotoNavigateController alloc]initWithRootViewController:vc];
    nav.navigationBar.translucent = YES;
//    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    [nav.navigationBar setBackgroundImage:[self imageWithColor:RGB(19, 153, 231)] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTintColor:[UIColor whiteColor]];
    nav.navigationBar.barStyle = UIBarStyleBlack;
    [self.root presentViewController:nav animated:YES completion:nil];
}

- (UIImage *)imageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (void)getSelectedPhotos:(UIViewController *)vc{
    
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:self.seletedPhotos.count];
    for (int i = 0; i < self.seletedPhotos.count; i++) {
        [photos addObject:@""];
    }
    CGFloat scale = self.isSelectedOriginPhoto?1:[UIScreen mainScreen].scale;
    weakify(self);
    for (int i = 0; i < self.seletedPhotos.count; i++) {
        PhotoSelectModel *model = self.seletedPhotos[i];
        [[PhotoAlbumTool shareInstance]getImageByAsset:model.asset scale:scale resizeMode:PHImageRequestOptionsResizeModeExact completed:^(UIImage *image) {
            strongify(weakSelf);
            if (image) {
                [photos replaceObjectAtIndex:i withObject:[self scaleImage:image]];
            }
            for (id obj in photos) {
                if ([obj isKindOfClass:[NSString class]]) return ;
            }
            
            [strongSelf completed:photos];
            [strongSelf hide];
            [vc.navigationController dismissViewControllerAnimated:true completion:nil];
        }];
    }
}

- (void)hide{
    
}

- (void)completed:(NSArray <UIImage *>*)photos{
    
    if (self.callBack) {
        self.callBack(photos, self.seletedPhotos.copy);
        self.callBack = nil;
    }
}

- (UIImage *)scaleImage:(UIImage *)image{
    
    CGSize size = CGSizeMake(kScalePhotoWidth, kScalePhotoWidth / image.size.width * image.size.height);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
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

@implementation PhotoNavigateController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = self.previousStatusBarStyle;
}

@end
