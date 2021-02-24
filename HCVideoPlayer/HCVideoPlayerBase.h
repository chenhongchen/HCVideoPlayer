//
//  HCVideoPlayerBase.h
//  HCVideoPlayer
//
//  Created by chc on 2019/5/6.
//  Copyright © 2019 chc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCVideoPlayerConst.h"
#import "HCOrientController.h"
#import "HCVideoPlayerDelegate.h"
#import "HCPlayerView.h"
#import "HCVideoAdsItem.h"
#import "HCConnerAdsItem.h"

@interface HCVideoPlayerBase : UIView<HCPlayerViewDelegate>
{
    HCPlayerView *_urlPlayer;
    NSURL *_url;
    NSURL *_castUrl;
    CGFloat _volume;
    CGFloat _rate;
    NSString *_photo;
    HCVideoPlayerZoomType _zoomType;
//    HCVideoPlayerZoomStatus _zoomStatus;
    BOOL _whenAppActiveNotToPlay;
    BOOL _isManualStopOrPausePlay;
    __weak HCOrientController *_orVC;
    BOOL _isLive;
    BOOL _noZoomInShowModel;
}
@property (nonatomic, strong, readonly) HCPlayerView *urlPlayer; // url播放器
@property (nonatomic, weak, readonly) UIView *statusBar;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSURL *castUrl;
/** 用于投屏封面 */
@property (nonatomic, copy) NSString *photo;
/** 音量（非系统音量） */
@property (nonatomic, assign) CGFloat volume;
@property (nonatomic, assign) bool mixWithOthersWhenMute;
/** 播放速度 */
@property (nonatomic, assign) CGFloat rate;
/** 缩放类型 */
@property (nonatomic, assign) HCVideoPlayerZoomType zoomType;
/** 缩放状态 */
@property (nonatomic, assign) HCVideoPlayerZoomStatus zoomStatus;
/** 贴片广告模型 */
@property (nonatomic, strong) HCVideoAdsItem *videoAdsItem;
/** 暂停图片广告 */
@property (nonatomic, strong) NSArray <HCVideoAdItem *> *picAdsItem;
/** 角落图片广告 */
@property (nonatomic, strong) HCConnerAdsItem *cornerAdsItem;

- (void)playWithUrl:(NSURL *)url;
- (void)playWithUrl:(NSURL *)url readyComplete:(HCVideoPlayerReadyComplete)readyComplete;
- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;
- (void)seekToTime:(NSTimeInterval)time autoPlay:(BOOL)autoPlay;
- (void)seekToTime:(NSTimeInterval)time autoPlay:(BOOL)autoPlay complete:(void (^)(BOOL finished))complete;

@property (nonatomic, weak) id <HCVideoPlayerDelegate> delegate;

/** 初始化，并传入当前控制器 */
- (instancetype)initWithCurController:(UIViewController *)curController;

/** 如果显示播放器的控制器是preset出来的，这项必填 */
@property (nonatomic, weak) UIViewController *curController;

@property (nonatomic, assign, readonly) HCVideoPlayerStatus status;
@property (nonatomic, weak, readonly) UIView *contentView;
/** present方向根控制器 */
@property (nonatomic, weak, readonly) UIViewController *rootPresentVc;
@property (nonatomic, weak) HCOrientController *orVC;

@property (nonatomic, copy) UIView *(^getPlayerSuperViewBlock)(id videoPlayer);
@property (nonatomic, copy) id <HCVideoPlayerDelegate> (^getPlayerDelegateBlock)(id videoPlayer);

/** 停止播放并退出全屏 */
- (void)stopAndExitFullScreen;
/** 获取播放器截屏 */
- (void)getCurrentTimeImageComplete:(void (^)(UIImage *image))complete;

/// 当激活APP时不播放
@property (nonatomic, assign) BOOL whenAppActiveNotToPlay;

/// 主动暂停或停止
@property (nonatomic, assign) BOOL isManualStopOrPausePlay;

/** 是否是直播 */
@property (nonatomic, assign) BOOL isLive;

// 没有缩小模式
@property (nonatomic, assign) BOOL noZoomInShowModel;

- (void)playAfterShowOtherView;
- (void)makeZoom;

/** 变为非全屏显示 */
- (void)makeZoomIn;

- (void)showPicAd;
- (void)hiddenPicAd;

- (void)onGetTotalTime:(NSTimeInterval)totalTime;
- (void)onGetPlayTime:(NSTimeInterval)playTime;

- (void)addSubViewToControllContentViewBottom:(UIView *)view;
@end
