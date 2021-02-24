//
//  HCMorePanel.m
//  HCVideoPlayer
//
//  Created by chc on 2018/1/10.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "HCMorePanel.h"
#import "HCVideoPlayerConst.h"
#import "HCIconSlider.h"
#import <MediaPlayer/MediaPlayer.h>
#import<AVFoundation/AVFoundation.h>
#import "BrightnessView.h"
#import "HCVerButton.h"

@interface HCMorePanel ()<HCIconSliderDelegate>
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, weak) UIView *topContentView;
// 缓
@property (nonatomic, weak) HCVerButton *dlBtn;
// 投
@property (nonatomic, weak) HCVerButton *ctBtn;
// 换
@property (nonatomic, weak) HCVerButton *stBtn;
// 定时关
@property (nonatomic, weak) HCVerButton *timeCloseBtn;
// 加入看单
@property (nonatomic, weak) HCVerButton *addToMyDefWBBtn;
@property (nonatomic, weak) UIView *topHLine;

//
@property (nonatomic, weak) UILabel *speedLabel;
@property (nonatomic, weak) UIView *playSpeedContentView;
@property (nonatomic, weak) UILabel *playSpeedTitleLabel;
@property (nonatomic, strong) NSArray *speedValues;
@property (nonatomic, strong) NSArray *speedTexts;
@property (nonatomic, strong) NSArray *playSpeedBtns;
@property (nonatomic, weak) UIView *middleHLine;

//
@property (nonatomic, weak) UIView *bottomContentView;
@property (nonatomic, weak) UILabel *fullScreenShowLabel;
@property (nonatomic, weak) UISwitch *fullScreenShowSwt;
@property (nonatomic, weak) UILabel *skipLabel;
@property (nonatomic, weak) UISwitch *skipSwt;
@property (nonatomic, weak) UILabel *smallWindowLabel;
@property (nonatomic, weak) UISwitch *smallWindowSwt;
@property (nonatomic, weak) HCIconSlider *voiceSlider;
@property (nonatomic, weak) HCIconSlider *brightSlider;
@property (nonatomic, strong) UISlider* volumeViewSlider;
@property (nonatomic, weak) UIButton *selSpeedBtn;
@end

@implementation HCMorePanel
#pragma mark - 懒加载
- (UIScrollView *)scrollView
{
    if (_scrollView == nil) { 
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        [self addSubview:scrollView];
        _scrollView = scrollView;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        [HCVPTool scrollView:scrollView unAutomaticallyAdjustsScrollViewInsetsForController:[HCVPTool myControllerWithView:self]];
    }
    return _scrollView;
}

- (UIView *)contentView
{
    if (_contentView == nil) {
        UIView *contentView = [[UIView alloc] init];
        [self.scrollView addSubview:contentView];
        _contentView = contentView;
    }
    return _contentView;
}

- (UIView *)topContentView
{
    if (_topContentView == nil) {
        UIView *topContentView = [[UIView alloc] init];
        [self.contentView addSubview:topContentView];
        _topContentView = topContentView;
    }
    return _topContentView;
}

- (HCVerButton *)dlBtn
{
    if (_dlBtn == nil) {
        HCVerButton *dlBtn = [[HCVerButton alloc] init];
        [self.topContentView addSubview:dlBtn];
        _dlBtn = dlBtn;
        [dlBtn setImage:[UIImage vp_imageWithName:@"vp_more_download"] forState:UIControlStateNormal];
        [dlBtn setTitle:@"缓存" forState:UIControlStateNormal];
        dlBtn.titleFont = [UIFont systemFontOfSize:14];
        dlBtn.padding = 6;
        dlBtn.titleLabel.textColor = kVP_ColorWithHexValueA(0xE6E6E6, 1);
        [dlBtn addTarget:self action:@selector(didClickDlBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dlBtn;
}

- (HCVerButton *)ctBtn
{
    if (_ctBtn == nil) {
        HCVerButton *ctBtn = [[HCVerButton alloc] init];
        [self.topContentView addSubview:ctBtn];
        _ctBtn = ctBtn;
        [ctBtn setImage:[UIImage vp_imageWithName:@"vp_more_cast"] forState:UIControlStateNormal];
        [ctBtn setTitle:@"投屏" forState:UIControlStateNormal];
        ctBtn.titleFont = [UIFont systemFontOfSize:14];
        ctBtn.padding = 6;
        ctBtn.titleLabel.textColor = kVP_ColorWithHexValueA(0xE6E6E6, 1);
        [ctBtn addTarget:self action:@selector(didClickCtBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _ctBtn;
}

- (HCVerButton *)stBtn
{
    if (_stBtn == nil) {
        HCVerButton *stBtn = [[HCVerButton alloc] init];
        [self.topContentView addSubview:stBtn];
        _stBtn = stBtn;
        [stBtn setImage:[UIImage vp_imageWithName:@"vp_more_switch"] forState:UIControlStateNormal];
        [stBtn setTitle:@"切换源" forState:UIControlStateNormal];
        stBtn.titleFont = [UIFont systemFontOfSize:14];
        stBtn.padding = 6;
        stBtn.titleLabel.textColor = kVP_ColorWithHexValueA(0xE6E6E6, 1);
        [stBtn addTarget:self action:@selector(didClickStBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _stBtn;
}

- (HCVerButton *)timeCloseBtn
{
    if (_timeCloseBtn == nil) {
        HCVerButton *timeCloseBtn = [[HCVerButton alloc] init];
        [self.topContentView addSubview:timeCloseBtn];
        _timeCloseBtn = timeCloseBtn;
        [timeCloseBtn setImage:[UIImage vp_imageWithName:@"vp_more_time"] forState:UIControlStateNormal];
        [timeCloseBtn setTitle:@"定时关" forState:UIControlStateNormal];
        timeCloseBtn.titleFont = [UIFont systemFontOfSize:14];
        timeCloseBtn.padding = 6;
        timeCloseBtn.titleLabel.textColor = kVP_ColorWithHexValueA(0xE6E6E6, 1);
        [timeCloseBtn addTarget:self action:@selector(didClickTimeCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _timeCloseBtn;
}

- (HCVerButton *)addToMyDefWBBtn
{
    if (_addToMyDefWBBtn == nil) {
        HCVerButton *addToMyDefWBBtn = [[HCVerButton alloc] init];
        [self.topContentView addSubview:addToMyDefWBBtn];
        _addToMyDefWBBtn = addToMyDefWBBtn;
        [addToMyDefWBBtn setImage:[UIImage vp_imageWithName:@"vp_more_collect"] forState:UIControlStateNormal];
        [addToMyDefWBBtn setImage:[UIImage vp_imageWithName:@"vp_more_collect_h"] forState:UIControlStateSelected];
        [addToMyDefWBBtn setTitle:@"加看单" forState:UIControlStateNormal];
        addToMyDefWBBtn.titleFont = [UIFont systemFontOfSize:14];
        addToMyDefWBBtn.padding = 6;
        addToMyDefWBBtn.titleLabel.textColor = kVP_ColorWithHexValueA(0xE6E6E6, 1);
        [addToMyDefWBBtn addTarget:self action:@selector(didClickAddToMyDefWBBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _addToMyDefWBBtn;
}

- (UIView *)topHLine
{
    if (_topHLine == nil) {
        UIView *topLine = [[UIView alloc] init];
        [self.topContentView addSubview:topLine];
        _topHLine = topLine;
        topLine.backgroundColor = kVP_ColorWithHexValueA(0x4D4D4D, 1);
    }
    return _topHLine;
}

- (UIView *)playSpeedContentView
{
    if (_playSpeedContentView == nil) {
        UIView *playSpeedContentView = [[UIView alloc] init];
        [self.contentView addSubview:playSpeedContentView];
        _playSpeedContentView = playSpeedContentView;
    }
    return _playSpeedContentView;
}

- (UILabel *)playSpeedTitleLabel
{
    if (_playSpeedTitleLabel == nil) {
        UILabel *playSpeedTitleLabel = [[UILabel alloc] init];
        [self.playSpeedContentView addSubview:playSpeedTitleLabel];
        _playSpeedTitleLabel = playSpeedTitleLabel;
        playSpeedTitleLabel.text = @"倍速播放：";
        playSpeedTitleLabel.textColor = kVP_ColorWithHexValueA(0xE6E6E6, 1);
        playSpeedTitleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _playSpeedTitleLabel;
}

- (UIView *)middleHLine
{
    if (_middleHLine == nil) {
        UIView *topLine = [[UIView alloc] init];
        [self.playSpeedContentView addSubview:topLine];
        _middleHLine = topLine;
        topLine.backgroundColor = kVP_ColorWithHexValueA(0x4D4D4D, 1);
    }
    return _middleHLine;
}

- (UIView *)bottomContentView
{
    if (_bottomContentView == nil) {
        UIView *bottomContentView = [[UIView alloc] init];
        [self.contentView addSubview:bottomContentView];
        _bottomContentView = bottomContentView;
    }
    return _bottomContentView;
}

- (UILabel *)fullScreenShowLabel
{
    if (_fullScreenShowLabel == nil) {
        UILabel *fullScreenShowLabel = [[UILabel alloc] init];
        [self.bottomContentView addSubview:fullScreenShowLabel];
        _fullScreenShowLabel = fullScreenShowLabel;
        fullScreenShowLabel.font = [UIFont systemFontOfSize:14];
        fullScreenShowLabel.textColor = kVP_ColorWithHexValueA(0xE6E6E6, 1);
        fullScreenShowLabel.text = @"满屏显示（字幕可能被截断）：";
    }
    return _fullScreenShowLabel;
}

- (UISwitch *)fullScreenShowSwt
{
    if (_fullScreenShowSwt == nil) {
        UISwitch *fullScreenShowSwt = [[UISwitch alloc] init];
        [self.bottomContentView addSubview:fullScreenShowSwt];
        _fullScreenShowSwt = fullScreenShowSwt;
        fullScreenShowSwt.layer.masksToBounds = YES;
        fullScreenShowSwt.backgroundColor = kVP_ColorWithHexValueA(0xB2B2B2, 1);
        fullScreenShowSwt.tintColor = kVP_ColorWithHexValueA(0xB2B2B2, 1);
        fullScreenShowSwt.onTintColor = kVP_ColorWithHexValueA(0x4DA6EB, 1);
        BOOL fullScreenShow = [[NSUserDefaults standardUserDefaults] boolForKey:VPFullScreenShow];
        fullScreenShowSwt.on = fullScreenShow;
        [fullScreenShowSwt addTarget:self action:@selector(didClickFullScreenShowSwt) forControlEvents:UIControlEventValueChanged];
    }
    return _fullScreenShowSwt;
}

- (UILabel *)skipLabel
{
    if (_skipLabel == nil) {
        UILabel *skipLabel = [[UILabel alloc] init];
        [self.bottomContentView addSubview:skipLabel];
        _skipLabel = skipLabel;
        skipLabel.font = [UIFont systemFontOfSize:14];
        skipLabel.textColor = kVP_ColorWithHexValueA(0xE6E6E6, 1);
        skipLabel.text = @"自动跳过片头片尾：";
    }
    return _skipLabel;
}

- (UISwitch *)skipSwt
{
    if (_skipSwt == nil) {
        UISwitch *skipSwt = [[UISwitch alloc] init];
        [self.bottomContentView addSubview:skipSwt];
        _skipSwt = skipSwt;
        skipSwt.layer.masksToBounds = YES;
        skipSwt.backgroundColor = kVP_ColorWithHexValueA(0xB2B2B2, 1);
        skipSwt.tintColor = kVP_ColorWithHexValueA(0xB2B2B2, 1);
        skipSwt.onTintColor = kVP_ColorWithHexValueA(0x4DA6EB, 1);
        BOOL autoSkippingTitlesAndEnds = ![[NSUserDefaults standardUserDefaults] boolForKey:VPUDKeyNotAutoSkippingTitlesAndEnds];
        skipSwt.on = autoSkippingTitlesAndEnds;
        [skipSwt addTarget:self action:@selector(didClickSkipSwt) forControlEvents:UIControlEventValueChanged];
    }
    return _skipSwt;
}

- (UILabel *)smallWindowLabel
{
    if (_smallWindowLabel == nil) {
        UILabel *smallWindowLabel = [[UILabel alloc] init];
        [self.bottomContentView addSubview:smallWindowLabel];
        _smallWindowLabel = smallWindowLabel;
        smallWindowLabel.font = [UIFont systemFontOfSize:14];
        smallWindowLabel.textColor = kVP_ColorWithHexValueA(0xE6E6E6, 1);
        smallWindowLabel.text = @"悬浮小窗：";
    }
    return _smallWindowLabel;
}

- (UISwitch *)smallWindowSwt
{
    if (_smallWindowSwt == nil) {
        UISwitch *smallWindowSwt = [[UISwitch alloc] init];
        [self.bottomContentView addSubview:smallWindowSwt];
        _smallWindowSwt = smallWindowSwt;
        smallWindowSwt.layer.masksToBounds = YES;
        smallWindowSwt.backgroundColor = kVP_ColorWithHexValueA(0xB2B2B2, 1);
        smallWindowSwt.tintColor = kVP_ColorWithHexValueA(0xB2B2B2, 1);
        smallWindowSwt.onTintColor = kVP_ColorWithHexValueA(0x4DA6EB, 1);
        BOOL isSmallWindwoModleClose = [[NSUserDefaults standardUserDefaults] boolForKey:VPUDKeyIsSmallWindwoModleClose];
        smallWindowSwt.on = !isSmallWindwoModleClose;
        [smallWindowSwt addTarget:self action:@selector(didClickSmallWindowSwt) forControlEvents:UIControlEventValueChanged];
    }
    return _smallWindowSwt;
}

- (HCIconSlider *)voiceSlider
{
    if (_voiceSlider == nil) {
        HCIconSlider *voiceSlider = [[HCIconSlider alloc] init];
        [self.bottomContentView addSubview:voiceSlider];
        _voiceSlider = voiceSlider;
        voiceSlider.delegate = self;
        voiceSlider.leftImageName = @"vp_more_unvoice";
        voiceSlider.rightImageName = @"vp_more_voice";
    }
    return _voiceSlider;
}

- (HCIconSlider *)brightSlider
{
    if (_brightSlider == nil) {
        HCIconSlider *brightSlider = [[HCIconSlider alloc] init];
        [self.bottomContentView addSubview:brightSlider];
        _brightSlider = brightSlider;
        brightSlider.delegate = self;
        brightSlider.leftImageName = @"vp_more_unbright";
        brightSlider.rightImageName = @"vp_more_bright";
    }
    return _brightSlider;
}

- (UISlider *)volumeViewSlider
{
    if (_volumeViewSlider == nil) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame:CGRectZero];
        volumeView.alpha = 0.0001f;
        volumeView.showsRouteButton = NO;
        //默认YES
        volumeView.showsVolumeSlider = YES;
        [self addSubview:volumeView];
        [volumeView userActivity];
        
        for (UIView *view in [volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                _volumeViewSlider = (UISlider*)view;
                break;
            }
        }
    }
    return _volumeViewSlider;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupSelfGesture];
        [self setupUI];
        [self setupPlaySpeedBtns];
        [self setupSliderImageWidth];
        [self volumeViewSlider];
        self.brightSlider.value = [UIScreen mainScreen].brightness;
        self.voiceSlider.value = [[AVAudioSession sharedInstance] outputVolume];
        // 添加音量变化通知
        [[AVAudioSession sharedInstance] addObserver:self forKeyPath:@"outputVolume" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:(void *)[AVAudioSession sharedInstance]];
    }
    return self;
}

- (void)dealloc
{
    VPLog(@"dealloc - HCMorePanel");
    [[AVAudioSession sharedInstance] removeObserver:self forKeyPath:@"outputVolume" context:(void *)[AVAudioSession sharedInstance]];
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

- (void)setupUI
{
    self.enableDlBtn = YES;
    self.enableStBtn = YES;
    self.enableAddToMyDefWBBtn = YES;
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
    
    [BrightnessView unShowWhenChangeBright];
}

- (void)hiddenPanel
{
    [UIView animateWithDuration:kVP_AniDuration animations:^{
        self.backgroundColor = kVP_Color(0, 0, 0, 0.0);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(didHiddenMorePanel)]) {
            [self.delegate didHiddenMorePanel];
        }
    }];
    
    [BrightnessView showWhenChangeBright];
}

- (void)setRate:(CGFloat)rate
{
    _rate = rate;
    for (int i = 0; i < _speedValues.count; i ++) {
        NSNumber *num = _speedValues[i];
        if (fabs(num.floatValue - _rate) < 0.1) {
            _selSpeedBtn.selected = NO;
            _selSpeedBtn = _playSpeedBtns[i];
            _selSpeedBtn.selected = YES;
        }
    }
}

- (void)setCollectStatus:(BOOL)collectStatus
{
    _collectStatus = collectStatus;
    self.addToMyDefWBBtn.selected = collectStatus;
    [self setupFrame];
}

- (void)setEnableDlBtn:(BOOL)enableDlBtn
{
    _enableDlBtn = enableDlBtn;
    self.dlBtn.enabled = _enableDlBtn;
}

- (void)setEnableStBtn:(BOOL)enableStBtn
{
    _enableStBtn = enableStBtn;
    self.stBtn.enabled = _enableStBtn;
}

- (void)setEnableAddToMyDefWBBtn:(BOOL)enableAddToMyDefWBBtn
{
    _enableAddToMyDefWBBtn = enableAddToMyDefWBBtn;
    self.addToMyDefWBBtn.enabled = _enableAddToMyDefWBBtn;
}

#pragma mark - 事件
- (void)selfTap
{
    [self hiddenPanel];
}

- (void)selfPan
{
    
}

- (void)didClickDlBtn
{
    if ([self.delegate respondsToSelector:@selector(didClickDlBtnForMorePanel:)]) {
        [self.delegate didClickDlBtnForMorePanel:self];
    }
    [self hiddenPanel];
    [self impactOccurred];
}

- (void)didClickCtBtn
{
    if ([self.delegate respondsToSelector:@selector(didClickCtBtnForMorePanel:)]) {
        [self.delegate didClickCtBtnForMorePanel:self];
    }
    [self hiddenPanel];
    [self impactOccurred];
}

- (void)didClickStBtn
{
    if ([self.delegate respondsToSelector:@selector(didClickStBtnForMorePanel:)]) {
        [self.delegate didClickStBtnForMorePanel:self];
    }
    [self hiddenPanel];
    [self impactOccurred];
}

- (void)didClickTimeCloseBtn
{
    if ([self.delegate respondsToSelector:@selector(didClickTimeCloseBtnForMorePanel:)]) {
        [self.delegate didClickTimeCloseBtnForMorePanel:self];
    }
    [self hiddenPanel];
    [self impactOccurred];
}

- (void)didClickAddToMyDefWBBtn
{
    self.addToMyDefWBBtn.selected = !self.addToMyDefWBBtn.selected;
    if ([self.delegate respondsToSelector:@selector(morePanel:didChangeColloctStatus:)]) {
        [self.delegate morePanel:self didChangeColloctStatus:self.addToMyDefWBBtn.selected];
    }
    [self impactOccurred];
}

- (void)speedBtnClicked:(UIButton *)btn
{
    _selSpeedBtn.selected = NO;
    _selSpeedBtn = btn;
    _selSpeedBtn.selected = YES;
    
    NSNumber *num = _speedValues[btn.tag];
    if ([self.delegate respondsToSelector:@selector(morePanel:didSelectRate:)]) {
        [self.delegate morePanel:self didSelectRate:num.floatValue];
    }
    [self impactOccurred];
}

- (void)didClickFullScreenShowSwt
{
    BOOL fullScreenShow = self.fullScreenShowSwt.on;
    [[NSUserDefaults standardUserDefaults] setBool:fullScreenShow forKey:VPFullScreenShow];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if ([self.delegate respondsToSelector:@selector(morePanel:didChangeFullScreenShowValue:)]) {
        [self.delegate morePanel:self didChangeFullScreenShowValue:fullScreenShow];
    }
}

- (void)didClickSkipSwt
{
    BOOL autoSkippingTitlesAndEnds = self.skipSwt.on;
    [[NSUserDefaults standardUserDefaults] setBool:!autoSkippingTitlesAndEnds forKey:VPUDKeyNotAutoSkippingTitlesAndEnds];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if ([self.delegate respondsToSelector:@selector(morePanel:didChangeAutoSkipValue:)]) {
        [self.delegate morePanel:self didChangeAutoSkipValue:autoSkippingTitlesAndEnds];
    }
}

- (void)didClickSmallWindowSwt
{
    BOOL isSmallWindwoModleClose = !self.smallWindowSwt.on;
    [[NSUserDefaults standardUserDefaults] setBool:isSmallWindwoModleClose forKey:VPUDKeyIsSmallWindwoModleClose];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if ([self.delegate respondsToSelector:@selector(morePanel:didChangeSmallWindowValue:)]) {
        [self.delegate morePanel:self didChangeSmallWindowValue:!isSmallWindwoModleClose];
    }
}

#pragma mark - 内部方法
- (void)setupFrame
{
    CGFloat width = ceil(self.dlBtn.imageView.image.size.width);
    CGFloat height = ceil([self.dlBtn heightToFitWidth:width]);
    CGFloat x = 0;
    CGFloat y = 0;
    self.dlBtn.frame = CGRectMake(x, y, width, height);
    
    width = ceil(self.ctBtn.imageView.image.size.width);
    height = ceil([self.ctBtn heightToFitWidth:width]);
    x = ceil(CGRectGetMaxX(self.dlBtn.frame) + 45);
    y = 0;
    self.ctBtn.frame = CGRectMake(x, y, width, height);
    
    width = ceil(self.stBtn.imageView.image.size.width);
    height = ceil([self.stBtn heightToFitWidth:width]);
    x = ceil(CGRectGetMaxX(self.ctBtn.frame) + 45);
    y = 0;
    self.stBtn.frame = CGRectMake(x, y, width, height);
    
    width = ceil(self.timeCloseBtn.imageView.image.size.width);
    height = ceil([self.timeCloseBtn heightToFitWidth:width]);
    x = ceil(CGRectGetMaxX(self.stBtn.frame) + 45);
    y = 0;
    self.timeCloseBtn.frame = CGRectMake(x, y, width, height);
    
    width = ceil(self.addToMyDefWBBtn.imageView.image.size.width);
    height = ceil([self.addToMyDefWBBtn heightToFitWidth:width]);
    x = ceil(CGRectGetMaxX(self.timeCloseBtn.frame) + 45);
    y = 0;
    self.addToMyDefWBBtn.frame = CGRectMake(x, y, width, height);
    
    width = CGRectGetMaxX(self.addToMyDefWBBtn.frame);
    height = 1.0 / [UIScreen mainScreen].scale;
    x = 0;
    y = CGRectGetMaxY(self.addToMyDefWBBtn.frame) + 25;
    self.topHLine.frame = CGRectMake(x, y, width, height);
    
    height = CGRectGetMaxY(self.topHLine.frame);
    x = 0;
    y = 25;
    self.topContentView.frame = CGRectMake(x, y, width, height);
    
    CGSize size = [self setupPlaySpeedContentViewSubViewsFrame];
    x = 0;
    y = ceil(CGRectGetMaxY(self.addToMyDefWBBtn.frame) + 52);
    self.playSpeedContentView.frame = CGRectMake(x, y, ceil(size.width), ceil(size.height));
    
    [self.fullScreenShowSwt sizeToFit];
    width = CGRectGetWidth(self.fullScreenShowSwt.frame);
    height = CGRectGetHeight(self.fullScreenShowSwt.frame);
    x = CGRectGetWidth(self.topContentView.frame) - CGRectGetWidth(self.fullScreenShowSwt.frame);
    y = 25;
    self.fullScreenShowSwt.frame = CGRectMake(x, y, width, height);
    self.fullScreenShowSwt.layer.cornerRadius = height * 0.5;
    
    width = [self.fullScreenShowLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
    x = 0;
    self.fullScreenShowLabel.frame = CGRectMake(x, y, width, height);
    
    [self.skipSwt sizeToFit];
    width = CGRectGetWidth(self.skipSwt.frame);
    height = CGRectGetHeight(self.skipSwt.frame);
    x = CGRectGetWidth(self.topContentView.frame) - CGRectGetWidth(self.skipSwt.frame);
    y = CGRectGetMaxY(self.fullScreenShowSwt.frame) + 25;
    self.skipSwt.frame = CGRectMake(x, y, width, height);
    self.skipSwt.layer.cornerRadius = height * 0.5;
    
    width = [self.skipLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
    x = 0;
    self.skipLabel.frame = CGRectMake(x, y, width, height);
    
    [self.smallWindowSwt sizeToFit];
    width = CGRectGetWidth(self.smallWindowSwt.frame);
    height = CGRectGetHeight(self.smallWindowSwt.frame);
    x = CGRectGetWidth(self.topContentView.frame) - CGRectGetWidth(self.smallWindowSwt.frame);
    y = CGRectGetMaxY(self.skipSwt.frame) + 25;
    self.smallWindowSwt.frame = CGRectMake(x, y, width, height);
    self.smallWindowSwt.layer.cornerRadius = height * 0.5;
    
    width = [self.smallWindowLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)].width;
    x = 0;
    self.smallWindowLabel.frame = CGRectMake(x, y, width, height);
    
    x = 0;
    y = ceil(CGRectGetMaxY(self.smallWindowSwt.frame) + 25);
    width = CGRectGetWidth(self.topContentView.frame);
    height = ceil([self.brightSlider heightToFit]);
    self.brightSlider.frame = CGRectMake(x, y, width, height);
    
    x = 0;
    y = ceil(CGRectGetMaxY(self.brightSlider.frame) + 25);
    width = CGRectGetWidth(self.topContentView.frame);
    height = ceil([self.brightSlider heightToFit]);
    self.voiceSlider.frame = CGRectMake(x, y, width, height);
    
    x = 0;
    y = CGRectGetMaxY(self.playSpeedContentView.frame);
    width = CGRectGetWidth(self.topContentView.frame);
    height = CGRectGetMaxY(self.voiceSlider.frame) + 25;
    self.bottomContentView.frame = CGRectMake(x, y, width, height);
    
    width = ceil(CGRectGetWidth(self.topContentView.frame));
    height = ceil(CGRectGetMaxY(self.bottomContentView.frame));
    x = ceil((self.bounds.size.width - width) * 0.5);
    y = 0;
    self.contentView.frame = CGRectMake(x, y, width, height);
    
    self.scrollView.frame = self.bounds;
    self.scrollView.contentSize = CGSizeMake(0, CGRectGetMaxY(self.contentView.frame));
}

- (void)setupPlaySpeedBtns
{
    _speedValues = @[@0.5,@0.75,@1.0,@1.25,@1.5,@2.0];
    _speedTexts = @[@"0.5X",@"0.75X",@"1X",@"1.25X",@"1.5X",@"2X"];
    
    NSMutableArray *arrayM = [NSMutableArray array];
    for (int i = 0; i < _speedTexts.count; i ++) {
        NSString *text = _speedTexts[i];
        UIButton *btn = [[UIButton alloc] init];
        [self.playSpeedContentView addSubview:btn];
        [btn setTitle:text forState:UIControlStateNormal];
        [btn setTitleColor:kVP_ColorWithHexValueA(0xE6E6E6, 1) forState:UIControlStateNormal];
        [btn setTitleColor:kVP_ColorWithHexValueA(0x4DA6EB, 1) forState:UIControlStateSelected];
        btn.titleLabel.font = [UIFont systemFontOfSize:17];
        btn.tag = i;
        [btn addTarget:self action:@selector(speedBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [arrayM addObject:btn];
    }
    _playSpeedBtns = arrayM;
    [self setupPlaySpeedContentViewSubViewsFrame];
}

- (CGSize)setupPlaySpeedContentViewSubViewsFrame
{
    CGFloat maxHeight = ceil(MAX(self.playSpeedTitleLabel.font.lineHeight, ((UIButton *)self.playSpeedBtns.firstObject).titleLabel.font.lineHeight));
    CGSize size = [self.playSpeedTitleLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGFloat x = 0;
    CGFloat y = 25;
    self.playSpeedTitleLabel.frame = CGRectMake(x, y, size.width, maxHeight);
    if (!_playSpeedBtns.count) {
        return CGSizeZero;
    }
    CGFloat width = (CGRectGetWidth(self.topContentView.frame) - CGRectGetWidth(self.playSpeedTitleLabel.frame) + 16) / _playSpeedBtns.count;
    UIView *lastView = self.playSpeedTitleLabel;
    for (UIButton *btn in _playSpeedBtns) {
        x = ceil(CGRectGetMaxX(lastView.frame));
        y = 25;
        btn.frame = CGRectMake(x, y, width, maxHeight);
        lastView = btn;
    }
    
    //
    size = self.topHLine.bounds.size;
    x = 0;
    y = CGRectGetMaxY(lastView.frame) + 25;
    self.middleHLine.frame = CGRectMake(x, y, size.width, size.height);
    
    //
    size = CGSizeMake(CGRectGetMaxX(self.middleHLine.frame), CGRectGetMaxY(self.middleHLine.frame));
    return size;
}

- (void)setupSliderImageWidth
{
    CGFloat leftImageWidth = MAX([UIImage vp_imageWithName:@"vp_more_unbright"].size.width, [UIImage vp_imageWithName:@"vp_more_unvoice"].size.width);
    CGFloat rightImageWidth = MAX([UIImage vp_imageWithName:@"vp_more_bright"].size.width, [UIImage vp_imageWithName:@"vp_more_voice"].size.width);
    self.voiceSlider.leftImageWidth = leftImageWidth;
    self.voiceSlider.rightImageWidth = rightImageWidth;
    self.brightSlider.leftImageWidth = leftImageWidth;
    self.brightSlider.rightImageWidth = rightImageWidth;
}

- (void)impactOccurred
{
    if (@available(iOS 10.0, *)) {
        UIImpactFeedbackGenerator *feedBackGenertor = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
        [feedBackGenertor impactOccurred];
    } else {
        // Fallback on earlier versions
    }
}

#pragma mark - HCIconSliderDelegate
- (void)iconSlider:(HCIconSlider *)iconSlider didChangedSliderValue:(double)sliderValue
{
    if (self.voiceSlider == iconSlider) {
        self.volumeViewSlider.value = sliderValue;
    }
    if (self.brightSlider == iconSlider) {
        [[UIScreen mainScreen] setBrightness:sliderValue];
    }
}

- (void)iconSlider:(HCIconSlider *)iconSlider didSliderUpAtValue:(CGFloat)value
{
    if (self.voiceSlider == iconSlider) {
        self.volumeViewSlider.value = value;
    }
    if (self.brightSlider == iconSlider) {
        [[UIScreen mainScreen] setBrightness:value];
        // 修复监听new值还是old的情况；
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[UIScreen mainScreen] setBrightness:value];
        });
    }
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if(context == (__bridge void *)[AVAudioSession sharedInstance]){
        float newValue = [[change objectForKey:@"new"] floatValue];
        // TODO: 这里实现你的逻辑代码
        self.voiceSlider.value = newValue;
    }
}
@end
