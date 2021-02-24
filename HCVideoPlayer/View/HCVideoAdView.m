//
//  HCVideoAdView.m
//  HCVideoPlayer
//
//  Created by chc on 2019/5/24.
//  Copyright © 2019 chc. All rights reserved.
//

#import "HCVideoAdView.h"
#import "HCAirplayCastTool.h"
#import "HCVideoAdJumpView.h"
#import "HCPlayerView.h"
#import "HCVideoPlayerConst.h"

@interface HCVideoAdView ()<HCPlayerViewDelegate>
@property (nonatomic, strong) NSArray <HCPlayerView *> *playerViews;
@property (nonatomic, weak) UIView *controllView;
@property (nonatomic, weak) UIButton *backBtn;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UIButton *skipBtn;
@property (nonatomic, weak) UIButton *jumpBtn;
@property (nonatomic, weak) UIButton *speakerBtn;
@property (nonatomic, weak) UIButton *zoomBtn;
@property (nonatomic, assign) NSInteger playIndex;
@property (nonatomic, assign) NSTimeInterval adsTotalTime;
@property (nonatomic, assign) NSTimeInterval playTotalTime;

@property (nonatomic, assign) BOOL pauseStatus;

@property (nonatomic, assign) BOOL isBluetoothOutput;
@property (nonatomic, assign) CGFloat volumeRate;

@property (nonatomic, weak) UIView *bkView;
@property (nonatomic, strong) HCWeakTimer *timer;
@end

@implementation HCVideoAdView
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
        [backBtn setImage:[UIImage vp_imageWithName:@"vp_adBack"] forState:UIControlStateNormal];
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
        timeLabel.backgroundColor =kVP_Color(0, 0, 0, 0.5);
        timeLabel.font = kVP_Font(18);
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.clipsToBounds = YES;
        timeLabel.textAlignment = NSTextAlignmentCenter;
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
        [speakerBtn setImage:[UIImage vp_imageWithName:@"vp_adVoiceOn"] forState:UIControlStateNormal];
        [speakerBtn setImage:[UIImage vp_imageWithName:@"vp_adVoiceOff"] forState:UIControlStateSelected];
        speakerBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [speakerBtn addTarget:self action:@selector(didClickSpeakerBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speakerBtn;
}

- (UIButton *)zoomBtn
{
    if (_zoomBtn == nil) {
        UIButton *zoomBtn = [[UIButton alloc] init];
        [self.controllView addSubview:zoomBtn];
        _zoomBtn =  zoomBtn;
        [zoomBtn setImage:[UIImage vp_imageWithName:@"vp_adZoom"] forState:UIControlStateNormal];
        [zoomBtn addTarget:self action:@selector(didClickZoomBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _zoomBtn;
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
                weakPlayerView.volume = ((CGFloat)(!weakSelf.speakerBtn.selected)) * weakSelf.volumeRate;
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
        if ([self.delegate respondsToSelector:@selector(didAdsPlayCompleteForVideoAdView:)]) {
            [self.delegate didAdsPlayCompleteForVideoAdView:self];
        }
    }
}

- (void)play
{
    _pauseStatus = NO;
    HCPlayerView *curPlayerView = _playerViews[_playIndex];
    curPlayerView.volume = ((CGFloat)(!self.speakerBtn.selected)) * self.volumeRate;
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
    curPlayerView.volume = ((CGFloat)(!self.speakerBtn.selected)) * self.volumeRate;
    [curPlayerView stop];
}

- (void)setShowZoom:(BOOL)showZoom
{
    _showZoom = showZoom;
    self.zoomBtn.hidden = !_showZoom;
    [self setupFrame];
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self bkView];
        [self setupNotification];
        _timer = [HCWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timeEvent) userInfo:nil repeats:YES];
        self.showZoom = YES;
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
            if ([self.delegate respondsToSelector:@selector(didAdsPlayCompleteForVideoAdView:)]) {
                [self.delegate didAdsPlayCompleteForVideoAdView:self];
            }
            return;
        }
        
        playerView = _playerViews[_playIndex];
        playerView.volume = ((CGFloat)(!self.speakerBtn.selected)) * self.volumeRate;
        playerView.delegate = self;
        [playerView play];
        [self.controllView addSubview:playerView];
        [self.controllView sendSubviewToBack:playerView];
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
        if ([self.delegate respondsToSelector:@selector(didAdsPlayCompleteForVideoAdView:)]) {
            [self.delegate didAdsPlayCompleteForVideoAdView:self];
        }
        return;
    }
    
    playerView = _playerViews[_playIndex];
    playerView.volume = ((CGFloat)(!self.speakerBtn.selected)) * self.volumeRate;
    playerView.delegate = self;
    [playerView play];
    [self.controllView addSubview:playerView];
    [self.controllView sendSubviewToBack:playerView];
}

- (void)didLoadErrorForPlayerView:(HCPlayerView *)playerView
{
    
}

- (void)didPlayErrorForPlayerView:(HCPlayerView *)playerView
{
    if ([self.delegate respondsToSelector:@selector(didAdsPlayCompleteForVideoAdView:)]) {
        [self.delegate didAdsPlayCompleteForVideoAdView:self];
    }
}

#pragma mark - 事件
- (void)didClickBackBtn
{
    if ([self.delegate respondsToSelector:@selector(didClickBackBtnForVideoAdView:)]) {
        [self.delegate didClickBackBtnForVideoAdView:self];
    }
}

- (void)didClickSkipBtn
{
    if ([self.delegate respondsToSelector:@selector(didClickSkipBtnForVideoAdView:)]) {
        [self.delegate didClickSkipBtnForVideoAdView:self];
    }
}

- (void)didClickJumpBtn
{
    HCVideoAdItem *adItem = nil;
    if (_playIndex < self.adsItem.ads.count) {
        adItem = self.adsItem.ads[_playIndex];
    }
    
    if ([self.delegate respondsToSelector:@selector(videoAdView:didClickAdItem:)]) {
        
        [self.delegate videoAdView:self didClickAdItem:adItem];
    }
}

- (void)didClickSpeakerBtn
{
    self.speakerBtn.selected = !self.speakerBtn.selected;
    
    if (_playIndex < _playerViews.count) {
        HCPlayerView *playerView = _playerViews[_playIndex];
        playerView.volume = ((CGFloat)(!self.speakerBtn.selected)) * self.volumeRate;
    }
}

- (void)didClickZoomBtn
{
    if ([self.delegate respondsToSelector:@selector(didClickZoomBtnForVideoAdView:)]) {
        [self.delegate didClickZoomBtnForVideoAdView:self];
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
            playerView.volume = ((CGFloat)(!self.speakerBtn.selected)) * self.volumeRate;
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
    [self play];
}

#pragma mark - 内部方法
- (void)setupFrame
{
    for (HCPlayerView *playerView in _playerViews) {
        playerView.frame = self.bounds;
    }
    
    self.controllView.frame = self.bounds;
    
    self.backBtn.vp_x = 20;
    self.backBtn.vp_y = 20;
    self.backBtn.vp_height = 44;
    self.backBtn.vp_width = 44;
    
    self.zoomBtn.vp_width = 44;
    self.zoomBtn.vp_height = 44;
    self.zoomBtn.vp_x = self.controllView.vp_width - self.zoomBtn.vp_width - 20;
    self.zoomBtn.vp_y = self.controllView.vp_height - self.zoomBtn.vp_height - 20;
    
    self.speakerBtn.vp_width = 44;
    self.speakerBtn.vp_height = 44;
    self.speakerBtn.vp_x = CGRectGetMinX(self.zoomBtn.frame) - self.speakerBtn.vp_width - 15;
    if (_showZoom == NO) {
        self.speakerBtn.vp_x = self.controllView.vp_width - self.speakerBtn.vp_width - 20;
    }
    self.speakerBtn.vp_y = self.controllView.vp_height - self.speakerBtn.vp_height - 20;
    
    self.jumpBtn.vp_y = self.speakerBtn.vp_y;
    self.jumpBtn.vp_height = 44;
    self.jumpBtn.vp_width = 136;
    self.jumpBtn.vp_x = CGRectGetMinX(self.speakerBtn.frame) - 10 - self.jumpBtn.vp_width;
    _jumpBtn.layer.cornerRadius = self.jumpBtn.vp_height * 0.5;
    CGFloat minW = MIN(kVP_ScreenWidth, kVP_ScreenHeight);
    _jumpBtn.hidden = YES;
    if (self.vp_width > minW) {
        _jumpBtn.hidden = NO;
    }
    
//    self.skipBtn.vp_width = 104;
//    self.skipBtn.vp_height = 44;
//    self.skipBtn.vp_x = self.controllView.vp_width - self.skipBtn.vp_width - 20;
//    self.skipBtn.vp_y = 20;
//    self.skipBtn.layer.cornerRadius = self.skipBtn.vp_height * 0.5;
    
    self.timeLabel.vp_width = 44;
    self.timeLabel.vp_height = 44;
    self.timeLabel.vp_y = 20;
    
//    if (_skipBtn.hidden) {
        self.timeLabel.vp_x = self.controllView.vp_width - 20 - self.timeLabel.vp_width;
//    }
//    else
//    {
//        self.timeLabel.vp_x = CGRectGetMinX(self.skipBtn.frame) - 10 - self.timeLabel.vp_width;
//    }
    self.timeLabel.layer.cornerRadius = self.timeLabel.vp_height * 0.5;
    
    self.bkView.vp_width = self.controllView.vp_width * 2;
    self.bkView.vp_height = self.controllView.vp_height * 2;
    self.bkView.vp_x = (self.controllView.vp_width - self.bkView.vp_width) * 0.5;
    self.bkView.vp_y = (self.controllView.vp_height - self.bkView.vp_height) * 0.5;
    
    for (UIView *view in self.controllView.subviews) {
        view.hidden = self.vp_width < MIN(kVP_ScreenWidth, kVP_ScreenHeight) && ![view isKindOfClass:[HCPlayerView class]];
    }
}
@end
