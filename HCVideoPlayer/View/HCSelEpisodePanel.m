//
//  HCSelEpisodePanel.m
//  HCVideoPlayer
//
//  Created by chc on 2018/7/22.
//  Copyright © 2018年 chc. All rights reserved.
//

#define kCltIdentifier @"HCSelEpisodePanelCltCell"

#import "HCSelEpisodePanel.h"
#import "HCVideoPlayerConst.h"

@class HCSelEpisodePanelCltCell;
@protocol HCSelEpisodePanelCltCellDelegate <NSObject>
- (void)didClickTitleBtnForSelEpisodePanelCltCell:(HCSelEpisodePanelCltCell *)selEpisodePanelCltCell;
@end

@interface HCSelEpisodePanelCltCell : UICollectionViewCell
@property (nonatomic, strong) NSString *title;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, weak) UIButton *titleBtn;
@property (nonatomic, assign) BOOL isBigType;
@property (nonatomic, assign) BOOL isSelect;
@property (nonatomic, weak) id <HCSelEpisodePanelCltCellDelegate> delegate;
@end

@implementation HCSelEpisodePanelCltCell
#pragma mark - 懒加载
- (UIButton *)titleBtn
{
    if (_titleBtn == nil) {
        UIButton *titleBtn = [[UIButton alloc] init];
        [self.contentView addSubview:titleBtn];
        _titleBtn = titleBtn;
        titleBtn.layer.cornerRadius = 4;
        titleBtn.layer.masksToBounds = YES;
        [titleBtn setTitleColor:kVP_TitleBlackColor forState:UIControlStateNormal];
        titleBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        titleBtn.titleLabel.numberOfLines = 1;
        titleBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [titleBtn setBackgroundImage:[UIImage vp_imageWithColor:kVP_ColorWithHexValueA(0xFFFFFF, 0.3)] forState:UIControlStateNormal];
        [titleBtn setBackgroundImage:[UIImage vp_imageWithColor:kVP_ColorWithHexValueA(0xFFFFFF, 0.8)] forState:UIControlStateSelected];
        [titleBtn setTitleColor:kVP_ColorWithHexValueA(0xFFFFFF, 0.8) forState:UIControlStateNormal];
        [titleBtn setTitleColor:kVP_ColorWithHexValueA(0x000000, 0.8) forState:UIControlStateSelected];
        [titleBtn addTarget:self action:@selector(didClickTitleBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _titleBtn;
}

#pragma mark - 外部方法
- (void)setTitle:(NSString *)title
{
    _title = title;
    [self.titleBtn setTitle:_title forState:UIControlStateNormal];
}

- (void)setIsBigType:(BOOL)isBigType
{
    _isBigType = isBigType;
    if (_isBigType) {
        self.titleBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
        self.titleBtn.titleLabel.font = kVP_Font(13);
    }
    else
    {
        self.titleBtn.titleLabel.font = kVP_Font(16);
        self.titleBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 5);
    }
}

- (void)setIsSelect:(BOOL)isSelect
{
    _isSelect = isSelect;
    self.titleBtn.selected = _isSelect;
}

#pragma mark 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleBtn.frame = self.bounds;
}

#pragma mark - 事件
- (void)didClickTitleBtn
{
    if ([self.delegate respondsToSelector:@selector(didClickTitleBtnForSelEpisodePanelCltCell:)]) {
        [self.delegate didClickTitleBtnForSelEpisodePanelCltCell:self];
    }
}

@end

@interface HCSelEpisodePanel ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, HCSelEpisodePanelCltCellDelegate>
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UICollectionView *collectionView;
@end

@implementation HCSelEpisodePanel
#pragma mark - 懒加载
- (UIView *)contentView
{
    if (_contentView == nil) {
        UIView *contentView = [[UIView alloc] init];
        [self addSubview:contentView];
        _contentView = contentView;
    }
    return _contentView;
}

- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.minimumLineSpacing = 18;
        layout.minimumInteritemSpacing = 18;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        [self.contentView addSubview:collectionView];
        _collectionView = collectionView;
        collectionView.backgroundColor = [UIColor clearColor];
        collectionView.delegate = self;
        collectionView.dataSource = self;
        collectionView.scrollsToTop = NO;
        collectionView.showsVerticalScrollIndicator = NO;
        collectionView.showsHorizontalScrollIndicator = NO;
        collectionView.alwaysBounceVertical = YES;
        collectionView.clipsToBounds = NO;
        collectionView.contentInset = UIEdgeInsetsMake(50, 0, 50, 0);
        collectionView.scrollIndicatorInsets = UIEdgeInsetsMake(kVP_NavigationBarHeight, 0, 0, 0);
        [collectionView registerClass:[HCSelEpisodePanelCltCell class] forCellWithReuseIdentifier:kCltIdentifier];
//        [collectionView unAutomaticallyAdjustsScrollViewInsetsForController:self];
        collectionView.clipsToBounds = YES;
    }
    return _collectionView;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupSelfGesture];
    }
    return self;
}

- (void)dealloc
{
    VPLog(@"dealloc - HCMorePanel");
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupFrame];
}

- (void)setupSelfGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfTap)];
    [self addGestureRecognizer:tap];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selfPan)];
    [self addGestureRecognizer:pan];
}

#pragma mark - 外部方法
- (void)showPanelAtView:(UIView *)view
{
    if (![view isKindOfClass:[UIView class]]) {
        return;
    }
    self.frame = view.bounds;
    [view addSubview:self];
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            self.backgroundColor = kVP_Color(0, 0, 0, 0.85);
        }];
    });
}

- (void)hiddenPanel
{
    [UIView animateWithDuration:kVP_AniDuration animations:^{
        self.backgroundColor = kVP_Color(0, 0, 0, 0.0);
        self.contentView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(didHiddenSelEpisodePanel:)]) {
            [self.delegate didHiddenSelEpisodePanel:self];
        }
    }];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _items.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HCSelEpisodePanelCltCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCltIdentifier forIndexPath:indexPath];
    NSString *item = _items[indexPath.row];
    cell.title = item;
    cell.isBigType = _isBigType;
    cell.isSelect = (_selIndex == indexPath.item);
    cell.index = indexPath.item;
    cell.delegate = self;
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_isBigType) {
        CGFloat posterW = (self.contentView.vp_width - 18) * 0.5;
        return CGSizeMake(posterW, 52);
    }
    return CGSizeMake(52, 52);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // 这个事件不会响应？？？
}

#pragma mark - HCSelEpisodePanelCltCellDelegate
- (void)didClickTitleBtnForSelEpisodePanelCltCell:(HCSelEpisodePanelCltCell *)selEpisodePanelCltCell
{
    _selIndex = selEpisodePanelCltCell.index;
    [self.collectionView reloadData];
    if ([self.delegate respondsToSelector:@selector(selEpisodePanel:didClickItem:atIndex:)]) {
        [self.delegate selEpisodePanel:self didClickItem:selEpisodePanelCltCell.title atIndex:selEpisodePanelCltCell.index];
    }
}

#pragma mark - 事件
- (void)selfTap
{
    [self hiddenPanel];
}

- (void)selfPan
{
    
}

#pragma mark - 内部方法
- (void)setupFrame
{
    self.contentView.vp_x = 60 + 34;
    self.contentView.vp_y = 0;
    self.contentView.vp_width = kVP_ScreenWidth - self.contentView.vp_x * 2;
    self.contentView.vp_height = self.vp_height;
    
    self.collectionView.frame = self.contentView.bounds;
}
@end
