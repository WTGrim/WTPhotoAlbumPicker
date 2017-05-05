//
//  PhotoPreviewController.m
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/5/2.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "PhotoPreviewController.h"
#import "PhotoAlbumPickerDefine.h"
#import <Photos/Photos.h>
#import "PhotoAlbumTool.h"
#import "PhotoAlbumCommonModel.h"
#import "PhotoPreviewCell.h"
#import "PhotoAlbumListController.h"

#define kMargin  15
#define kMinMargin 5
#define kAddTag 100

@interface PhotoPreviewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, weak)UIButton *originBtn;
@property(nonatomic, weak)UIButton *completedBtn;
@property(nonatomic, weak)UILabel *byteLabel;
@property(nonatomic, strong)NSMutableArray<PHAsset *> *dataArray;

@end

static NSString *const cellId = @"cellId";
@implementation PhotoPreviewController

- (NSMutableArray<PHAsset *> *)dataArray{
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
    
    [self setupNavBar];
    [self setupBottomView];
    [self setupCollectionView];
    [self getData];
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
    
    UIImage *back = [UIImage imageNamed:@"backBtn"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:back style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
}

- (void)setupCollectionView{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.minimumLineSpacing = kMinMargin;
    layout.minimumInteritemSpacing = kMinMargin;
    layout.itemSize = CGSizeMake((ScreenWidth - 3 * kMinMargin) / 4 , (ScreenWidth - 3 * kMinMargin) / 4);
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, ScreenWidth, ScreenHeight - 49 - 64) collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerClass:[PhotoPreviewCell class] forCellWithReuseIdentifier:cellId];
    [self.view addSubview:self.collectionView];
}

- (void)getData{
    [self.dataArray addObjectsFromArray:[[PhotoAlbumTool shareInstance] getPhotosInAsset:self.assetCollection timeAsc:true]];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PhotoPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    
    PHAsset *asset = self.dataArray[indexPath.row];
    weakify(self);
    CGSize size = cell.frame.size;
    size.width *= 2.5;
    size.height *= 2.5;
    cell.selectBtn.selected = false;
    [[PhotoAlbumTool shareInstance]getImageByAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeExact completed:^(UIImage *image, NSDictionary *info) {
        strongify(weakSelf);
        cell.headImageView.image = image;
        for (PhotoSelectModel *model in strongSelf.selectedPhotos) {
            if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
                cell.selectBtn.selected = true;
                break;
            }
        }
    }];
    
    cell.selectBtn.tag = indexPath.row + kAddTag;
    [cell.selectBtn addTarget:self action:@selector(cellSelectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)cellSelectBtnAction:(UIButton *)btn{
    
    if (self.selectedPhotos.count >= self.maxSelectedCount && btn.selected == false) {
        NSLog(@"最大选择数为%ld", self.maxSelectedCount);
        return;
    }
    
    PHAsset *asset = self.dataArray[btn.tag - kAddTag];
    
    if (!btn.selected) {
        [btn.layer addAnimation:GetSelectBtnAnimation() forKey:nil];
        if (![[PhotoAlbumTool shareInstance]isLocalForAsset:asset]) {
            NSLog(@"%@", GetLocalziedString(PhotoAlbumPickeriCloudPhoto));
            return;
        }
        PhotoSelectModel *model = [[PhotoSelectModel alloc]init];
        model.asset = asset;
        model.localIdentifier = asset.localIdentifier;
        [self.selectedPhotos addObject:model];
        
    }else{
        for (PhotoSelectModel *model in self.selectedPhotos) {
            if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
                [self.selectedPhotos removeObject:model];
                break;
            }
        }
    }
    btn.selected = !btn.selected;
    [self judgeStatus];
    [self setOriginImageBytes];
}

- (void)setOriginImageBytes{
    
    weakify(self);
    if (self.isSelectedOrigin && self.selectedPhotos.count > 0) {
        [[PhotoAlbumTool shareInstance]getPhotosBytes:self.selectedPhotos completed:^(NSString *bytes) {
            strongify(weakSelf);
            strongSelf.byteLabel.text = [NSString stringWithFormat:@"(%@)", bytes];
        }];
        self.originBtn.selected = self.isSelectedOrigin;
    }else{
        self.originBtn.selected = false;
        self.byteLabel.text = nil;
    }
}

#pragma mark - 点击原图
- (void)originBtnAction:(UIButton *)btn{
    
    self.isSelectedOrigin = !self.originBtn.selected;
    [self setOriginImageBytes];
    
}

#pragma mark - 点击确定
- (void)completedBtnAction{
    
    if (_completedBlock) {
        _completedBlock(self.selectedPhotos, self.isSelectedOrigin);
    }
}

- (void)setupBottomView{
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - 49, ScreenWidth, 49)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:bottomView];
    
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
    line.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [bottomView addSubview:line];
    
    UIButton *originBtn = [[UIButton alloc]initWithFrame:CGRectMake(kMargin, 4.5, 60, 40)];
    [originBtn setImage:[UIImage imageNamed:@"btn_original_circle"] forState:UIControlStateNormal];
    [originBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateSelected];
    [originBtn setTitle:GetLocalziedString(PhotoAlbumPickerOriginal) forState:UIControlStateNormal];
    [originBtn setTitleColor:RGB(80, 180, 234) forState:UIControlStateSelected];
    [originBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    originBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [originBtn addTarget:self action:@selector(originBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.originBtn = originBtn;
    [bottomView addSubview:self.originBtn];
    
    UILabel *byteLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.originBtn.frame), CGRectGetMinY(self.originBtn.frame), 70, 40)];
    byteLabel.font = [UIFont systemFontOfSize:15];
    byteLabel.textColor = RGB(80, 180, 234);
    self.byteLabel = byteLabel;
    [bottomView addSubview:self.byteLabel];
    
    UIButton *completedBtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth - 70 - kMargin, CGRectGetMinY(self.originBtn.frame), 70, 40)];
    [completedBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [completedBtn setBackgroundColor: [UIColor groupTableViewBackgroundColor]];
    [completedBtn setTitle:GetLocalziedString(PhotoAlbumPickerDone) forState:UIControlStateNormal];
    completedBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [completedBtn addTarget:self action:@selector(completedBtnAction) forControlEvents:UIControlEventTouchUpInside];
    completedBtn.layer.cornerRadius = 3;
    completedBtn.layer.masksToBounds = true;
    self.completedBtn = completedBtn;
    [bottomView addSubview:self.completedBtn];
    
    [self judgeStatus];
}

- (void)judgeStatus{
    
    if (self.selectedPhotos.count) {
        self.originBtn.enabled = true;
        self.originBtn.selected = true;
        self.completedBtn.enabled = true;
        [self.completedBtn setTitle:[NSString stringWithFormat:@"%@(%ld)", GetLocalziedString(PhotoAlbumPickerDone), self.selectedPhotos.count] forState:UIControlStateNormal];
        self.completedBtn.backgroundColor = RGB(80, 180, 234);
        [self.completedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        
        self.originBtn.enabled = false;
        self.originBtn.selected = false;
        self.completedBtn.enabled = false;
        [self.completedBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.completedBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.completedBtn setTitle:GetLocalziedString(PhotoAlbumPickerDone) forState:UIControlStateNormal];
    }
}

- (void)cancelAction{
    if (_cancelBlock) {
        _cancelBlock();
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)backAction{
    
    self.listVC.selectPhotos = self.selectedPhotos;
    self.listVC.isSelectOrigin = self.isSelectedOrigin;
    [self.navigationController popViewControllerAnimated:true];
}

@end





