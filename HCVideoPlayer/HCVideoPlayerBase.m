//
//  HCVideoPlayerBase.m
//  HCVideoPlayer
//
//  Created by chc on 2019/5/6.
//  Copyright © 2019 chc. All rights reserved.
//

#import "HCVideoPlayerBase.h"
#import "HCAirplayCastTool.h"
#import "HCVideoAdView.h"
#import "HCPicAdView.h"
#import "HCNavWebController.h"
#import "UIViewController+VP.h"
#import "HCSmallWindow.h"
#import "HCCornerAdView.h"
#import "AppDelegate+VP.h"

@interface HCCornerAdTimeRange : NSObject
@property (nonatomic, assign) NSTimeInterval startTime;
@property (nonatomic, assign) NSTimeInterval endTime;
@end

@implementation HCCornerAdTimeRange

@end

@interface HCVideoPlayerBase ()<HCVideoAdViewDelegate, HCNavWebControllerDelegate, HCPicAdViewDelegate, HCCornerAdViewDelegate>
@property (nonatomic, strong) HCPlayerView *urlPlayer; // url播放器
@property (nonatomic, weak) UIView *contentView;
// present方向根控制器
@property (nonatomic, weak) UIViewController *rootPresentVc;
@property (nonatomic, weak) HCVideoAdView *videoAdView;
@property (nonatomic, weak) HCPicAdView *picAdView;
@property (nonatomic, weak) HCCornerAdView *cornerAdView;
@property (nonatomic, strong) HCVideoAdItem *curOpenedAdItem;
@property (nonatomic, assign) NSTimeInterval total_time;
@property (nonatomic, strong) NSMutableArray *conerAdTimeRangesM;
// 自定义横屏状态栏,iphonex 横屏时用
@property (nonatomic, weak) UIView *statusBar;
@property (nonatomic, weak) UILabel *sysTimeLabel;
@property (nonatomic, strong) HCWeakTimer *sysTimer;
@end

@implementation HCVideoPlayerBase

#pragma mark - 懒加载
- (UIView *)contentView
{
    if (_contentView == nil) {
        UIView *contentView = [[UIView alloc] init];
        [self addSubview:contentView];
        _contentView = contentView;
        contentView.backgroundColor = [UIColor blackColor];
    }
    return _contentView;
}

- (HCPlayerView *)urlPlayer
{
    if (_urlPlayer == nil) {
        HCPlayerView *urlPlayer = [[HCPlayerView alloc] init];
        [self.contentView addSubview:urlPlayer];
        _urlPlayer = urlPlayer;
        urlPlayer.delegate = self;
        //
        _volume = urlPlayer.volume;
        _mixWithOthersWhenMute = urlPlayer.mixWithOthersWhenMute;
        _rate = urlPlayer.rate;
    }
    return _urlPlayer;
}

- (UIView *)statusBar
{
    if (![UIApplication sharedApplication].isStatusBarHidden) {
        [_statusBar removeFromSuperview];
        return nil;
    }
    if (_statusBar == nil) {
        UIView *statusBar = [[UIView alloc] init];
        [self.contentView addSubview:statusBar];
        _statusBar = statusBar;
        statusBar.alpha = 0;
    }
    [self.contentView bringSubviewToFront:_statusBar];
    return _statusBar;
}

- (UILabel *)sysTimeLabel
{
    if (_sysTimeLabel == nil) {
        UILabel *sysTimeLabel = [[UILabel alloc] init];
        [self.statusBar addSubview:sysTimeLabel];
        _sysTimeLabel = sysTimeLabel;
        sysTimeLabel.font = [UIFont systemFontOfSize:14];
        sysTimeLabel.numberOfLines = 1;
        sysTimeLabel.textColor = [UIColor whiteColor];
        sysTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _sysTimeLabel;
}

#pragma mark - setter
- (void)setUrl:(NSURL *)url
{
    _url = url;
    // 投屏url排除本地视频
    if (![_url.absoluteString containsString:@"localhost:"] && ![_url.absoluteString containsString:@"127.0.0.1"]) {
        _castUrl = _url;
    }
}

- (void)setVolume:(CGFloat)volume
{
    _volume = volume;
    self.urlPlayer.volume = _volume;
}

- (void)setMixWithOthersWhenMute:(bool)mixWithOthersWhenMute
{
    _mixWithOthersWhenMute = mixWithOthersWhenMute;
    self.urlPlayer.mixWithOthersWhenMute = _mixWithOthersWhenMute;
}

- (void)setRate:(CGFloat)rate
{
    _rate = rate;
    self.urlPlayer.rate = rate;
}

- (void)setCurController:(UIViewController *)curController
{
    _curController = curController;
    _rootPresentVc = [self getRootPresentVcWithCurVc:_curController];
    if (_rootPresentVc == nil) {
        _rootPresentVc = [UIView vp_rootWindow].rootViewController;
    }
}

- (void)setVideoAdsItem:(HCVideoAdsItem *)videoAdsItem
{
    _videoAdsItem = videoAdsItem;
    [self showVideoAd];
}

- (void)setCornerAdsItem:(HCConnerAdsItem *)cornerAdsItem
{
    _cornerAdsItem = cornerAdsItem;
    _conerAdTimeRangesM = nil; // 设为nil，表示重新开始设置角落广告范围
    [self hiddenCornerAd];
    [self setupCornerTimeRangs];
}

- (void)setZoomStatus:(HCVideoPlayerZoomStatus)zoomStatus
{
    _zoomStatus = zoomStatus;
    if (_zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        [HCSmallWindow removeSmallWindow];
    }
}

#pragma mark - getter
- (HCVideoPlayerStatus)status
{
    HCVideoPlayerStatus status = HCVideoPlayerStatusIdle;
    if (_url && _urlPlayer.playerState == HCPlayerViewStateReadying) {
        status = HCVideoPlayerStatusReadying;
    }
    else if (_url && _urlPlayer.playerState == HCPlayerViewStateReadyed)
    {
        status = HCVideoPlayerStatusReadyed;
    }
    else if (_url && _urlPlayer.playerState == HCPlayerViewStatePlay)
    {
        status = HCVideoPlayerStatusPlay;
    }
    else if (_url && _urlPlayer.playerState == HCPlayerViewStatePause)
    {
        status = HCVideoPlayerStatusPause;
    }
    else if (_url && _urlPlayer.playerState == HCPlayerViewStatePlayback)
    {
        status = HCVideoPlayerStatusPlayback;
    }
    else if (_url && _urlPlayer.playerState == HCPlayerViewStateStop)
    {
        status = HCVideoPlayerStatusStop;
    }
    else if (_url && _urlPlayer.playerState == HCPlayerViewStateError)
    {
        status = HCVideoPlayerStatusError;
    }
    return status;
}

#pragma mark - 外部方法
- (void)playWithUrl:(NSURL *)url
{
    __weak typeof(self) weakSelf = self;
    [self playWithUrl:url readyComplete:^(HCVideoPlayerBase *videoPlayer, HCVideoPlayerStatus status) {
        [weakSelf play];
    }];
}
- (void)playWithUrl:(NSURL *)url readyComplete:(HCVideoPlayerReadyComplete)readyComplete
{
    [self playWithUrl:url forceReload:NO readyComplete:readyComplete];
}

- (void)play
{
    if (_url)
    {
        [_urlPlayer play];
    }
}

- (void)pause
{
    if (_url)
    {
        [_urlPlayer pause];
    }
}

- (void)resume
{
    if (_url)
    {
        [_urlPlayer play];
    }
}

- (void)stop
{
    @autoreleasepool {
        [_urlPlayer stop];
        [[HCNetWorkSpeed shareNetworkSpeed] stopMonitoringNetworkSpeed];
    }
}

- (void)seekToTime:(NSTimeInterval)time autoPlay:(BOOL)autoPlay
{
    [self seekToTime:time autoPlay:autoPlay complete:nil];
}

- (void)seekToTime:(NSTimeInterval)time autoPlay:(BOOL)autoPlay complete:(void (^)(BOOL finished))complete
{
    [self.urlPlayer seekToTime:time autoPlay:autoPlay complete:^(BOOL finished) {
        if (complete) {
            complete(finished);
        }
    }];
}

- (void)stopAndExitFullScreen
{
    [self stop];
    [self removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(stopAndExitFullScreenForVideoPlayer:)]) {
        [self.delegate stopAndExitFullScreenForVideoPlayer:self];
    }
}

- (void)getCurrentTimeImageComplete:(void (^)(UIImage *image))complete
{
    [_urlPlayer getCurrentTimeImageComplete:^(UIImage *image) {
        if (complete) {
            complete(image);
        }
    }];
}

#pragma mark - 需子类重写的方法
- (void)playWithUrl:(NSURL *)url forceReload:(BOOL)forceReload readyComplete:(HCVideoPlayerReadyComplete)readyComplete
{
    
}

- (void)makeZoom
{
    
}

- (void)makeZoomIn
{
    [self hiddenCornerAd];
}

- (void)playAfterShowOtherView
{
    
}

- (void)addSubViewToControllContentViewBottom:(UIView *)view
{
    
}

#pragma mark - 播放通知
- (void)onGetTotalTime:(NSTimeInterval)totalTime
{
    _total_time = totalTime;
    [self setupCornerTimeRangs];
}

- (void)onGetPlayTime:(NSTimeInterval)playTime
{
    if (_total_time <= 0) {
        return;
    }
    
    NSArray *timeRanges = [NSMutableArray arrayWithArray:_conerAdTimeRangesM];
    for (HCCornerAdTimeRange *timeRange in timeRanges) {
        if (playTime >= timeRange.startTime && playTime < timeRange.endTime) {
            [_conerAdTimeRangesM removeObject:timeRange];
            [self showCornerAd];
            break;
        }
    }
    
}

#pragma mark - 初始化
- (instancetype)initWithCurController:(UIViewController *)curController
{
    if (self = [super init]) {
        self.curController = curController;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.clipsToBounds = YES;
        _rootPresentVc = [UIView vp_rootWindow].rootViewController;
        self.sysTimer = [HCWeakTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sysTimerEvent) userInfo:nil repeats:YES];
    }
    return self;
}

- (void)dealloc
{
    [self.sysTimer stop];
    self.sysTimer = nil;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupVideoAdViewFrame];
    [self setupPicAdViewFrame];
    [self setupStatusBarFrame];
}

#pragma mark - 事件
- (void)sysTimerEvent
{
    self.sysTimeLabel.text = [NSString getCurrentTimesHHmm];
}

#pragma mark - 内部方法
- (UIViewController *)getRootPresentVcWithCurVc:(UIViewController *)curVc
{
    if (curVc == nil) {
        curVc = [UIViewController vp_currentVC];
    }
    UIViewController *rootPresentVc = nil;
    if (curVc.parentViewController) {
        rootPresentVc = curVc.parentViewController;
        UIViewController *parentVc = [self getRootPresentVcWithCurVc:rootPresentVc];
        if (parentVc) {
            return parentVc;
        }
        else
        {
            return rootPresentVc;
        }
    }
    else
    {
        return curVc;
    }
}

- (void)setupStatusBarFrame
{
    self.statusBar.vp_y = 0;
    self.statusBar.vp_width = self.vp_width;
    self.statusBar.vp_height = 20;
    self.sysTimeLabel.vp_width = self.vp_width;
    self.sysTimeLabel.vp_height = 20;
    
    self.statusBar.hidden = (self.zoomStatus == HCVideoPlayerZoomStatusZoomIn ? YES : NO);
}

#pragma mark - 播放器上广告
#pragma mark 贴片广告
/** 显示贴片广告 */
- (void)showVideoAd
{
    if (![HCAirplayCastTool isAirPlayOnCast] && _videoAdsItem.ads.count) {
        
        self.whenAppActiveNotToPlay = YES;
        self.isManualStopOrPausePlay = YES;
        [self pause];
        
        [_videoAdView removeFromSuperview];
        _videoAdView = nil;
        
        HCVideoAdView *videoAdView = [[HCVideoAdView alloc] init];
        _videoAdView = videoAdView;
        [self addSubview:videoAdView];
        videoAdView.delegate = self;
        videoAdView.adsItem = _videoAdsItem;
        [self setupVideoAdViewFrame];
    }
}

- (void)setupVideoAdViewFrame {
    self.videoAdView.frame = self.bounds;
    if (_zoomStatus == HCVideoPlayerZoomStatusZoomIn) {
        return;
    }
    // 适配iPhoneX
    if (self.videoAdView.vp_width > self.videoAdView.vp_height) {
        CGFloat width = self.videoAdView.vp_width - (kVP_IS_FullScreen ? 68 : 0);
        self.videoAdView.vp_x = (self.videoAdView.vp_width - width) * 0.5;
        self.videoAdView.vp_width = width;
    }
    else
    {
        CGFloat height = self.videoAdView.vp_height - (kVP_IS_FullScreen ? 68 : 0);
        self.videoAdView.vp_y = (self.videoAdView.vp_height - height) * 0.5;
        self.videoAdView.vp_height = height;
    }
}

/** 隐藏贴片广告 */
- (void)hiddenVideoAd
{
    [_videoAdView removeFromSuperview];
    _videoAdView = nil;
    self.whenAppActiveNotToPlay = NO;
    self.isManualStopOrPausePlay = NO;
    _videoAdsItem = nil;
}

#pragma mark 暂停图片广告
- (void)showPicAd
{
    if (![HCAirplayCastTool isAirPlayOnCast] && self.isManualStopOrPausePlay && !_videoAdView) {
        
        [_picAdView removeFromSuperview];
        _picAdView = nil;
        
        HCPicAdView *picAdView = [[HCPicAdView alloc] init];
        [self.contentView addSubview:picAdView];
        _picAdView = picAdView;
        picAdView.delegate = self;
        picAdView.picItems = _picAdsItem;
        [picAdView sizeToFit];
        picAdView.vp_x = (self.vp_width - picAdView.vp_width) * 0.5;
        picAdView.vp_y = (self.vp_height - picAdView.vp_height) * 0.5;
    }
}

- (void)setupPicAdViewFrame
{
    [_picAdView sizeToFit];
    _picAdView.vp_x = (self.vp_width - _picAdView.vp_width) * 0.5;
    _picAdView.vp_y = (self.vp_height - _picAdView.vp_height) * 0.5;
}

- (void)hiddenPicAd
{
    [_picAdView removeFromSuperview];
    _picAdView = nil;
}

#pragma mark 角落图片广告
- (void)showCornerAd
{
    if (![HCAirplayCastTool isAirPlayOnCast] && !_videoAdView) {
        
        [_cornerAdView removeFromSuperview];
        _cornerAdView = nil;
        
        HCCornerAdView *cornerAdView = [[HCCornerAdView alloc] init];
        [self addSubViewToControllContentViewBottom:cornerAdView];
        _cornerAdView = cornerAdView;
        cornerAdView.delegate = self;
        cornerAdView.cornerItems = _cornerAdsItem.ads;
        [cornerAdView sizeToFit];
        
        NSDictionary *positionsD = @{@"lefttop" : @[@(34), @(10)],
                                   @"leftbottom" : @[@(34), @(self.vp_height - cornerAdView.vp_height - 10)],
                                   @"rightbottom" : @[@(self.vp_width - cornerAdView.vp_width - 34), @(self.vp_height - cornerAdView.vp_height - 10)]
                                   };
        NSArray *position = positionsD[_cornerAdsItem.corner_dir];
        if (position.count == 2) {
            cornerAdView.vp_x = [position.firstObject doubleValue];
            cornerAdView.vp_y = [position.lastObject doubleValue];
        }
        else {
            cornerAdView.vp_x = 34;
            cornerAdView.vp_y = self.vp_height - cornerAdView.vp_height - 10;
        }
    }
}

- (void)setupConerAdViewFrame
{
    [_cornerAdView sizeToFit];
    _cornerAdView.vp_x = (self.vp_width - _cornerAdView.vp_width) * 0.5;
    _cornerAdView.vp_y = (self.vp_height - _cornerAdView.vp_height) * 0.5;
}

- (void)hiddenCornerAd
{
    [_cornerAdView removeFromSuperview];
    _cornerAdView = nil;
}

- (void)setupCornerTimeRangs
{
    if (_conerAdTimeRangesM != nil) {
        return;
    }
    
    if (_total_time <= 0) {
        _conerAdTimeRangesM = nil;
        return;
    }
    
    _conerAdTimeRangesM = [NSMutableArray array];
    NSArray *timeSpans = @[@(0.2), @(0.8)];
    if (_total_time > 30 * 60) {
        timeSpans = @[@(0.2), @(0.5), @(0.8)];
    }
    
    for (NSNumber *timeSpan in timeSpans) {
        HCCornerAdTimeRange *timeRange = [[HCCornerAdTimeRange alloc] init];
        timeRange.startTime = _total_time * timeSpan.doubleValue;
        timeRange.endTime = _total_time * (timeSpan.doubleValue + 0.1);
        [_conerAdTimeRangesM addObject:timeRange];
    }
}

- (void)resumePlay
{
    self.isManualStopOrPausePlay = NO;
    if (self.isLive || self.status == HCVideoPlayerStatusIdle || self.status == HCVideoPlayerStatusStop || self.status == HCVideoPlayerStatusError) {
        __weak typeof(self) weakSelf = self;
        [self playWithUrl:self.url forceReload:YES readyComplete:^(id videoPlayer, HCVideoPlayerStatus status) {
            [weakSelf play];
        }];
    }
    else
    {
        [self playWithUrl:self.url];
    }
}

- (void)openAdWithAdItem:(HCVideoAdItem *)adItem
{
    _curOpenedAdItem = adItem;
    BOOL isExecute = YES;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickAdItem:)]) {
        isExecute = [self.delegate videoPlayer:self didClickAdItem:adItem];
    }
    if (!isExecute) {
        return;
    }
    
    // 其他链接跳转
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:adItem.url]]) {
        return;
    }
    
    if (adItem.opentype.integerValue == 0) { // 外部浏览器打开
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:adItem.url]];
    }
    else { // 内部浏览器打开
        HCNavWebController *vc = [[HCNavWebController alloc] init];
        vc.url = [NSURL URLWithString:adItem.url];
        vc.delegate = self;
        if ([adItem.adstype isEqualToString:@"video"]) {
            [_videoAdView pause];
        }
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        if (self.noZoomInShowModel) {
            [self.orVC presentViewController:vc animated:NO completion:nil];
        }
        else {
            [self makeZoomIn];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[UIViewController vp_currentVC] presentViewController:vc animated:NO completion:nil];
            });
        }
    }
}

#pragma mark - KTVideoAdViewDelegate
- (void)didClickBackBtnForVideoAdView:(HCVideoAdView *)videoAdView
{
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickBackBtnAtZoomStatus:)]) {
        [self.delegate videoPlayer:self didClickBackBtnAtZoomStatus:self.zoomStatus];
    }
    if (self.zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        [self makeZoom];
    }
}

- (void)didClickSkipBtnForVideoAdView:(HCVideoAdView *)videoAdView
{
    [self hiddenVideoAd];
    [self resumePlay];
}

- (void)didClickZoomBtnForVideoAdView:(HCVideoAdView *)videoAdView
{
    [self makeZoom];
}

- (void)videoAdView:(HCVideoAdView *)videoAdView didClickAdItem:(HCVideoAdItem *)adItem
{
    [self openAdWithAdItem:adItem];
}

- (void)didAdsPlayCompleteForVideoAdView:(HCVideoAdView *)videoAdView
{
    [self hiddenVideoAd];
    [self resumePlay];
}

#pragma mark - HCPicAdViewDelegate
- (void)vpPicAdView:(HCPicAdView *)vpPicAdView didClickAdItem:(HCVideoAdItem *)adItem
{
    [self hiddenPicAd];
    [self openAdWithAdItem:adItem];
}

#pragma mark - HCCornerAdViewDelegate
- (void)cornerAdView:(HCCornerAdView *)cornerAdView didClickAdItem:(HCVideoAdItem *)adItem
{
    [self hiddenCornerAd];
    [self openAdWithAdItem:adItem];
}

#pragma mark - HCNavWebControllerDelegate
- (void)didClickBackBtnForNavWebController:(HCNavWebController *)navWebController
{
    // 影视播放暂停弹窗广告类型，广告页回来后还是暂停，且显示广告
    if ([_curOpenedAdItem.adstype isEqualToString:@"photo"]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self showPicAd];
        });
        return;
    }
    // 影视开始播放前视频广告类型，广告页回来后继续播放广告
    [_videoAdView play];
}
@end
