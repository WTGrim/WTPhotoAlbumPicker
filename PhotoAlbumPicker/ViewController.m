//
//  ViewController.m
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/4/25.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "ViewController.h"
#import "PhotoAlertSheet.h"
#import "PhotoAlbumPickerDefine.h"

@interface ViewController ()

@property(nonatomic, strong)NSArray <PhotoSelectModel *>*lastSelectPhotos;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
}

- (void)setupUI{
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(100, 100, 100, 100)];
    btn.backgroundColor = [UIColor redColor];
    [btn setTitle:@"相册选择器" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(btnAction) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnAction{
    
    PhotoAlertSheet *sheet = [[PhotoAlertSheet alloc]init];
    sheet.maxAllowedSelectCount = 3;
    sheet.maxPreviewCount = 20;
    weakify(self);
    [sheet showPhotosInAllAlbumWithRoot:self lastSelectedModels:self.lastSelectPhotos completed:^(NSArray<UIImage *> *photos, NSArray<PhotoSelectModel *> *selectedModels) {
        strongify(weakSelf);
        strongSelf.lastSelectPhotos = selectedModels;
        NSLog(@"%@", strongSelf.lastSelectPhotos);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
