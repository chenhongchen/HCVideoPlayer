//
//  HCVideoPlayerDelegate.h
//  HCVideoPlayer
//
//  Created by chc on 2019/5/3.
//  Copyright © 2019 chc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HCVideoAdItem.h"

@class HCVideoPlayerBase;
@protocol HCVideoPlayerDelegate <NSObject>
@optional
// 播放相关
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer playTime:(NSTimeInterval)playTime;
- (void)didStartPlayForVideoPlayer:(HCVideoPlayerBase *)videoPlayer;
- (void)didReadyForPlayForVideoPlayer:(HCVideoPlayerBase *)videoPlayer;
- (void)didContinuePlayForVideoPlayer:(HCVideoPlayerBase *)videoPlayer;
- (void)didPausePlayForVideoPlayer:(HCVideoPlayerBase *)videoPlayer;
- (void)didStopPlayForVideoPlayer:(HCVideoPlayerBase *)videoPlayer;
- (void)didPlaybackForVideoPlayer:(HCVideoPlayerBase *)videoPlayer;
- (void)didLoadErrorForVideoPlayer:(HCVideoPlayerBase *)videoPlayer;

// 其他
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer changedZoomStatus:(HCVideoPlayerZoomStatus)zoomStatus;
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickPlayBtn:(UIButton *)playBtn;
// 返回NO则不执行内部处理
- (BOOL)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickBackBtnAtZoomStatus:(HCVideoPlayerZoomStatus)zoomStatus;
- (BOOL)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickMoreBtn:(UIButton *)moreBtn;
- (BOOL)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickShareBtn:(UIButton *)shareBtn;
- (BOOL)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickTVBtn:(UIButton *)tvBtn;
- (BOOL)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickCameraBtn:(UIButton *)cameraBtn;
// 点击了选集按钮
- (BOOL)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickEpisodeBtn:(UIButton *)episodeBtn;
// 点击了切换按钮
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickSwitchBtn:(UIButton *)switchBtn;
// 点击了锁按钮
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickLockBtn:(UIButton *)lockBtn;
// 点击了下一个按钮
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickNextBtn:(UIButton *)nextBtn;
// 点击了上一个按钮
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickLastBtn:(UIButton *)lastBtn;
// 点击了弹幕按钮
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickBarrageBtn:(UIButton *)barrageBtn;
// 点击了弹幕选择颜色按钮
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickBarrageSelColorBtn:(UIButton *)barrageSelColorBtn;
// 点击了发送弹幕按钮
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickBarrageSendBtn:(UIButton *)barrageSendBtn;
// 点击了缩放按钮
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickZoomBtn:(UIButton *)zoomBtn;
// 点击了播放速度按钮
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickPlaySpeedBtn:(UIButton *)playSpeedBtn;

// morePanel
- (void)didClickMorePanelDLBtnForVideoPlayer:(HCVideoPlayerBase *)videoPlayer;
- (void)didClickCtBtnForVideoPlayer:(HCVideoPlayerBase *)videoPlayer;
- (void)didClickStBtnForVideoPlayer:(HCVideoPlayerBase *)videoPlayer;
- (void)didClickTimeCloseForVideoPlayer:(HCVideoPlayerBase *)videoPlayer;
// 点击了收藏按钮状态变化
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didChangeMorePanelColloctStatus:(BOOL)status;
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didSelectRate:(CGFloat)rate;
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didChangeFullScreenShowValue:(BOOL)value;
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didChangeAutoSkipValue:(BOOL)value;
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didChangeSmallWindowValue:(BOOL)value;

// sharePanel
// 点击了分享面板的Item，可通过Item里的key，来判断是分享链接，还是图片；
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didSelectSharePanelItem:(HCShareItem *)item shareImage:(UIImage *)shareImage;
// 点击了选集面板Item
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didSelectSelEpisodeItem:(NSString *)item atIndex:(NSInteger)index;
// 点击了加载错误Label
- (void)didClickErrorTextForvideoPlayer:(HCVideoPlayerBase *)videoPlayer;

- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didStartCast:(NSString *)castType;
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didEndCast:(NSString *)castType;
- (void)videoPlayer:(HCVideoPlayerBase *)videoPlayer didChangeProgress:(double)progress;
- (void)stopAndExitFullScreenForVideoPlayer:(HCVideoPlayerBase *)videoPlayer;
// 点击了广告 返回NO则不执行内部处理
- (BOOL)videoPlayer:(HCVideoPlayerBase *)videoPlayer didClickAdItem:(HCVideoAdItem *)adItem;
// 点击了屏幕，显示控制界面
- (void)didClickControllContentViewFroVideoPlayer:(HCVideoPlayerBase *)videoPlayer;
// 点击了控制界面，隐藏控制界面
- (void)didClickcontrollerViewFroVideoPlayer:(HCVideoPlayerBase *)videoPlayer;
@end
