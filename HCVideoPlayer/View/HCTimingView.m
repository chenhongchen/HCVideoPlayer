//
//  HCTimingView.m
//  HCVideoPlayer
//
//  Created by chc on 2019/1/14.
//  Copyright © 2019年 chc. All rights reserved.
//

#import "HCTimingView.h"
#import "HCVideoPlayerConst.h"

@interface HCTimingView ()
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIButton *unuseBtn;
@property (nonatomic, weak) UIButton *playTheEpsBtn;
@property (nonatomic, weak) UIButton *play30Btn;
@property (nonatomic, weak) UIButton *play60Btn;
@property (nonatomic, weak) UIButton *selBtn;
@end

@implementation HCTimingView

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

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        UILabel *titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;
        titleLabel.text = @"定时关闭播放：";
        titleLabel.font = kVP_Font(14);
        titleLabel.textColor = kVP_ColorWithHexValueA(0xE6E6E6, 1);
    }
    return _titleLabel;
}

- (UIButton *)unuseBtn
{
    if (_unuseBtn == nil) {
        UIButton *unuseBtn = [[UIButton alloc] init];
        [self.contentView addSubview:unuseBtn];
        _unuseBtn = unuseBtn;
        unuseBtn.titleLabel.font = kVP_Font(16);
        [unuseBtn setTitle:@"不开启" forState:UIControlStateNormal];
        [unuseBtn setTitleColor:kVP_ColorWithHexValueA(0xE6E6E6, 1) forState:UIControlStateNormal];
        [unuseBtn setTitleColor:kVP_ColorWithHexValueA(0x4DA6EB, 1) forState:UIControlStateSelected];
        [unuseBtn addTarget:self action:@selector(didClickTimeSetBtn:) forControlEvents:UIControlEventTouchUpInside];
        unuseBtn.tag = HCTimingTypeUnuse;
    }
    return _unuseBtn;
}

- (UIButton *)playTheEpsBtn
{
    if (_playTheEpsBtn == nil) {
        UIButton *playTheEpsBtn = [[UIButton alloc] init];
        [self.contentView addSubview:playTheEpsBtn];
        _playTheEpsBtn = playTheEpsBtn;
        playTheEpsBtn.titleLabel.font = kVP_Font(16);
        [playTheEpsBtn setTitle:@"播完本集" forState:UIControlStateNormal];
        [playTheEpsBtn setTitleColor:kVP_ColorWithHexValueA(0xE6E6E6, 1) forState:UIControlStateNormal];
        [playTheEpsBtn setTitleColor:kVP_ColorWithHexValueA(0x4DA6EB , 1) forState:UIControlStateSelected];
        [playTheEpsBtn addTarget:self action:@selector(didClickTimeSetBtn:) forControlEvents:UIControlEventTouchUpInside];
        playTheEpsBtn.tag = HCTimingTypePlayTheEps;
    }
    return _playTheEpsBtn;
}

- (UIButton *)play30Btn
{
    if (_play30Btn == nil) {
        UIButton *play30Btn = [[UIButton alloc] init];
        [self.contentView addSubview:play30Btn];
        _play30Btn = play30Btn;
        play30Btn.titleLabel.font = kVP_Font(16);
        [play30Btn setTitle:@"30:00" forState:UIControlStateNormal];
        [play30Btn setTitleColor:kVP_ColorWithHexValueA(0xE6E6E6, 1) forState:UIControlStateNormal];
        [play30Btn setTitleColor:kVP_ColorWithHexValueA(0x4DA6EB , 1) forState:UIControlStateSelected];
        [play30Btn addTarget:self action:@selector(didClickTimeSetBtn:) forControlEvents:UIControlEventTouchUpInside];
        play30Btn.tag = HCTimingTypePlay30;
    }
    return _play30Btn;
}

- (UIButton *)play60Btn
{
    if (_play60Btn == nil) {
        UIButton *play60Btn = [[UIButton alloc] init];
        [self.contentView addSubview:play60Btn];
        _play60Btn = play60Btn;
        play60Btn.titleLabel.font = kVP_Font(16);
        [play60Btn setTitle:@"60:00" forState:UIControlStateNormal];
        [play60Btn setTitleColor:kVP_ColorWithHexValueA(0xE6E6E6, 1) forState:UIControlStateNormal];
        [play60Btn setTitleColor:kVP_ColorWithHexValueA(0x4DA6EB , 1) forState:UIControlStateSelected];
        [play60Btn addTarget:self action:@selector(didClickTimeSetBtn:) forControlEvents:UIControlEventTouchUpInside];
        play60Btn.tag = HCTimingTypePlay60;
    }
    return _play60Btn;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfTap)];
        [self addGestureRecognizer:tap];
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

#pragma mark - 外部方法
+ (HCTimingView *)showAtView:(UIView *)view
{
    if (![view isKindOfClass:[UIView class]]) {
        return nil;
    }
    HCTimingView *timingView = [[HCTimingView alloc] init];
    timingView.frame = view.bounds;
    [view addSubview:timingView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.03 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            timingView.backgroundColor = kVP_Color(0, 0, 0, 0.85);
        }];
    });
    
    return timingView;
}

- (void)hiddenPanel
{
    [UIView animateWithDuration:kVP_AniDuration animations:^{
        self.backgroundColor = kVP_Color(0, 0, 0, 0.0);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)setType:(HCTimingType)type
{
    _type = type;
    switch (_type) {
        case HCTimingTypeUnuse:
        {
            self.selBtn.selected = NO;
            self.selBtn = self.unuseBtn;
            self.selBtn.selected = YES;
        }
            break;
        case HCTimingTypePlayTheEps:
        {
            self.selBtn.selected = NO;
            self.selBtn = self.playTheEpsBtn;
            self.selBtn.selected = YES;
        }
            break;
        case HCTimingTypePlay30:
        {
            self.selBtn.selected = NO;
            self.selBtn = self.play30Btn;
            self.selBtn.selected = YES;
        }
            break;
        case HCTimingTypePlay60:
        {
            self.selBtn.selected = NO;
            self.selBtn = self.play60Btn;
            self.selBtn.selected = YES;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - 事件
- (void)selfTap
{
    [self hiddenPanel];
}

- (void)didClickTimeSetBtn:(UIButton *)btn
{
    if (self.selBtn == btn) {
        return;
    }
    self.selBtn.selected = NO;
    self.selBtn = btn;
    self.selBtn.selected = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationVideoPlayerDidSetTiming object:nil userInfo:@{@"type" : @(btn.tag)}];
    [self hiddenPanel];
}

#pragma mark - 内部方法
- (void)setupFrame
{
    CGFloat width = 0;
    CGFloat height = 0;
    CGFloat x = 0;
    CGFloat y = 0;
    
    CGFloat selfH = self.bounds.size.height;
    CGFloat selfW = self.bounds.size.width;
    
    [self.titleLabel sizeToFit];
    width = CGRectGetWidth(self.titleLabel.frame);
    height = CGRectGetHeight(self.titleLabel.frame);
    x = 0;
    y = (selfH - height) * 0.5;
    self.titleLabel.frame = CGRectMake(x, y, width, height);
    
    [self.unuseBtn sizeToFit];
    width = CGRectGetWidth(self.unuseBtn.frame);
    height = 30;
    x = CGRectGetMaxX(self.titleLabel.frame) + 44;
    y = (selfH - height) * 0.5;
    self.unuseBtn.frame = CGRectMake(x, y, width, height);
    
    [self.playTheEpsBtn sizeToFit];
    width = CGRectGetWidth(self.playTheEpsBtn.frame);
    height = 30;
    x = CGRectGetMaxX(self.unuseBtn.frame) + 30;
    y = (selfH - height) * 0.5;
    self.playTheEpsBtn.frame = CGRectMake(x, y, width, height);
    
    [self.play30Btn sizeToFit];
    width = CGRectGetWidth(self.play30Btn.frame);
    height = 30;
    x = CGRectGetMaxX(self.playTheEpsBtn.frame) + 30;
    y = (selfH - height) * 0.5;
    self.play30Btn.frame = CGRectMake(x, y, width, height);
    
    [self.play60Btn sizeToFit];
    width = CGRectGetWidth(self.play60Btn.frame);
    height = 30;
    x = CGRectGetMaxX(self.play30Btn.frame) + 30;
    y = (selfH - height) * 0.5;
    self.play60Btn.frame = CGRectMake(x, y, width, height);
    
    width = CGRectGetMaxX(self.play60Btn.frame);
    height = self.vp_height;
    x = (selfW - width) * 0.5;
    y = 0;
    self.contentView.frame = CGRectMake(x, y, width, height);
}

@end
