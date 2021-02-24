//
//  HCCornerAdView.m
//
//  Created by chc on 2020/1/3.
//  Copyright © 2020. All rights reserved.
//

#import "HCCornerAdView.h"
#import "HCVideoPlayerConst.h"
#import "UIImageView+WebCache.h"

@interface HCCornerAdView ()
{
    HCVideoAdItem *_showAdItem;
}
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UIButton *closeBtn;
@end

@implementation HCCornerAdView
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
        imageView.clipsToBounds = YES;
        imageView.layer.cornerRadius = 4;
        
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
        [closeBtn setImage:[UIImage vp_imageWithName:@"vp_cornerAdClose"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(didClickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

#pragma mark - 外部方法
- (void)setCornerItems:(NSArray<HCVideoAdItem *> *)cornerItems
{
    _cornerItems = cornerItems;
    [self setupShowAdItem];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:_showAdItem.photo] completed:nil];
}

- (void)sizeToFit
{
    [self setupFrame];
    self.vp_width = kVP_isIPad ? 240 : 120;
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
    CGFloat selfW = kVP_isIPad ? 240 : 120;
    self.closeBtn.vp_width = 30;
    self.closeBtn.vp_height = 18;
    self.closeBtn.vp_x = selfW - self.closeBtn.vp_width;
    self.closeBtn.vp_y = 0;
    
    self.imageView.vp_y = CGRectGetMaxY(self.closeBtn.frame) + 5;
    self.imageView.vp_x = 0;
    self.imageView.vp_width = selfW;
    self.imageView.vp_height = kVP_isIPad ? 80 : 40;
}

#pragma mark - 事件
- (void)didClickCloseBtn
{
    [self removeFromSuperview];
    
    if ([self.delegate respondsToSelector:@selector(didClickCloseBtnForCornerAdView:)]) {
        [self.delegate didClickCloseBtnForCornerAdView:self];
    }
}

- (void)didClickImageView
{
    if ([self.delegate respondsToSelector:@selector(cornerAdView:didClickAdItem:)]) {
        [self.delegate cornerAdView:self didClickAdItem:_showAdItem];
    }
}

#pragma mark - 内部方法
/// 按权重获取要显示的广告
- (void)setupShowAdItem
{
    NSMutableArray *adItemsM = [NSMutableArray array];
    NSMutableArray *adIndexsM = [NSMutableArray array];
    
    // 取已下好图的广告
    for (HCVideoAdItem *adItem in _cornerItems) {
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
