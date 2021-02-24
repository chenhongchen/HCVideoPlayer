//
//  HCVideoAdView.m
//  HCVideoPlayer
//
//  Created by chc on 2019/5/24.
//  Copyright © 2019 chc. All rights reserved.
//

#import "HCSvVideoAdView.h"
#import "HCAirplayCastTool.h"
#import "HCVideoAdJumpView.h"
#import "HCPlayerView.h"
#import "HCVideoPlayerConst.h"

@interface HCSvVideoAdView ()<HCPlayerViewDelegate, HCVideoAdJumpViewDelegate>
@property (nonatomic, strong) NSArray <HCPlayerView *> *playerViews;
@property (nonatomic, weak) UIView *controllView;
@property (nonatomic, weak) UIButton *backBtn;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UIButton *skipBtn;
@property (nonatomic, weak) UIButton *jumpBtn;
@property (nonatomic, weak) UIButton *speakerBtn;

@property (nonatomic, weak) HCVideoAdJumpView *adJumpView;
@property (nonatomic, weak) UILabel *adLabel;

@property (nonatomic, assign) NSInteger playIndex;
@property (nonatomic, assign) NSTimeInterval adsTotalTime;
@property (nonatomic, assign) NSTimeInterval playTotalTime;

@property (nonatomic, assign) BOOL pauseStatus;

@property (nonatomic, assign) BOOL isBluetoothOutput;
@property (nonatomic, assign) CGFloat volumeRate;

@property (nonatomic, weak) UIView *bkView;
@property (nonatomic, strong) HCWeakTimer *timer;
@end

@implementation HCSvVideoAdView
#pragma mark - 懒加载
- (UIView *)controllView
{
    if (_controllView == nil) {
        UIView *controllView = [[UIView alloc] init];
        [self addSubview:controllView];
        _controllView = controllView;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickJumpBtn)];
        [controllView addGestureRecognizer:tap];
    }
    return _controllView;
}

- (UIButton *)backBtn
{
    if (_backBtn == nil) {
        UIButton *backBtn = [[UIButton alloc] init];
        [self.controllView addSubview:backBtn];
        _backBtn = backBtn;
        [backBtn setImage:[UIImage vp_imageWithName:@"vp_ad_back"] forState:UIControlStateNormal];
        backBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [backBtn addTarget:self action:@selector(didClickBackBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        UILabel *timeLabel = [[UILabel alloc] init];
        [self.controllView addSubview:timeLabel];
        _timeLabel = timeLabel;
        timeLabel.backgroundColor = kVP_Color(0, 0, 0, 0.5);
        timeLabel.font = kVP_Font(18);
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.clipsToBounds = YES;
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.hidden = YES;
    }
    return _timeLabel;
}

- (UIButton *)skipBtn
{
    if (_skipBtn == nil) {
        UIButton *skipBtn = [[UIButton alloc] init];
        [self.controllView addSubview:skipBtn];
        _skipBtn = skipBtn;
        skipBtn.backgroundColor = kVP_Color(0, 0, 0, 0.5);
        skipBtn.titleLabel.font = kVP_Font(16);
        [skipBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        skipBtn.clipsToBounds = YES;
        [skipBtn setTitle:@"跳过广告" forState:UIControlStateNormal];
        [skipBtn addTarget:self action:@selector(didClickSkipBtn) forControlEvents:UIControlEventTouchUpInside];
        skipBtn.hidden = YES;
    }
    return _skipBtn;
}

- (UIButton *)jumpBtn
{
    if (_jumpBtn == nil) {
        UIButton *jumpBtn = [[UIButton alloc] init];
        [self.controllView addSubview:jumpBtn];
        _jumpBtn = jumpBtn;
        jumpBtn.backgroundColor = kVP_ColorWithHexValueA(0x1F93EA, 0.9);
        jumpBtn.titleLabel.font = kVP_Font(16);
        [jumpBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        jumpBtn.clipsToBounds = YES;
        [jumpBtn setTitle:@"点击查看详情" forState:UIControlStateNormal];
        [jumpBtn addTarget:self action:@selector(didClickJumpBtn) forControlEvents:UIControlEventTouchUpInside];
        jumpBtn.hidden = YES;
    }
    return _jumpBtn;
}

- (UIButton *)speakerBtn
{
    if (_speakerBtn == nil) {
        UIButton *speakerBtn = [[UIButton alloc] init];
        [self.controllView addSubview:speakerBtn];
        _speakerBtn = speakerBtn;
        [speakerBtn setImage:[UIImage vp_imageWithName:@"vp_ad_voiceOn"] forState:UIControlStateNormal];
        [speakerBtn setImage:[UIImage vp_imageWithName:@"vp_ad_voiceOff"] forState:UIControlStateSelected];
        speakerBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [speakerBtn addTarget:self action:@selector(didClickSpeakerBtn) forControlEvents:UIControlEventTouchUpInside];
        speakerBtn.hidden = YES;
    }
    return _speakerBtn;
}

- (HCVideoAdJumpView *)adJumpView
{
    if (_adJumpView == nil) {
        HCVideoAdJumpView *adJumpView = [[HCVideoAdJumpView alloc] init];
        [self.controllView addSubview:adJumpView];
        _adJumpView = adJumpView;
        adJumpView.delegate = self;
    }
    return _adJumpView;
}

- (UILabel *)adLabel
{
    if (_adLabel == nil) {
        UILabel *adLabel = [[UILabel alloc] init];
        [self.controllView addSubview:adLabel];
        _adLabel = adLabel;
        adLabel.font = kVP_Font(12);
        adLabel.textColor = [UIColor whiteColor];
        adLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        adLabel.layer.cornerRadius = 4;
        adLabel.clipsToBounds = YES;
        adLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _adLabel;
}

- (UIView *)bkView
{
    if (_bkView == nil) {
        UIView *bkView = [[UIView alloc] init];
        [self addSubview:bkView];
        _bkView = bkView;
        bkView.backgroundColor = [UIColor blackColor];
    }
    return _bkView;
}

#pragma mark - 外部方法
- (void)setAdsItem:(HCVideoAdsItem *)adsItem
{
    _adsItem = adsItem;
    
    if (!_adsItem.ads.count) {
        self.hidden = YES;
        return;
    }
    _adsTotalTime = 0;
    _playTotalTime = 0;
    _playIndex = 0;
    
    self.adJumpView.canJump = _adsItem.canJump;
    
    self.adLabel.text = _adsItem.ads[_playIndex].title;
    [self setupFrame];
    
    __weak typeof(self) weakSelf = self;
    NSMutableArray *playerViewsM = [NSMutableArray array];
    for (int i = 0; i < _adsItem.ads.count; i ++) {
        
        HCVideoAdItem *adItem = _adsItem.ads[i];
        if (![adItem.adstype isEqualToString:@"video"]) { // 如果不是视频类型则去掉该广告
            continue;
        }
        
        // 计算总时间
        _adsTotalTime += adItem.seconds.floatValue;
        
        // 生成播放器
        HCPlayerView *playerView = [[HCPlayerView alloc] init];
        playerView.isAllowUseP2p = NO;
        [playerViewsM addObject:playerView];
        
        // 播放或准备播放
        __weak typeof(playerView) weakPlayerView = playerView;
        [playerView readyWithUrl:_adsItem.ads[i].videoUrl complete:^(HCPlayerViewState status) {
            if (weakSelf.playIndex == i) {
                weakPlayerView.volume = weakSelf.mute ? 0 : (((CGFloat)(!weakSelf.speakerBtn.selected)) * weakSelf.volumeRate);
                weakPlayerView.delegate = weakSelf;
                [weakPlayerView play];
                [weakSelf.controllView addSubview:weakPlayerView];
                [weakSelf.controllView sendSubviewToBack:weakPlayerView];
                
                if (weakSelf.pauseStatus) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [weakPlayerView pause];
                    });
                }
            }
            else
            {
                weakPlayerView.volume = 0;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [weakPlayerView seekToTime:0 autoPlay:NO];
                });
            }
        }];
    }
    _playerViews = playerViewsM;
    
    NSTimeInterval time = _adsTotalTime;
    if (_adsTotalTime < 0) {
        _adsTotalTime = 0;
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%0.0f", time];
    
    if (time <= 0) {
        self.hidden = YES;
        if ([self.delegate respondsToSelector:@selector(didAdsPlayCompleteForSvVideoAdView:)]) {
            [self.delegate didAdsPlayCompleteForSvVideoAdView:self];
        }
    }
}

- (void)play
{
    _pauseStatus = NO;
    HCPlayerView *curPlayerView = _playerViews[_playIndex];
    curPlayerView.volume = _mute ? 0 : (1.0 * self.volumeRate);
    [curPlayerView play];
}

- (void)pause
{
    _pauseStatus = YES;
    HCPlayerView *curPlayerView = _playerViews[_playIndex];
    curPlayerView.volume = 0;
    [curPlayerView pause];
}

- (void)stop
{
    _pauseStatus = NO;
    HCPlayerView *curPlayerView = _playerViews[_playIndex];
    curPlayerView.volume = _mute ? 0 : (1.0 * self.volumeRate);
    [curPlayerView stop];
}

- (void)setShowBack:(BOOL)showBack
{
    _showBack = showBack;
    self.backBtn.hidden = !_showBack;
}

- (void)setMute:(BOOL)mute
{
    _mute = mute;
    HCPlayerView *curPlayerView = _playerViews[_playIndex];
    curPlayerView.volume = _mute ? 0 : (1.0 * self.volumeRate);
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self bkView];
        [self setupNotification];
        _timer = [HCWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeEvent) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_timer stop];
    _timer = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupFrame];
}

- (void)setupNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputDeviceChanged:)name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - HCPlayerViewDelegate
- (void)didStartPlayForPlayerView:(HCPlayerView *)playerView
{
}

- (void)playerView:(HCPlayerView *)playerView vedioSize:(CGSize)vedioSize
{
    
}

- (void)playerView:(HCPlayerView *)playerView totalTime:(NSTimeInterval)totalTime
{
    
}

- (void)playerView:(HCPlayerView *)playerView loadTime:(NSTimeInterval)loadTime
{
    
}

- (void)playerView:(HCPlayerView *)playerView playTime:(NSTimeInterval)playTime
{
    if (playerView.playerState != HCPlayerViewStatePlay) {
        return;
    }
    
    NSTimeInterval time = _adsTotalTime - _playTotalTime - playTime;
    if (_adsTotalTime < 0) {
        _adsTotalTime = 0;
    }
    self.timeLabel.text = [NSString stringWithFormat:@"%0.0f", time];
    
    _adJumpView.sec = [NSString stringWithFormat:@"%0.0f", time];
    
    HCVideoAdItem *adItem = _adsItem.ads[_playIndex];
    if (playTime > adItem.seconds.floatValue) {
        _playTotalTime += _adsItem.ads[_playIndex].seconds.doubleValue;
        
        HCPlayerView *playerView = _playerViews[_playIndex];
        playerView.volume = 0;
        [playerView stop];
        playerView.delegate = nil;
        [playerView removeFromSuperview];
        
        _playIndex += 1;
        if (_playIndex >= _adsItem.ads.count) {
            if ([self.delegate respondsToSelector:@selector(didAdsPlayCompleteForSvVideoAdView:)]) {
                [self.delegate didAdsPlayCompleteForSvVideoAdView:self];
            }
            return;
        }
        
        playerView = _playerViews[_playIndex];
        playerView.volume = _mute ? 0 : (((CGFloat)(!self.speakerBtn.selected)) * self.volumeRate);
        playerView.delegate = self;
        [playerView play];
        [self.controllView addSubview:playerView];
        [self.controllView sendSubviewToBack:playerView];
        
        
        self.timeLabel.text = _adsItem.ads[_playIndex].title;
        [self setupFrame];
    }
}

- (void)didStopPlayForPlayerView:(HCPlayerView *)playerView
{
    
}

/** 播放完成不返回视频开头 */
- (void)didPlayCompleteForPlayerView:(HCPlayerView *)playerView
{
    _playTotalTime += _adsItem.ads[_playIndex].seconds.doubleValue;
    
    playerView.volume = 0;
    [playerView stop];
    playerView.delegate = nil;
    [playerView removeFromSuperview];
    
    _playIndex += 1;
    if (_playIndex >= _adsItem.ads.count) {
        if ([self.delegate respondsToSelector:@selector(didAdsPlayCompleteForSvVideoAdView:)]) {
            [self.delegate didAdsPlayCompleteForSvVideoAdView:self];
        }
        return;
    }
    
    playerView = _playerViews[_playIndex];
    playerView.volume = _mute ? 0 : (((CGFloat)(!self.speakerBtn.selected)) * self.volumeRate);
    playerView.delegate = self;
    [playerView play];
    [self.controllView addSubview:playerView];
    [self.controllView sendSubviewToBack:playerView];
    
    self.timeLabel.text = _adsItem.ads[_playIndex].title;
    [self setupFrame];
}

- (void)didLoadErrorForPlayerView:(HCPlayerView *)playerView
{
    
}

- (void)didPlayErrorForPlayerView:(HCPlayerView *)playerView
{
    if ([self.delegate respondsToSelector:@selector(didAdsPlayCompleteForSvVideoAdView:)]) {
        [self.delegate didAdsPlayCompleteForSvVideoAdView:self];
    }
}

#pragma mark - HCVideoAdJumpViewDelegate
- (void)didClickJumpBtnForAdJumpView:(HCVideoAdJumpView *)adJumpView
{
    if ([self.delegate respondsToSelector:@selector(didClickSkipBtnForSvVideoAdView:)]) {
        [self.delegate didClickSkipBtnForSvVideoAdView:self];
    }
}

#pragma mark - 事件
- (void)didClickBackBtn
{
    if ([self.delegate respondsToSelector:@selector(didClickBackBtnForSvVideoAdView:)]) {
        [self.delegate didClickBackBtnForSvVideoAdView:self];
    }
}

- (void)didClickSkipBtn
{
    if ([self.delegate respondsToSelector:@selector(didClickSkipBtnForSvVideoAdView:)]) {
        [self.delegate didClickSkipBtnForSvVideoAdView:self];
    }
}

- (void)didClickJumpBtn
{
    HCVideoAdItem *adItem = nil;
    if (_playIndex < self.adsItem.ads.count) {
        adItem = self.adsItem.ads[_playIndex];
    }
    
    if ([self.delegate respondsToSelector:@selector(svVideoAdView:didClickAdItem:)]) {
        
        [self.delegate svVideoAdView:self didClickAdItem:adItem];
    }
}

- (void)didClickSpeakerBtn
{
    self.speakerBtn.selected = !self.speakerBtn.selected;
    
    if (_playIndex < _playerViews.count) {
        HCPlayerView *playerView = _playerViews[_playIndex];
        playerView.volume = _mute ? 0 : (((CGFloat)(!self.speakerBtn.selected)) * self.volumeRate);
    }
}

#pragma mark - timer
- (void)timeEvent
{
    if (!self.pauseStatus) {
        HCPlayerView *curPlayerView = _playerViews[_playIndex];
        if (!curPlayerView.isCalling) {
            [curPlayerView play];
        }
    }
}

#pragma mark - 通知
- (void)outputDeviceChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_playIndex < _playerViews.count) {
            HCPlayerView *playerView = _playerViews[_playIndex];
            playerView.volume = _mute ? 0 : (((CGFloat)(!self.speakerBtn.selected)) * self.volumeRate);
        }
        
        if (_isBluetoothOutput && ![HCAirplayCastTool isBluetoothOutput]) {
            [self pause];
        }

        HCPlayerView *curPlayerView = _playerViews[_playIndex];
        if (!_isBluetoothOutput && [HCAirplayCastTool isBluetoothOutput] && !curPlayerView.isCalling) {
            [self play];
        }
        _isBluetoothOutput = [HCAirplayCastTool isBluetoothOutput];
    });
}

- (CGFloat)volumeRate
{
    CGFloat volumeRate = 1.0;
    //    if ([HCAirplayCastTool isBluetoothOutput]) {
    //        volumeRate = 0.25;
    //    }
    return volumeRate;
}

- (void)applicationWillResignActive
{
    [self pause];
}

- (void)applicationDidBecomeActive
{
    if (_isManualStopOrPausePlay) {
        return;
    }
    if (_whenAppActiveNotToPlay) {
        return;
    }
    [self play];
}

#pragma mark - 内部方法
- (void)setupFrame
{
    for (HCPlayerView *playerView in _playerViews) {
        playerView.frame = self.bounds;
    }
    
    self.controllView.frame = self.bounds;
    
    self.adJumpView.vp_x = 15;
    self.adJumpView.vp_y = self.controllView.vp_height - self.adJumpView.vp_height - 15;
    
    [self.adLabel sizeToFit];
    self.adLabel.vp_width = self.adLabel.vp_width + 30;
    self.adLabel.vp_height = 38;
    self.adLabel.vp_x = self.controllView.vp_width - 15 - self.adLabel.vp_width;
    self.adLabel.vp_y = self.controllView.vp_height - self.adJumpView.vp_height - 15;
    
    self.backBtn.vp_x = 20;
    self.backBtn.vp_y = 20;
    self.backBtn.vp_height = 44;
    self.backBtn.vp_width = 44;
    
    self.speakerBtn.vp_width = 44;
    self.speakerBtn.vp_height = 44;
    self.speakerBtn.vp_x = self.controllView.vp_width - self.speakerBtn.vp_width - 20;
    self.speakerBtn.vp_y = self.controllView.vp_height - self.speakerBtn.vp_height - 20;
    
    self.jumpBtn.vp_y = self.speakerBtn.vp_y;
    self.jumpBtn.vp_height = 44;
    self.jumpBtn.vp_width = 136;
    self.jumpBtn.vp_x = CGRectGetMinX(self.speakerBtn.frame) - 10 - self.jumpBtn.vp_width;
    _jumpBtn.layer.cornerRadius = self.jumpBtn.vp_height * 0.5;
    
    self.skipBtn.vp_width = 104;
    self.skipBtn.vp_height = 44;
    self.skipBtn.vp_x = self.controllView.vp_width - self.skipBtn.vp_width - 20;
    self.skipBtn.vp_y = 20;
    self.skipBtn.layer.cornerRadius = self.skipBtn.vp_height * 0.5;
    
    self.timeLabel.vp_width = 44;
    self.timeLabel.vp_height = 44;
    self.timeLabel.vp_y = 20;
    
    if (_skipBtn.hidden) {
        self.timeLabel.vp_x = self.controllView.vp_width - 20 - self.timeLabel.vp_width;
    }
    else
    {
        self.timeLabel.vp_x = CGRectGetMinX(self.skipBtn.frame) - 10 - self.timeLabel.vp_width;
    }
    self.timeLabel.layer.cornerRadius = self.timeLabel.vp_height * 0.5;
    
//    self.bkView.width = self.controllView.width * 2;
//    self.bkView.height = self.controllView.height * 2;
//    self.bkView.x = (self.controllView.width - self.bkView.width) * 0.5;
//    self.bkView.y = (self.controllView.height - self.bkView.height) * 0.5;
    self.bkView.frame = self.bounds;
}

@end
