//
//  HCVideoPlayer.h
//  HCVideoPlayer
//
//  Created by chc on 2017/6/3.
//  Copyright © 2017年 chc. All rights reserved.
//

#import "HCVideoPlayerBase.h"

@interface HCVideoPlayer : HCVideoPlayerBase
@property (nonatomic, copy) HCVideoPlayerReadyComplete readyComplete;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, assign, readonly) NSTimeInterval totalTime;
/** 收藏状态 */
@property (nonatomic, assign) BOOL collectStatus;
/** 缩小时是否显示返回按钮（默认是）*/
@property (nonatomic, assign) BOOL showBackWhileZoomIn;

/** 在全屏时，设备旋转到竖直时是否要取消全屏 */
@property (nonatomic, assign) BOOL zoomInWhenVerticalScreen;

@property (nonatomic, assign) UIDeviceOrientation deviceOrientation;

/** 直接全屏显示在keyWindow上 */
+ (instancetype)showWithUrl:(NSURL *)url curController:(UIViewController *)curController showComplete:(void (^)(void))showComplete;
+ (instancetype)showWithUrl:(NSURL *)url curController:(UIViewController *)curController autoPlay:(BOOL)autoPlay showComplete:(void (^)(void))showComplete readyComplete:(HCVideoPlayerReadyComplete)readyComplete;
+ (instancetype)showWithZoomType:(HCVideoPlayerZoomType)zoomType curController:(UIViewController *)curController showComplete:(void (^)(void))showComplete;
+ (instancetype)showWithVideoPlayer:(HCVideoPlayer *)videoPlayer zoomType:(HCVideoPlayerZoomType)zoomType curController:(UIViewController *)curController showComplete:(void (^)(void))showComplete;
/** 是否显示（配合+showWithUrl:类方法使用） */
@property (nonatomic, assign, readonly) BOOL isShowing;
/** 直接全屏显示在keyWindow上，配合showWithUrl方法 */
- (void)playAfterShow;

/** 配合+showWithUrl:类方法使用 */
- (void)hiddenSelf;

/** 对接播放（用于切换源的清晰度） */
- (void)joint_playWithUrl:(NSURL *)url complete:(void(^)(BOOL isJointSuccess))complete;

/** 成为GoogleCastListener */
- (void)becomeGoogleCastListener;

/** 展示你想显示的消息 */
- (void)showMsg:(NSString *)msg stopPlay:(BOOL)stopPlay autoHidden:(BOOL)autoHidden;
- (void)showMsg:(NSString *)msg stopPlay:(BOOL)stopPlay autoHidden:(BOOL)autoHidden duration:(CGFloat)duration;

/** 隐藏展示的消息 */
- (void)hiddenMsgAnimation:(BOOL)animation;

/** 显示加载动画 */
- (void)showLoading;
/** 隐藏加载动画 */
- (void)hiddenLoading;

/** 显示加载错误文案 */
- (void)showLoadError;
/** 隐藏加载错误文案 */
- (void)hiddenLoadError;

- (void)applicationWillResignActive;
- (void)applicationDidBecomeActive;

@property (nonatomic, strong) UIView *barrageView;

@property (nonatomic, assign) BOOL showMoreBtn;
@property (nonatomic, assign) BOOL showShareBtn;
@property (nonatomic, assign) BOOL showTvBtn;
@property (nonatomic, assign) BOOL showCameraBtn;
@property (nonatomic, assign) BOOL showNextBtn;
@property (nonatomic, assign) BOOL showBarrageBtn;
@property (nonatomic, assign) BOOL showBarrageSelColorBtn;
@property (nonatomic, assign) BOOL showBarrageSendBtn;
@property (nonatomic, assign) BOOL showEpisodeBtn;
@property (nonatomic, assign) BOOL showFullShowBtn;
@property (nonatomic, assign) BOOL showSwitchBtn;
@property (nonatomic, assign) BOOL showLockBtn;
@property (nonatomic, assign) BOOL showZoomBtn;

@property (nonatomic, assign) BOOL zoomInHiddenMoreBtn;
@property (nonatomic, assign) BOOL zoomInHiddenShareBtn;
@property (nonatomic, assign) BOOL zoomInHiddenTvBtn;
@property (nonatomic, assign) BOOL zoomInHiddenCameraBtn;
@property (nonatomic, assign) BOOL zoomInHiddenNextBtn;
@property (nonatomic, assign) BOOL zoomInHiddenEpisodeBtn;
@property (nonatomic, assign) BOOL zoomInHiddenFullShowBtn;
@property (nonatomic, assign) BOOL zoomInHiddenSwitchBtn;
@property (nonatomic, assign) BOOL zoomInHiddenLockBtn;

@property (nonatomic, assign) BOOL autoZoom;

// MorePanel
@property (nonatomic, assign) BOOL enableDlBtn;
@property (nonatomic, assign) BOOL enableStBtn;
@property (nonatomic, assign) BOOL enableAddToMyDefWBBtn;

/** 是否开启弹幕 */
@property (nonatomic, assign) BOOL isBarrageOpen;

/** 点击播放器是否退出键盘 */
@property (nonatomic, assign) BOOL endEditWhenClickSelf;

/** 选集列表的标题 */
@property (nonatomic, strong) NSArray <NSString *> *episodeTitles;
/** 选集列表cell是否为big显示类型 */
@property (nonatomic, assign) BOOL isBigSelEpisodeType;
@property (nonatomic, assign) NSInteger selEpisodeIndex;

// 定时类型
@property (nonatomic, assign, readonly) HCTimingType timingType;

// 是否在投屏
@property (nonatomic, assign, readonly) BOOL isOnCast;
+ (BOOL)isOnAirPlayCast;
@end

