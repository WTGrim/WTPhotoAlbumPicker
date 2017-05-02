//
//  NSBundle+Extension.h
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/5/2.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSBundle (Extension)

+ (instancetype)photoAlbumListBundle;
+ (NSString *)localizedStringForKey:(NSString *)key;
+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value;

@end
