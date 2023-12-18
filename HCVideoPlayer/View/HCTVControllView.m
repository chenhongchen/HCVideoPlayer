//
//  HCTVControllView.m
//  HCVideoPlayer
//
//  Created by chc on 2018/1/6.
//  Copyright © 2018年 chc. All rights reserved.
//
#define BLUECOLOR [UIColor colorWithRed:31.0/255 green:147.0/255 blue:234.0/255 alpha:1.0]
#define RedCOLOR [UIColor colorWithRed:226/255.0 green:42/255.0 blue:30/255.0 alpha:1.0]

#import "HCTVControllView.h"
#import "HCProgressView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HCVideoPlayerConst.h"

@interface HCTVControllView ()<HCProgressViewDelegate>
@property (nonatomic, strong) CLUPnPRenderer *render; // dlnaamsung

@property (nonatomic, weak) UIButton *backBtn;
@property (nonatomic, weak) UIImageView *topTvImageView;
@property (nonatomic, weak) UILabel *projectingLabel;
@property (nonatomic, weak) UIView *controllCenterBar;
@property (nonatomic, weak) UIButton *exitBtn;
@property (nonatomic, weak) UIButton *pauseBtn;
@property (nonatomic, weak) UIButton *changeDevBtn;

/// AirPlay按钮，添加在exitBtn上
@property (nonatomic, weak) MPVolumeView *exitVolume;
/// AirPlay按钮，添加在changeDevBtn上
@property (nonatomic, weak) MPVolumeView *changeDevVolume;

// 底部
@property (nonatomic, weak) UIButton *playerBtn;
@property (nonatomic, weak) HCProgressView *progressView;
@property (nonatomic, weak) UILabel *timeLabel;
@property (nonatomic, weak) UIView *bottomBar;

// 保存滑动时progressView的滑动开始点的进度
@property (nonatomic, assign) CGFloat panStartProgress;
@property (nonatomic, assign) BOOL isPan;
// 用于判断seek时是否已获取到播放进度信息 经测试大于2能获取到
@property (nonatomic, assign) NSInteger responeTimesAfterPan;
// 是否初始已获取到播放进度信息
@property (nonatomic, assign) BOOL startGetPositionInfo;

@property (nonatomic, strong) HCWeakTimer *timer;
@property (nonatomic, weak) UIView *bkView;
@end

@implementation HCTVControllView

#pragma mark - 懒加载
- (UIButton *)backBtn
{
    if (_backBtn == nil) {
        UIButton *backBtn = [[UIButton alloc] init];
        [self addSubview:backBtn];
        _backBtn = backBtn;
        [backBtn setImage:[UIImage vp_imageWithName:@"vp_back"] forState:UIControlStateNormal];
        [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIImageView *)topTvImageView
{
    if (_topTvImageView == nil) {
        UIImageView *topTvImageView = [[UIImageView alloc] initWithImage:[UIImage vp_imageWithName:@"vp_tv_topTv"]];
        [self addSubview:topTvImageView];
        _topTvImageView = topTvImageView;
    }
    return _topTvImageView;
}

- (UILabel *)projectingLabel
{
    if (_projectingLabel == nil) {
        UILabel *projectingLabel = [[UILabel alloc] init];
        [self addSubview:projectingLabel];
        _projectingLabel = projectingLabel;
        projectingLabel.font = [UIFont systemFontOfSize:14];
        projectingLabel.textColor = [UIColor whiteColor];
        projectingLabel.textAlignment = NSTextAlignmentCenter;
        projectingLabel.text = @"正在投屏中";
        projectingLabel.textColor = kVP_Color(153, 153, 153, 1.0);
        [projectingLabel sizeToFit];
    }
    return _projectingLabel;
}

- (UIView *)controllCenterBar
{
    if (_controllCenterBar == nil) {
        UIView *controllCenterBar = [[UIView alloc] init];
        [self addSubview:controllCenterBar];
        _controllCenterBar = controllCenterBar;
        controllCenterBar.backgroundColor = [UIColor clearColor];
        controllCenterBar.clipsToBounds = YES;
    }
    return _controllCenterBar;
}

- (UIButton *)exitBtn
{
    if (_exitBtn == nil) {
        UIButton *exitBtn = [[UIButton alloc] init];
        [self.controllCenterBar addSubview:exitBtn];
        _exitBtn = exitBtn;
        [exitBtn setTitle:@"退出投屏" forState:UIControlStateNormal];
        [exitBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        exitBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [exitBtn setBackgroundColor:kVP_ThemeColor];
        [exitBtn addTarget:self action:@selector(exitBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitBtn;
}

- (UIButton *)pauseBtn
{
    if (_pauseBtn == nil) {
        UIButton *pauseBtn = [[UIButton alloc] init];
        [self.controllCenterBar addSubview:pauseBtn];
        _pauseBtn = pauseBtn;
        [pauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
        [pauseBtn setTitle:@"播放" forState:UIControlStateSelected];
        [pauseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        pauseBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [pauseBtn setBackgroundColor:kVP_ThemeColor];
        [pauseBtn addTarget:self action:@selector(pauseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pauseBtn;
}

- (UIButton *)changeDevBtn
{
    if (_changeDevBtn == nil) {
        UIButton *changeDevBtn = [[UIButton alloc] init];
        [self.controllCenterBar addSubview:changeDevBtn];
        _changeDevBtn = changeDevBtn;
        [changeDevBtn setTitle:@"更换设备" forState:UIControlStateNormal];
        [changeDevBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        changeDevBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        [changeDevBtn setBackgroundColor:kVP_ThemeColor];
        [changeDevBtn addTarget:self action:@selector(changeDevBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _changeDevBtn;
}

- (MPVolumeView *)exitVolume
{
    if (_exitVolume == nil) {
        MPVolumeView *volume = [[MPVolumeView alloc] init];
        volume.showsVolumeSlider = NO;
        UIImage *airPlayImage = [UIImage vp_imageWithName:@""];
        [volume setRouteButtonImage:airPlayImage forState:UIControlStateNormal];
        [self.exitBtn addSubview:volume];
        _exitVolume = volume;
    }
    return _exitVolume;
}

- (MPVolumeView *)changeDevVolume
{
    if (_changeDevVolume == nil) {
        MPVolumeView *volume = [[MPVolumeView alloc] init];
        volume.showsVolumeSlider = NO;
        UIImage *airPlayImage = [UIImage vp_imageWithName:@""];
        [volume setRouteButtonImage:airPlayImage forState:UIControlStateNormal];
        [self.changeDevBtn addSubview:volume];
        _changeDevVolume = volume;
    }
    return _changeDevVolume;
}

- (UIButton *)playerBtn
{
    if (_playerBtn == nil) {
        UIButton *playerBtn = [[UIButton alloc] init];
        [self.bottomBar addSubview:playerBtn];
        _playerBtn = playerBtn;
        [playerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [playerBtn setImage:[UIImage vp_imageWithName:@"vp_pause"] forState:UIControlStateNormal];
        [playerBtn setImage:[UIImage vp_imageWithName:@"vp_play"] forState:UIControlStateSelected];
        [playerBtn addTarget:self action:@selector(playerBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playerBtn;
}

- (HCProgressView *)progressView
{
    if (_progressView == nil) {
        HCProgressView *progressView = [[HCProgressView alloc] init];
        [self.bottomBar addSubview:progressView];
        _progressView = progressView;
        progressView.progressHeight = 1.0;
        progressView.delegate = self;
    }
    return _progressView;
}

- (UILabel *)timeLabel
{
    if (_timeLabel == nil) {
        UILabel *timeLabel = [[UILabel alloc] init];
        [self.bottomBar addSubview:timeLabel];
        _timeLabel = timeLabel;
        timeLabel.font = [UIFont systemFontOfSize:10];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.text = @"00:00 / 00:00";
    }
    return _timeLabel;
}

- (UIView *)bottomBar
{
    if (_bottomBar == nil) {
        UIView *bottomBar = [[UIView alloc] init];
        [self addSubview:bottomBar];
        _bottomBar = bottomBar;
        bottomBar.backgroundColor = kVP_Color(0, 0, 0, 0.3);
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(bottomBarPan:)];
        [bottomBar addGestureRecognizer:pan];
    }
    return _bottomBar;
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
- (void)setDeviceItem:(HCTVDeviceItem *)deviceItem
{
    HCTVDeviceItem *lastDevItem = _deviceItem;
    _deviceItem = deviceItem;
    
    if (_style == HCTVControllViewStyleDlna) {
        
        CLUPnPRenderer *lastRender = [[CLUPnPRenderer alloc] initWithModel:lastDevItem.dlnaDev];
        [lastRender stop]; // 播放新的前，先停止该设备的播放；
        
        self.progressView.playProgress = 0;
        _startGetPositionInfo = NO;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            _render = [[CLUPnPRenderer alloc] initWithModel:_deviceItem.dlnaDev];
            [_render setAVTransportURL:_deviceItem.videoUrl];
            _render.delegate = self;
        });
    }
}

- (void)setStyle:(HCTVControllViewStyle)style
{
    _style = style;
    
    self.exitBtn.hidden = NO;
    self.pauseBtn.hidden = NO;
    self.changeDevBtn.hidden = NO;
    self.bottomBar.hidden = NO;
    self.exitVolume.hidden = YES;
    self.changeDevVolume.hidden = YES;
    if (_style == HCTVControllViewStyleDlna) {
        [self startTimeEvent];
    }
    else if (_style == HCTVControllViewStyleAirPlay) {
        self.exitVolume.hidden = NO;
        self.changeDevVolume.hidden = NO;
        [self startTimeEvent];
    }
    else if (_style == HCTVControllViewStyleGoogleCast) {
        self.exitBtn.hidden = YES;
        self.pauseBtn.hidden = YES;
        self.changeDevBtn.hidden = YES;
        self.bottomBar.hidden = YES;
    }
}

- (void)setTotalTime:(NSTimeInterval)totalTime
{
    _totalTime = totalTime;
    self.progressView.totalTime = _totalTime;
}

- (void)setPlayTime:(NSTimeInterval)playTime
{
    _playTime = playTime;
    
    if (fabs(_playTime - self.progressView.playTime) <= 10 || self.progressView.playTime == 0) {
        self.progressView.playTime = _playTime;
        self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", [NSString vp_formateStringFromSec:_playTime], [NSString vp_formateStringFromSec:_totalTime]];
        [self setupTimeLabelFrame];
    }
}

- (void)setLoadTime:(NSTimeInterval)loadTime
{
    _loadTime = loadTime;
    self.progressView.loadTime = _loadTime;
}

- (void)setupProgressZero
{
    self.totalTime = 0;
    _playTime = 0;
    self.loadTime = 0;
    self.progressView.playTime = 0;
    self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", [NSString vp_formateStringFromSec:_playTime], [NSString vp_formateStringFromSec:_totalTime]];
    [self setupTimeLabelFrame];
}

#pragma mark - 事件
- (void)exitBtnClicked:(UIButton *)btn
{
    [self stopAll];
    if ([self.delegate respondsToSelector:@selector(tvControllView:didClickExitBtnAtPlayTime:)]) {
        [self.delegate tvControllView:self didClickExitBtnAtPlayTime:self.progressView.playTime];
    }
    self.hidden = YES;
}

- (void)pauseBtnClicked:(UIButton *)btn
{
    btn.selected = !btn.isSelected;
    self.playerBtn.selected = btn.selected;
    if (btn.isSelected) {
        [self pause];
    }
    else {
        [self play];
    }
}

- (void)changeDevBtnClicked:(UIButton *)btn
{
    if ([self.delegate respondsToSelector:@selector(tvControllView:didClickChangeDevBtnAtPlayTime:)]) {
        [self.delegate tvControllView:self didClickChangeDevBtnAtPlayTime:self.progressView.playTime];
    }
}

- (void)timeEvent {
    if (_style == HCTVControllViewStyleDlna) {
        [self.render getPositionInfo];
    }
    else if (_style == HCTVControllViewStyleAirPlay)
    {
        self.progressView.playTime = self.videoPlayer.urlPlayer.currentTime;
        self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", [NSString vp_formateStringFromSec:self.progressView.playTime], [NSString vp_formateStringFromSec:_totalTime]];
        [self setupTimeLabelFrame];
    }
    VPLog(@"timeEvent - HCTVControllView");
}

- (void)playerBtnClicked:(UIButton *)playerBtn {
    playerBtn.selected = !playerBtn.selected;
    self.pauseBtn.selected = playerBtn.selected;
    if(playerBtn.selected) {
        [self.render pause];
    } else {
        [self.render play];
    }
}

- (void)bottomBarPan:(UIPanGestureRecognizer *)recognizer
{
    CGPoint point =  [recognizer translationInView:self.progressView];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat x = self.panStartProgress * self.progressView.bounds.size.width;
        self.progressView.playProgress = (point.x + x) / self.progressView.bounds.size.width;
        [self progressView:self.progressView didChangedSliderValue:self.progressView.playProgress time:(self.progressView.playProgress * self.progressView.totalTime)];
        self.isPan = NO;
    }
    else {
        if (!self.isPan) {
            self.panStartProgress = self.progressView.playProgress;
        }
        self.isPan = YES;
        CGFloat x = self.panStartProgress * self.progressView.bounds.size.width;
        self.progressView.playProgress = (point.x + x) / self.progressView.bounds.size.width;
    }
}

- (void)backBtnClicked
{
    if ([self.delegate respondsToSelector:@selector(didClickBackBtnForTvControllView:)]) {
        [self.delegate didClickBackBtnForTvControllView:self];
    }
}

- (void)selfClicked
{
    [UIApplication sharedApplication].statusBarHidden = ![UIApplication sharedApplication].statusBarHidden;
}

- (void)selfPan
{
    
}

#pragma mark - 通知
- (void)videoPlayerWillZoomOut:(NSNotification *)notif
{
    NSValue *value = notif.userInfo[@"toFrame"];
    [self setupSubViewsFrameWithSelfFrame:value.CGRectValue];
}

#pragma mark - HCProgressViewDelegate
- (void)progressView:(HCProgressView *)progressView didChangedSliderValue:(double)sliderValue time:(NSTimeInterval)time
{
    [self seekTime:time];
    if (!self.isPan) {
        self.panStartProgress = progressView.playProgress;
    }
    else
    {
        _responeTimesAfterPan = 0;
    }
}

- (void)progressView:(HCProgressView *)progressView didSliderUpAtValue:(CGFloat)value time:(CGFloat)time
{
    [self seekTime:time];
    _responeTimesAfterPan = 0;
}

#pragma mark - CLUPnPResponseDelegate
// 设置url响应
- (void)upnpSetAVTransportURIResponse;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

// 获取播放状态
- (void)upnpGetTransportInfoResponse:(CLUPnPTransportInfo *)info;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

// 获取播放进度
- (void)upnpGetPositionInfoResponse:(CLUPnPAVPositionInfo *)info{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        VPLog(@"SESESE)()()(%f, === %f === %f == %ld", info.trackDuration, info.absTime, info.relTime, info.track);
        
        if (_deviceItem.seekTime > 0 && info.relTime > 1) { // TV 同步 手机进度
            [self.render seek:_deviceItem.seekTime];
            _deviceItem.seekTime = -1;
            return;
        }
        if (info.relTime > 0) {
            _startGetPositionInfo = YES; // 用于判断是否已获取到播放进度信息
        }
        if (_isPan || _responeTimesAfterPan < 2) { // 小于2不执行，防止进度条跳动
            _responeTimesAfterPan ++;
            return;
        }
        
//        if (info.track == 0 && info.relTime == 1.0) { // track为0 表示停止或暂停播放，这时relTime为1.0表示播放完成；
//            self.progressView.playProgress = 1;
//            [self exitBtnClicked:self.exitBtn];
//            VPLog(@"track == 0");
//            return;
//        }
        if (info.trackDuration <= 0) {
            return;
        }
        self.progressView.totalTime = info.trackDuration;
        self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", [NSString vp_formateStringFromSec:info.relTime], [NSString vp_formateStringFromSec:info.trackDuration]];
        [self setupTimeLabelFrame];
        self.progressView.playProgress = info.relTime / info.trackDuration;
    });
}

#pragma mark - VideoPlayerDelegate
- (void)onCurrentPlayTime:(NSInteger)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.progressView.totalTime <= 0) {
            return;
        }
        
        self.progressView.playTime = progress;
        self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", [NSString vp_formateStringFromSec:progress], [NSString vp_formateStringFromSec:self.progressView.totalTime]];
        [self setupTimeLabelFrame];
    });
}

- (void)onStreamingStarted:(NSInteger)duration
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.totalTime = duration;
    });
}

- (void)onStreamCompleted
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self bkView];
        self.backgroundColor = [UIColor blackColor];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoPlayerWillZoomOut:) name:NotificationVideoPlayerWillZoomOut object:nil];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfClicked)];
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selfClicked)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(selfPan)];
        [self addGestureRecognizer:pan];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopAll];
    VPLog(@"dealloc - HCTVControllView");
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self setupSubViewsFrameWithSelfFrame:self.frame];
}

- (void)setupSubViewsFrameWithSelfFrame:(CGRect)selfFrame
{
    CGFloat selfW = selfFrame.size.width;
    CGFloat selfH = selfFrame.size.height;
    
    CGFloat x = (selfW - self.topTvImageView.bounds.size.width) * 0.5;
    CGFloat y = 0;
    CGFloat width = self.topTvImageView.bounds.size.width;
    CGFloat height = self.topTvImageView.bounds.size.height;
    self.topTvImageView.frame = CGRectMake(x, y, width, height);
    
    width = selfW;
    height = self.projectingLabel.bounds.size.height;
    x = 0;
    y = CGRectGetMaxY(self.topTvImageView.frame) + 33 * (selfW / 375);
    self.projectingLabel.frame = CGRectMake(x, y, width, height);
    
    width = 72;
    height = 28;
    y = 0;
    x = 0;
    self.exitBtn.frame = CGRectMake(x, y, width, height);
    self.exitVolume.frame = self.exitBtn.bounds;
    
    x = CGRectGetMaxX(self.exitBtn.frame) + 1;
    self.pauseBtn.frame = CGRectMake(x, y, width, height);
    
    x = CGRectGetMaxX(self.pauseBtn.frame) + 1;
    self.changeDevBtn.frame = CGRectMake(x, y, width, height);
    self.changeDevVolume.frame = self.changeDevBtn.bounds;
    
    width = CGRectGetMaxX(self.changeDevBtn.frame);
    x = (selfW - width) * 0.5;
    y = CGRectGetMaxY(self.projectingLabel.frame) + 16 * (selfW / 375);
    self.controllCenterBar.frame = CGRectMake(x, y, width, height);
    self.controllCenterBar.layer.cornerRadius = height * 0.5;
    
    width = selfW;
    height = 40;
    x = 0;
    y = selfH - height;
    self.bottomBar.frame = CGRectMake(x, y, width, height);
    
    width = 42;
    y = 0;
    self.playerBtn.frame = CGRectMake(x, y, width, height);
    
    x = CGRectGetMaxX(self.playerBtn.frame);
    y = 0;
    width = selfW - 12 - x;
    self.progressView.frame = CGRectMake(x, y, width, height);
    
    self.backBtn.frame = CGRectMake(0, 20, 50, 44);
    
    [self setupTimeLabelFrame];
    
    self.bkView.vp_width = self.vp_width * 2;
    self.bkView.vp_height = self.vp_height * 2;
    self.bkView.vp_x = (self.vp_width - self.bkView.vp_width) * 0.5;
    self.bkView.vp_y = (self.vp_height - self.bkView.vp_height) * 0.5;
}

#pragma mark - 内部方法
- (void)stopAll
{
    [self.timer stop];
    self.timer = nil;
    
    [self removeAllDelegate];
    
    [_render stop];
    self.render = nil;
}

- (void)setupTimeLabelFrame
{
    CGSize size = [self.timeLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGFloat x = CGRectGetMaxX(self.progressView.frame) - size.width;
    CGFloat y = self.bottomBar.frame.size.height * 0.75 - size.height * 0.5;
    CGFloat width = size.width;
    CGFloat height = size.height;
    self.timeLabel.frame = CGRectMake(x, y, width, height);
}

- (void)startTimeEvent
{
    [_timer stop];
    _timer = [HCWeakTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timeEvent) userInfo:nil repeats:YES];
}

- (void)play
{
    if (_style == HCTVControllViewStyleDlna) {
        [_render play];
    }
    else if (_style == HCTVControllViewStyleAirPlay) {
        [self.videoPlayer play];
    }
}

- (void)pause
{
    if (_style == HCTVControllViewStyleDlna) {
        [_render pause];
    }
    else if (_style == HCTVControllViewStyleAirPlay) {
        [self.videoPlayer pause];
    }
}

- (void)seekTime:(NSTimeInterval)time
{
    if (_style == HCTVControllViewStyleDlna) {
        [_render seek:time];
    }
    else if (_style == HCTVControllViewStyleAirPlay) { // AirPlay投屏
        if (self.videoPlayer.url)
            [self.videoPlayer seekToTime:time autoPlay:NO];
    }
}

- (void)removeAllDelegate
{
    _render.delegate = nil;
}
@end
