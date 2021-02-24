//
//  HCPicAdView.m
//  HCVideoPlayer
//
//  Created by chc on 2018/9/30.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "HCPicAdView.h"
#import "HCVideoPlayerConst.h"
#import "UIImageView+WebCache.h"

@interface HCPicAdView ()
{
    HCVideoAdItem *_showAdItem;
}
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIButton *closeBtn;
@end

@implementation HCPicAdView
#pragma mark - 懒加载
- (UIImageView *)imageView
{
    if (_imageView == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        _imageView = imageView;
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.backgroundColor = [UIColor blackColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickImageView)];
        [imageView addGestureRecognizer:tap];
    }
    return _imageView;
}

- (UIButton *)closeBtn
{
    if (_closeBtn == nil) {
        UIButton *closeBtn = [[UIButton alloc] init];
        [self addSubview:closeBtn];
        _closeBtn = closeBtn;
        [closeBtn setImage:[UIImage vp_imageWithName:@"vp_adDelete"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(didClickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

#pragma mark - 外部方法
- (void)setPicItems:(NSArray<HCVideoAdItem *> *)picItems
{
    _picItems = picItems;
    
    [self setupShowAdItem];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:_showAdItem.photo] completed:nil];
}

- (void)sizeToFit
{
    [self setupFrame];
    self.vp_width = CGRectGetMaxX(self.closeBtn.frame);
    self.vp_height = CGRectGetMaxY(self.imageView.frame);
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupFrame];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!_showAdItem) {
        [self removeFromSuperview];
    }
    [self setupFrame];
}

- (void)setupFrame
{
    CGFloat closeBtnW = 30;
    
    self.imageView.vp_y = closeBtnW * 0.5;
    self.imageView.vp_x = 0;
    self.imageView.vp_width = 360;
    self.imageView.vp_height = 224;
    // iphone竖屏时，即缩小时
    if (kVP_isIphone && kVP_ScreenWidth < kVP_ScreenHeight) {
        self.imageView.vp_width = 209;
        self.imageView.vp_height = 130;
    }
    
    self.closeBtn.vp_x = self.imageView.vp_width - closeBtnW * 0.5;
    self.closeBtn.vp_y = 0;
    self.closeBtn.vp_width = closeBtnW;
    self.closeBtn.vp_height = closeBtnW;
}

#pragma mark - 事件
- (void)didClickCloseBtn
{
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(didClickCloseBtnForVpPicAdView:)]) {
        [self.delegate didClickCloseBtnForVpPicAdView:self];
    }
}

- (void)didClickImageView
{
    if ([self.delegate respondsToSelector:@selector(vpPicAdView:didClickAdItem:)]) {
        [self.delegate vpPicAdView:self didClickAdItem:_showAdItem];
    }
}

#pragma mark - 内部方法
/// 按权重获取要显示的广告
- (void)setupShowAdItem
{
    NSMutableArray *adItemsM = [NSMutableArray array];
    NSMutableArray *adIndexsM = [NSMutableArray array];
    
    // 取已下好图的广告
    for (HCVideoAdItem *adItem in _picItems) {
        if (adItem.hasCacheImage && [adItem.adstype isEqualToString:@"photo"]) { // 已缓存，且只需要图片广告
            [adItemsM addObject:adItem];
        }
    }
    
    if (!adItemsM.count) {
        _showAdItem = nil;
        return;
    }
    
    for (int i = 0; i < adItemsM.count; i ++) {
        HCVideoAdItem *adItem = adItemsM[i];
        NSInteger wights = adItem.weights.floatValue * 100;
        for (int j = 0; j < wights; j ++) {
            [adIndexsM addObject:@(i)];
        }
    }
    
    if (adIndexsM.count) {
        uint32_t randomIndex = arc4random_uniform((uint32_t)adIndexsM.count);
        NSInteger showAdIndex = [adIndexsM[randomIndex] integerValue];
        _showAdItem = adItemsM[showAdIndex];
    }
    else
    {
        _showAdItem = nil;
    }
}

@end
