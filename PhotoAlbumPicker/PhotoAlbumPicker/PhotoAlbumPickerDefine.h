//
//  PhotoAlbumPickerDefine.h
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/4/27.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#ifndef PhotoAlbumPickerDefine_h
#define PhotoAlbumPickerDefine_h
#import "NSBundle+Extension.h"

#define ScreenWidth      [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight     [[UIScreen mainScreen] bounds].size.height
#define kItemMargin 30
#define kMaxImageWidth 500
#define weakify(var) __weak typeof(var)weakSelf = var
#define strongify(var) __strong typeof(var)strongSelf = var
#define RGB(r, g, b)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBA(r, g, b, a)   [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

#define PhotoAlbumPickerCamera @"PhotoAlbumPickerCamera"
#define PhotoAlbumPickerAlbum @"PhotoAlbumPickerAlbum"
#define PhotoAlbumPickerCancel @"PhotoAlbumPickerCancel"

#define PhotoAlbumPickerOriginal @"PhotoAlbumPickerOriginal"
#define PhotoAlbumPickerDone @"PhotoAlbumPickerDone"
#define PhotoAlbumPickerOK @"PhotoAlbumPickerOK"

#define PhotoAlbumPickerPhotos @"PhotoAlbumPickerPhotos"
#define PhotoAlbumPickerPreview @"PhotoAlbumPickerPreview"

#define PhotoAlbumPickerLoading @"PhotoAlbumPickerLoading"
#define PhotoAlbumPickerWaiting @"PhotoAlbumPickerWaiting"

#define PhotoAlbumPickerSaveImageError @"PhotoAlbumPickerSaveImageError"
#define PhotoAlbumPickerMaxSelectedCount @"PhotoAlbumPickerMaxSelectedCount"

#define PhotoAlbumPickerNoCameraAuthority @"PhotoAlbumPickerNoCameraAuthority"
#define PhotoAlbumPickerNoAblumAuthority @"PhotoAlbumPickerNoAblumAuthority"
#define PhotoAlbumPickeriCloudPhoto @"PhotoAlbumPickeriCloudPhoto"

static inline NSString * GetLocalziedString(NSString *key){
    return [NSBundle localizedStringForKey:key];
}

static inline CGFloat GetMatchValue(BOOL isVertical, NSString *string, CGFloat fontSize, CGFloat fixedValue){
    CGSize size ;
    if (isVertical) {
        size = CGSizeMake(fixedValue, MAXFLOAT);
    }else{
        size = CGSizeMake(MAXFLOAT, fixedValue);
    }
    CGSize resultSize;
    if ([[[UIDevice currentDevice] systemVersion] doubleValue] >= 7.0) {
        resultSize = [string boundingRectWithSize:size options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:fontSize]} context:nil].size;
    }
    
    return isVertical ? resultSize.height : resultSize.width;
}

static inline CAKeyframeAnimation *GetSelectBtnAnimation(){
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.duration = 0.3;
    animation.removedOnCompletion = YES;
    animation.fillMode = kCAFillModeForwards;
    animation.values = @[[NSValue valueWithCATransform3D:CATransform3DMakeScale(.6, .6, 1.0)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.3, 1.3, 1.0)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(.8, .8, 1.0)],
                         [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]
                         ];
    return animation;
}


#endif /* PhotoAlbumPickerDefine_h */
