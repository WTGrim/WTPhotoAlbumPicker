//
//  PhotoPreviewController.m
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/4/28.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "PhotoAlbumListController.h"
#import "PhotoAlbumTool.h"
#import "PhotoAlbumPickerDefine.h"
#import "PhotoPreviewController.h"

@interface PhotoAlbumListController ()

@property(nonatomic, strong)NSMutableArray<AlbumList *> *dataArray;

@end

static NSString *const cellId = @"cellId";
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
    self.title = GetLocalziedString(PhotoAlbumPickerPhotos);
    self.tableView.tableFooterView = [[UIView alloc]init];
    self.tableView.indicatorStyle = UITableViewCellAccessoryDisclosureIndicator;
    [self.tableView registerClass:[AlbumListCell class] forCellReuseIdentifier:cellId];
    [self setupNavBar];
    [self getAlbums];
    [self pushPreviewVC];
}

- (void)setupNavBar{
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = GetMatchValue(NO, GetLocalziedString(PhotoAlbumPickerCancel), 16, 44);
    btn.frame = CGRectMake(0, 0, width, 44);
    [btn setTitle:GetLocalziedString(PhotoAlbumPickerCancel) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    self.navigationItem.hidesBackButton = YES;
}

- (void)getAlbums{
    [self.dataArray addObjectsFromArray:[[PhotoAlbumTool shareInstance] getAlbumList]];
}

- (void)pushPreviewVC{
    
    if (self.dataArray.count == 0) return;
    NSInteger i = 0;
    for (AlbumList *list in self.dataArray) {
        if (list.assetCollection.assetCollectionSubtype == 209) {
            i = [self.dataArray indexOfObject:list];
            break;
        }
    }
    [self pushPreviewVCWithIndex:i animate:false];
}

- (void)pushPreviewVCWithIndex:(NSInteger)idx animate:(BOOL)animate{
    
    AlbumList *list = self.dataArray[idx];
    PhotoPreviewController *preview = [[PhotoPreviewController alloc]init];
    preview.selectedPhotos = self.selectPhotos.mutableCopy;
    preview.assetCollection = list.assetCollection;
    preview.isSelectedOrigin = self.isSelectOrigin;
    preview.maxSeletedCount = self.maxSelectCount;
    preview.cancelBlock = self.cancelBlock;
    preview.completedBlock = self.completedBlock;
    preview.listVC = self;
    preview.title = list.title;
    [self.navigationController pushViewController:preview animated:animate];
}

- (void)cancelAction{
    if (_cancelBlock) {
        _cancelBlock();
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AlbumListCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
    AlbumList *list = self.dataArray[indexPath.row];
    [[PhotoAlbumTool shareInstance] getImageByAsset:list.firstImageAsset size:CGSizeMake(65 * 3, 65 * 3) resizeMode:PHImageRequestOptionsResizeModeFast completed:^(UIImage *image, NSDictionary *info) {
        cell.headImageView.image = image;
    }];
    cell.titleInfo.text = list.title;
    cell.count.text = [NSString stringWithFormat:@"(%ld)", list.photoCount];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self pushPreviewVCWithIndex:indexPath.row animate:true];
}

@end

@interface AlbumListCell()

@end

@implementation AlbumListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.headImageView = [UIImageView new];
    self.headImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.headImageView];
    self.titleInfo = [UILabel new];
    self.titleInfo.font = [UIFont systemFontOfSize:15];
    self.titleInfo.textColor = [UIColor blackColor];
    [self.contentView addSubview:self.titleInfo];
    self.count = [UILabel new];
    self.count.textColor = [UIColor darkGrayColor];
    self.count.font = [UIFont systemFontOfSize:15];
    [self.contentView addSubview:self.count];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.headImageView.frame = CGRectMake(15, 3, CGRectGetHeight(self.frame) - 6, CGRectGetHeight(self.frame) - 6);
    self.titleInfo.frame = CGRectMake(CGRectGetMaxX(self.headImageView.frame) + 15, 0, 200, CGRectGetHeight(self.frame));
    self.count.frame = CGRectMake(CGRectGetMaxX(self.titleInfo.frame), 0, 60, CGRectGetHeight(self.frame));
}


@end
