//
//  HCSvSharePanel.m
//  HCVideoPlayer
//
//  Created by chc on 2019/5/14.
//  Copyright © 2019 chc. All rights reserved.
//

#import "HCSvSharePanel.h"
#import "HCVerButton.h"

@interface HCSvSharePanel ()
@property (nonatomic, weak) HCVerButton *wechatBtn;
@property (nonatomic, weak) HCVerButton *circleBtn;
@property (nonatomic, weak) HCVerButton *rePlayBtn;
@property (nonatomic, weak) UIView *vLine;
@property (nonatomic, copy) void (^clickedReplayBtn)();
@end

@implementation HCSvSharePanel

#pragma mark - 懒加载
- (HCVerButton *)wechatBtn
{
    if (_wechatBtn == nil) {
        HCVerButton *wechatBtn = [[HCVerButton alloc] init];
        [self addSubview:wechatBtn];
        _wechatBtn = wechatBtn;
        HCShareItem *item = [[HCShareItem alloc] init];
        item.appName = @"微信";
        item.title = @"微信好友";
        item.norImage = @"sv_wechat";
        item.platform = @"1";
        item.key = ShareListKeyLinkShare;
        wechatBtn.shareItem = item;
        wechatBtn.padding = 10;
        wechatBtn.titleFont = [UIFont systemFontOfSize:14];
        wechatBtn.titleLabel.textColor = [UIColor whiteColor];
        [wechatBtn addTarget:self action:@selector(didClickWechatBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _wechatBtn;
}

- (HCVerButton *)circleBtn
{
    if (_circleBtn == nil) {
        HCVerButton *circleBtn = [[HCVerButton alloc] init];
        [self addSubview:circleBtn];
        _circleBtn = circleBtn;
        HCShareItem *item = [[HCShareItem alloc] init];
        item.appName = @"微信";
        item.title = @"朋友圈";
        item.norImage = @"sv_circle";
        item.platform = @"2";
        item.key = ShareListKeyLinkShare;
        circleBtn.shareItem = item;
        circleBtn.padding = 10;
        circleBtn.titleFont = [UIFont systemFontOfSize:14];
        circleBtn.titleLabel.textColor = [UIColor whiteColor];
        [circleBtn addTarget:self action:@selector(didClickCircleBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _circleBtn;
}

- (HCVerButton *)rePlayBtn
{
    if (_rePlayBtn == nil) {
        HCVerButton *rePlayBtn = [[HCVerButton alloc] init];
        [self addSubview:rePlayBtn];
        _rePlayBtn = rePlayBtn;
        HCShareItem *item = [[HCShareItem alloc] init];
        item.title = @"重播";
        item.norImage = @"sv_replay";
        rePlayBtn.shareItem = item;
        rePlayBtn.padding = 10;
        rePlayBtn.titleFont = [UIFont systemFontOfSize:14];
        rePlayBtn.titleLabel.textColor = [UIColor whiteColor];
        [rePlayBtn addTarget:self action:@selector(didClickReplayBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rePlayBtn;
}

- (UIView *)vLine
{
    if (_vLine == nil) {
        UIView *vLine = [[UIView alloc] init];
        [self addSubview:vLine];
        _vLine = vLine;
        vLine.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.5].CGColor;
    }
    return _vLine;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kVP_Color(0, 0, 0, 0.5);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfTap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)dealloc
{
    VPLog(@"dealloc - HCSvSharePanel");
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupFrame];
}

- (void)setupFrame
{
    CGFloat selfW = self.bounds.size.width;
    CGFloat selfH = self.bounds.size.height;
    
    CGFloat wechatBtnW = 36;
    CGFloat wechatBtnH = [self.wechatBtn heightToFitWidth:wechatBtnW];
    
    CGFloat circleBtnW = 36;
    CGFloat circleBtnH = [self.circleBtn heightToFitWidth:circleBtnW];
    
    CGFloat rePlayBtnW = 36;
    CGFloat rePlayBtnH = [self.rePlayBtn heightToFitWidth:rePlayBtnW];
    
    CGFloat hLineW = 1;
    CGFloat hLineH = 30;
    
    CGFloat wechatToCirclePadding = 38;
    CGFloat circleToHLinePadding = 28;
    CGFloat hLineToReplayPadding = 25;
    
    CGFloat totalW = wechatBtnW + circleBtnW + hLineW + rePlayBtnW + wechatToCirclePadding + circleToHLinePadding + hLineToReplayPadding;
    
    CGFloat x = (selfW - totalW) * 0.5;
    CGFloat y = (selfH - wechatBtnH) * 0.5;
    self.wechatBtn.frame = CGRectMake(x, y, wechatBtnW, wechatBtnH);
    
    x = CGRectGetMaxX(self.wechatBtn.frame) + wechatToCirclePadding;
    y = (selfH - circleBtnH) * 0.5;
    self.circleBtn.frame = CGRectMake(x, y, circleBtnW, circleBtnH);
    
    x = CGRectGetMaxX(self.circleBtn.frame) + circleToHLinePadding;
    y = CGRectGetMinY(self.circleBtn.frame) + 3;
    self.vLine.frame = CGRectMake(x, y, hLineW, hLineH);
    
    x = CGRectGetMaxX(self.vLine.frame) + hLineToReplayPadding;
    y = (selfH - rePlayBtnH) * 0.5;
    self.rePlayBtn.frame = CGRectMake(x, y, rePlayBtnW, rePlayBtnH);
}

#pragma mark - 外部方法
+ (instancetype)showPanelAtView:(UIView *)view clickedReplayBtn:(void (^)(void))clickedReplayBtn
{
    if (![view isKindOfClass:[UIView class]]) {
        return nil;
    }
    
    [self hiddenPanelAtView:view];
    
    HCSvSharePanel *panel = [[self alloc] init];
    [view addSubview:panel];
    panel.clickedReplayBtn = clickedReplayBtn;
    panel.frame = view.bounds;
    
    return panel;
}

+ (void)hiddenPanelAtView:(UIView *)view
{
    if (![view isKindOfClass:[UIView class]]) {
        return;
    }
    
    for (HCSvSharePanel *panel in view.subviews) {
        if ([panel isKindOfClass:[HCSvSharePanel class]]) {
            [panel removeFromSuperview];
        }
    }
}

- (void)hiddenPanel
{
    [self removeFromSuperview];
}

#pragma mark - 内部方法

#pragma mark - 事件
- (void)didClickReplayBtn
{
    [self hiddenPanel];
    
    if (self.clickedReplayBtn) {
        self.clickedReplayBtn();
    }
    else if ([self.delegate respondsToSelector:@selector(didClickRePlayBtnForSvSharePanel:)]) {
        [self.delegate didClickRePlayBtnForSvSharePanel:self];
    }
}

- (void)didClickWechatBtn
{
    if ([self.delegate respondsToSelector:@selector(svSharePanel:didClickWechatItem:)]) {
        [self.delegate svSharePanel:self didClickWechatItem:self.wechatBtn.shareItem];
    }
}

- (void)didClickCircleBtn
{
    if ([self.delegate respondsToSelector:@selector(svSharePanel:didClickCircleItem:)]) {
        [self.delegate svSharePanel:self didClickCircleItem:self.circleBtn.shareItem];
    }
}

- (void)selfTap
{
}
@end
