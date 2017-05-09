//
//  PhotoDetailViewController.m
//  PhotoAlbumPicker
//
//  Created by Dwt on 2017/5/5.
//  Copyright © 2017年 Dwt. All rights reserved.
//

#import "PhotoDetailViewController.h"
#import "PhotoAlbumPickerDefine.h"
#import "PhotoAlbumTool.h"
#import "PhotoAlbumCommonModel.h"
#import "PhotoDetailCell.h"

#define kMargin 30
#define kBottomViewH 49
static NSString *const cellId = @"cellId";

@interface PhotoDetailViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property(nonatomic, strong)UIButton *rightSelectBtn;
@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)NSMutableArray<PHAsset *> *dataArray;
@property(nonatomic, assign)NSInteger currentPage;
@property(nonatomic, strong)UIView *bottomView;
@property(nonatomic, strong)UIButton *orginalBtn;
@property(nonatomic, strong)UIButton *completedBtn;
@property(nonatomic, strong)UILabel *bytesLabel;

@end

@implementation PhotoDetailViewController

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

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.collectionView setContentOffset:CGPointMake(self.selectIndex * (ScreenWidth + kMargin), 0)];
    [self setNavRightStutas];
}

- (void)setupUI{
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = false;

    [self setNav];
    [self addAsset];
    [self setCollectionView];
    [self setBottomView];
    [self setCompleteBtnStatus];
}

- (void)setNav{
    
    UIImage *back = [UIImage imageNamed:@"backBtn"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:back style:UIBarButtonItemStylePlain target:self action:@selector(backAction)];
    
    self.rightSelectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rightSelectBtn.frame = CGRectMake(0, 0, 25, 25);
    [self.rightSelectBtn setBackgroundImage:[UIImage imageNamed:@"btn_circle"] forState:UIControlStateNormal];
    [self.rightSelectBtn setBackgroundImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateSelected];
    [self.rightSelectBtn addTarget:self action:@selector(rightSelectBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:self.rightSelectBtn];
}

- (void)addAsset{
    
    [self.dataArray addObjectsFromArray:self.asset];
    self.currentPage = self.selectIndex + 1;
    self.title = [NSString stringWithFormat:@"%ld/%ld", self.currentPage, self.dataArray.count];
}

- (void)setCollectionView{
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = kMargin;
    layout.sectionInset = UIEdgeInsetsMake(0, kMargin * 0.5, 0, kMargin * 0.5);
    layout.itemSize = self.view.bounds.size;
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(-kMargin * 0.5, 0, ScreenWidth + kMargin, ScreenHeight) collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.pagingEnabled = true;
    [self.collectionView registerClass:[PhotoDetailCell class] forCellWithReuseIdentifier:cellId];
    [self.view addSubview:self.collectionView];
}

- (void)setBottomView{
    
    self.bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, ScreenHeight - kBottomViewH, ScreenWidth, kBottomViewH)];
    self.bottomView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.bottomView];
    
    self.orginalBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    CGFloat width = GetMatchValue(false, GetLocalziedString(PhotoAlbumPickerOriginal), 15, 30);
    self.orginalBtn.frame = CGRectMake(15, (kBottomViewH - 30) * 0.5, width + 30, 30);
    [self.orginalBtn setImage:[UIImage imageNamed:@"btn_original_circle"] forState:UIControlStateNormal];
    [self.orginalBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateSelected];
    [self.orginalBtn setTitle:GetLocalziedString(PhotoAlbumPickerOriginal) forState:UIControlStateNormal];
    [self.orginalBtn setTitleColor:RGB(80, 180, 234) forState:UIControlStateNormal];
    [self.orginalBtn setTitleColor:RGB(80, 180, 234) forState:UIControlStateSelected];
    [self.orginalBtn addTarget:self action:@selector(orginalBtnSelectAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.orginalBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
    [self.bottomView addSubview:self.orginalBtn];
    self.orginalBtn.selected = self.isSelectedOrigin;

    self.bytesLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.orginalBtn.frame), CGRectGetMinY(self.orginalBtn.frame), 80, 30)];
    self.bytesLabel.font = [UIFont systemFontOfSize:15];
    self.bytesLabel.textColor = RGB(80, 180, 234);
    [self.bottomView addSubview:self.bytesLabel];
    if (self.selectPhotos.count > 0) {
        [self setBytesLabel];
    }
    
    self.completedBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.completedBtn.frame = CGRectMake(ScreenWidth - 85, CGRectGetMinY(self.orginalBtn.frame), 70, 30);
    self.completedBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.completedBtn setTitle:GetLocalziedString(PhotoAlbumPickerDone) forState:UIControlStateNormal];
    self.completedBtn.layer.cornerRadius = 3;
    self.completedBtn.layer.masksToBounds = true;
    [self.completedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.completedBtn setBackgroundColor:RGB(80, 180, 234)];
    [self.bottomView addSubview:self.completedBtn];
    [self.completedBtn addTarget:self action:@selector(completedBtnAction) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - collectionViewDataSource And delegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PhotoDetailCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    weakify(self);
    cell.asset = self.dataArray[indexPath.row];
    cell.tapBlock = ^{
        strongify(weakSelf);
        if (strongSelf.navigationController.navigationBar.isHidden) {
            [strongSelf showAnimation];
        }else{
            [strongSelf hideAnimation];
        }
    };
    return cell;
}

- (void)showAnimation{
    
    [self.navigationController setNavigationBarHidden:false animated:true];
    [[UIApplication sharedApplication]setStatusBarHidden:false withAnimation:UIStatusBarAnimationSlide];
    CGRect rect = self.bottomView.frame;
    rect.origin.y -= kBottomViewH;
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomView.frame = rect;
    }];
}


- (void)hideAnimation{
    [self.navigationController setNavigationBarHidden:true animated:true];
    [[UIApplication sharedApplication]setStatusBarHidden:true withAnimation:UIStatusBarAnimationSlide];
    CGRect rect = self.bottomView.frame;
    rect.origin.y += kBottomViewH;
    [UIView animateWithDuration:0.25 animations:^{
        self.bottomView.frame = rect;
    }];
}


- (void)completedBtnAction{
    if (self.completedBtnBlock) {
        self.completedBtnBlock(self.selectPhotos, self.isSelectedOrigin);
    }
}

- (void)setBytesLabel{
    
    if (!self.isSelectedOrigin) return;
    if (self.selectPhotos.count > 0) {
        weakify(self);
        [[PhotoAlbumTool shareInstance]getPhotosBytes:self.selectPhotos completed:^(NSString *bytes) {
            strongify(weakSelf);
            strongSelf.bytesLabel.text = [NSString stringWithFormat:@"(%@)", bytes];
        }];
    }else{
        self.bytesLabel.text = nil;
    }
}

- (void)orginalBtnSelectAction:(UIButton *)btn{
    
    self.isSelectedOrigin = btn.selected = !btn.selected;
    if (btn.selected) {
        if (![self hasSelectedThisPhoto]) {
            [self rightSelectBtnAction:self.rightSelectBtn];
        }else{
            [self setBytesLabel];
        }
    }else{
        self.bytesLabel.text = nil;
    }
}

- (BOOL)hasSelectedThisPhoto{
    
    PHAsset *asset = self.dataArray[self.currentPage - 1];
    for (PhotoSelectModel *model in self.selectPhotos) {
        if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
            return true;
        }
    }
    return false;
}


- (void)rightSelectBtnAction:(UIButton *)btn{
    
    if (self.selectPhotos.count >= self.maxSelectCount && btn.selected == false) {
        NSLog(@"最大选择数为:%ld", self.maxSelectCount);
        return;
    }
    
    PHAsset *asset = self.dataArray[self.currentPage - 1];
    if (![self hasSelectedThisPhoto]) {
        [self.rightSelectBtn.layer addAnimation:GetSelectBtnAnimation() forKey:nil];
        if (![[PhotoAlbumTool shareInstance]isLocalForAsset:asset]) {
            NSLog(@"不是本地图片");
            return;
        }
        
        PhotoSelectModel *model = [[PhotoSelectModel alloc]init];
        model.asset = asset;
        model.localIdentifier = asset.localIdentifier;
        [self.selectPhotos addObject:model];
    }else{
        [self removeThisImage];
    }
    btn.selected = !btn.selected;
    [self setBytesLabel];
    [self setCompleteBtnStatus];
}

- (void)removeThisImage{
    
    PHAsset *asset = self.dataArray[self.currentPage - 1];
    for (PhotoSelectModel *model in self.selectPhotos) {
        if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
            [self.selectPhotos removeObject:model];
            break;
        }
    }
}

- (void)setCompleteBtnStatus{
    
    if (self.selectPhotos.count > 0) {
        [self.completedBtn setTitle:[NSString stringWithFormat:@"%@(%ld)", GetLocalziedString(PhotoAlbumPickerDone), self.selectPhotos.count] forState:UIControlStateNormal];
    }else{
        [self.completedBtn setTitle:GetLocalziedString(PhotoAlbumPickerDone) forState:UIControlStateNormal];
    }
}

- (void)backAction{
    if (self.completedBtnBlock) {
        self.completedBtnBlock(self.selectPhotos, self.isSelectedOrigin);
    }
    [self.navigationController popViewControllerAnimated:true];
}

- (void)setNavRightStutas{
    
    if ([self hasSelectedThisPhoto]) {
        self.rightSelectBtn.selected = true;
    }else{
        self.rightSelectBtn.selected = false;
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (scrollView == self.collectionView) {
        NSInteger index = scrollView.contentOffset.x / (ScreenWidth + kMargin);
        self.currentPage = index + 1;
        self.title = [NSString stringWithFormat:@"%ld/%ld", self.currentPage, self.asset.count];
        [self setNavRightStutas];
    }
}
@end
