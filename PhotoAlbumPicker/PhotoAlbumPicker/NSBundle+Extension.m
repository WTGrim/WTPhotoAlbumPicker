//
//  NSBundle+Extension.m
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/5/2.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "NSBundle+Extension.h"
#import "PhotoAlertSheet.h"

@implementation NSBundle (Extension)

+ (instancetype)photoAlbumListBundle{
    static NSBundle *bundle = nil;
    if (!bundle) {
        bundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[PhotoAlertSheet class]] pathForResource:@"PhotoAlbumPicker" ofType:@"bundle"]];
    }
    return bundle;
}

+ (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value{
    
    static NSBundle *bundle = nil;
    if (!bundle) {
        NSString *language = [NSLocale preferredLanguages].firstObject;
        if ([language hasPrefix:@"en"]) {
            language = @"en";
        }else if([language hasPrefix:@"zh"]){
            if ([language rangeOfString:@"Hans"].location != NSNotFound) {
                language = @"zh-Hans";
            }else{
                language = @"zh-Hant";
            }
        }else if ([language hasPrefix:@"ja"]){
            language = @"ja-US";
        }else{
            language = @"en";
        }
        bundle = [NSBundle bundleWithPath:[[NSBundle photoAlbumListBundle] pathForResource:language ofType:@"lproj"]];
    }
    value = [bundle localizedStringForKey:key value:value table:nil];
    return [[NSBundle mainBundle]localizedStringForKey:key value:value table:nil];
}

+ (NSString *)localizedStringForKey:(NSString *)key{
    return  [self localizedStringForKey:key value:nil];
}

@end
