//
//  HCVideoPlayer.m
//  HCVideoPlayer
//
//  Created by chc on 2017/6/3.
//  Copyright © 2017年 chc. All rights reserved.
//
#define kHCVP_BottomBarHeight 92
#define kHCVP_BtnWidth 50
#define kHCVP_TextBtnWidth 60

#import "HCVideoPlayer.h"
#import <MediaPlayer/MediaPlayer.h>
#import "HCQualitySheet.h"
#import "AppDelegate+VP.h"
#import "HCTVControllView.h"
#import "HCSelectTvDevController.h"
#import "HCSharePanel.h"
#import "HCMorePanel.h"
#import "HCSelEpisodePanel.h"
#import "HCImageShareView.h"
#import "HCHorButton.h"
#import "UIView+Tap.h"
#import "HCGoogleCastTool.h"
#import "UIViewController+VP.h"
#import "HCGoogleCastTool.h"
#import "HCAirplayCastTool.h"
#import "HCPTPTool.h"
#import "BrightnessView.h"
#import "HCFastForwardAndBackView.h"
#import "HCTimingView.h"
#import "HCLoadingView.h"
#import "HCProgressView.h"
#import "HCProgressImageView.h"

@interface HCVideoPlayer ()<HCProgressViewDelegate, HCOrientControllerDelegate, HCSelectTvDevControllerDelegate, HCTVControllViewDelegate, HCSharePanelDelegate, HCSelEpisodePanelDelegate, HCSelEpisodePanelDelegate, HCMorePanelDelegate, GCKSessionManagerListener, HCFastForwardAndBackViewDelegate>
{
    __weak HCSharePanel *_sharePanel;
    __weak HCMorePanel *_morePanel;
    __weak HCSelEpisodePanel *_selEpisodePanel;
}
@property (nonatomic, weak) HCPlayerView *jointPlayerView;
@property (nonatomic, weak) UILabel *loadErrorLabel;
@property (nonatomic, weak) HCLoadingView *activityIndicator;
@property (nonatomic, weak) UILabel *loadSpeedLabel;

/// 控制容器
@property (nonatomic, weak) UIView *controllContentView;

// 播放控制界面控件
// 顶部
@property (nonatomic, weak) UIButton *backBtn;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIImageView *topBarShadow;
@property (nonatomic, weak) UIImageView *topBar;
@property (nonatomic, weak) UIButton *tvBtn;
@property (nonatomic, weak) UIButton *shareBtn;
@property (nonatomic, weak) UIButton *moreBtn;
// 底部
@property (nonatomic, weak) UIButton *playerBtn;
@property (nonatomic, weak) HCProgressView *progressView;
@property (nonatomic, weak) HCProgressView *botProgressView;
@property (nonatomic, weak) UIButton *qualityBtn;
@property (nonatomic, weak) UILabel *timeLabel;
// leftTimeLabel、rightTimeLabe用于短视频类型
@property (nonatomic, weak) UILabel *leftTimeLabel;
@property (nonatomic, weak) UILabel *rightTimeLabe;
@property (nonatomic, weak) UIButton *nextBtn; // 下一集
@property (nonatomic, weak) UIButton *barrageBtn;
@property (nonatomic, weak) UIButton *barrageSendBtn;
@property (nonatomic, weak) UIButton *barrageSelColorBtn;
@property (nonatomic, weak) UIButton *episodeBtn; // 选集
@property (nonatomic, weak) UIButton *fullShowBtn; // 满窗口显示
@property (nonatomic, weak) UIButton *zoomBtn;
@property (nonatomic, weak) UIImageView *bottomShadow;
@property (nonatomic, weak) UIImageView *bottomBar;
//
@property (nonatomic, weak) UIButton *cameraBtn;
@property (nonatomic, weak) UIButton *switchBtn; // 切换线路
@property (nonatomic, weak) HCImageShareView *imageShareView;
@property (nonatomic, weak) HCQualitySheet *qualitySheet;
@property (nonatomic, weak) UIView *controllView;

// 锁屏界面
@property (nonatomic, weak) UIView *lockContentView;
@property (nonatomic, weak) UIImageView *lockTopBar;
@property (nonatomic, weak) UIImageView *lockBottomBar;
// 锁屏按钮
@property (nonatomic, weak) UIButton *lockBtn;

@property (nonatomic, weak) UILabel *progressLabel;
@property (nonatomic, strong) HCProgressImageView *progressImageView;
@property (nonatomic, weak) UILabel *messageLabel;

// TV 控制
@property (nonatomic, weak) HCTVControllView *tvControllView;

//
@property (nonatomic, weak) HCFastForwardAndBackView *fastForwardAndBackView;

// 保存滑动时progressView的滑动开始点的进度
@property (nonatomic, assign) CGFloat panStartProgress;
@property (nonatomic, assign) BOOL isPan;

// 缩放、旋转
@property (nonatomic, assign) CGRect orgRect;
//@property (nonatomic, assign) UIDeviceOrientation deviceOrientation;
@property (nonatomic, weak) UIView *playSuperView;
@property (nonatomic, copy) void (^toZoomInCompleteBlock)(void);
@property (nonatomic, assign) UIStatusBarStyle orgStatusBarStyle;
@property (nonatomic, assign) BOOL orgStatusBarHidden;
@property (nonatomic, assign) BOOL isOnRotaion;

// 系统音量
@property (nonatomic, strong) UISlider* volumeViewSlider;
@property (nonatomic, assign) CGFloat volumeLastY;
// 屏幕亮度
@property (nonatomic, assign) CGFloat brightLastY;
// 当前滑动播放时间
@property (nonatomic, assign) CGFloat currentPanContentViewTime;
// 上次滑动播放时间
@property (nonatomic, assign) CGFloat lastPanContentViewTime;
// -1 为上下方向、0 为没定方向、1 为左右方向
@property (nonatomic, assign) NSInteger slideDirection;

@property (nonatomic, weak) HCSelectTvDevController *tvVc;

@property (nonatomic, strong) HCWeakTimer *timer;

/** 是否显示（配合+showWithUrl:类方法使用） */
@property (nonatomic, assign) BOOL isShowing;

@property (nonatomic, assign) BOOL isBluetoothOutput;

@property (nonatomic, assign) CGFloat airPlayProgress;

// 定时计时器
@property (nonatomic, strong) HCWeakTimer *timingTimer;
@property (nonatomic, assign) HCTimingType timingType;

@property (nonatomic, assign)BOOL isInBackground;
@end

/// 用于AirPlay投屏下，保存播放器.
HCVideoPlayer *g_airPlayVideoPlayer;
@implementation HCVideoPlayer

#pragma mark - 懒加载
- (UIView *)controllContentView
{
    if (_controllContentView == nil) {
        UIView *controllContentView = [[UIView alloc] init];
        [self.contentView addSubview:controllContentView];
        _controllContentView = controllContentView;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controllContentViewClicked)];
        [controllContentView addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewDoubleClicked:)];
        doubleTap.numberOfTapsRequired = 2;
        [controllContentView addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return _controllContentView;
}

- (UILabel *)loadErrorLabel
{
    if (_loadErrorLabel == nil) {
        UILabel *loadErrorLabel = [[UILabel alloc] init];
        [self.controllContentView addSubview:loadErrorLabel];
        _loadErrorLabel = loadErrorLabel;
        loadErrorLabel.font = [UIFont systemFontOfSize:14];
        loadErrorLabel.textColor = [UIColor whiteColor];
        loadErrorLabel.numberOfLines = 0;
        loadErrorLabel.text = @"视频加载失败!\n点击重试";
        loadErrorLabel.textAlignment = NSTextAlignmentCenter;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadErrorLabelClicked)];
        [loadErrorLabel addGestureRecognizer:tap];
        loadErrorLabel.userInteractionEnabled = YES;
        loadErrorLabel.hidden = YES;
    }
    return _loadErrorLabel;
}

- (UIButton *)backBtn
{
    if (_backBtn == nil) {
        UIButton *backBtn = [[UIButton alloc] init];
        [self.topBar addSubview:backBtn];
        _backBtn = backBtn;
        [backBtn setImage:[UIImage vp_imageWithName:@"vp_back"] forState:UIControlStateNormal];
        [backBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        UILabel *titleLabel = [[UILabel alloc] init];
        [self.topBar addSubview:titleLabel];
        _titleLabel = titleLabel;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.numberOfLines = 2;
    }
    return _titleLabel;
}

- (UIButton *)shareBtn
{
    if (_shareBtn == nil) {
        UIButton *shareBtn = [[UIButton alloc] init];
        [self.topBar addSubview:shareBtn];
        _shareBtn = shareBtn;
        [shareBtn setImage:[UIImage vp_imageWithName:@"vp_share"] forState:UIControlStateNormal];
        [shareBtn sizeToFit];
        [shareBtn addTarget:self action:@selector(shareBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareBtn;
}

- (UIButton *)moreBtn
{
    if (_moreBtn == nil) {
        UIButton *moreBtn = [[UIButton alloc] init];
        [self.topBar addSubview:moreBtn];
        _moreBtn = moreBtn;
        [moreBtn setImage:[UIImage vp_imageWithName:@"vp_more"] forState:UIControlStateNormal];
        [moreBtn sizeToFit];
        [moreBtn addTarget:self action:@selector(moreBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _moreBtn;
}

- (UIButton *)tvBtn
{
    if (_tvBtn == nil) {
        UIButton *tvBtn = [[UIButton alloc] init];
        [self.topBar addSubview:tvBtn];
        _tvBtn = tvBtn;
        [tvBtn setImage:[UIImage vp_imageWithName:@"vp_airplay"] forState:UIControlStateNormal];
        [tvBtn sizeToFit];
        [tvBtn addTarget:self action:@selector(tvBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _tvBtn;
}

- (UIButton *)fullShowBtn
{
    if (_fullShowBtn == nil) {
        UIButton *fullShowBtn = [[UIButton alloc] init];
        [self.bottomBar addSubview:fullShowBtn];
        _fullShowBtn = fullShowBtn;
        [fullShowBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [fullShowBtn setTitle:@"满屏" forState:UIControlStateNormal];
        [fullShowBtn setTitle:@"恢复" forState:UIControlStateSelected];
        fullShowBtn.titleLabel.font = kVP_Font(14);
        [fullShowBtn addTarget:self action:@selector(didClickFullShowBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        BOOL isFullShow =  [[NSUserDefaults standardUserDefaults] boolForKey:VPFullScreenShow];
        fullShowBtn.selected = isFullShow;
    }
    return _fullShowBtn;
}

- (UIButton *)zoomBtn
{
    if (_zoomBtn == nil) {
        UIButton *zoomBtn = [[UIButton alloc] init];
        [self.bottomBar addSubview:zoomBtn];
        _zoomBtn = zoomBtn;
        [zoomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [zoomBtn setImage:[UIImage vp_imageWithName:@"vp_zoom"] forState:UIControlStateNormal];
        [zoomBtn setImage:[UIImage vp_imageWithName:@"vp_zoom"] forState:UIControlStateSelected];
        zoomBtn.titleLabel.font = kVP_Font(14);
        [zoomBtn addTarget:self action:@selector(zoomBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _zoomBtn;
}

- (UIButton *)playerBtn
{
    if (_playerBtn == nil) {
        UIButton *playerBtn = [[UIButton alloc] init];
        [self.bottomBar addSubview:playerBtn];
        _playerBtn = playerBtn;
        [playerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [playerBtn setImage:[UIImage vp_imageWithName:@"vp_play"] forState:UIControlStateNormal];
        [playerBtn setImage:[UIImage vp_imageWithName:@"vp_pause"] forState:UIControlStateSelected];
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
        progressView.progressHeight = 2.0;
        progressView.delegate = self;
    }
    return _progressView;
}

- (HCProgressView *)botProgressView
{
    if (_botProgressView == nil) {
        HCProgressView *botProgressView = [[HCProgressView alloc] init];
        [self.contentView addSubview:botProgressView];
        _botProgressView = botProgressView;
        botProgressView.progressHeight = 2.0;
        botProgressView.hiddenPoint = YES;
        botProgressView.userInteractionEnabled = NO;
        botProgressView.bgColor = [UIColor clearColor];
    }
    return _botProgressView;
}

- (UIButton *)qualityBtn
{
    if (_qualityBtn == nil) {
        UIButton *qualityBtn = [[UIButton alloc] init];
        [self.bottomBar addSubview:qualityBtn];
        _qualityBtn = qualityBtn;
        [qualityBtn setTitle:@"标清" forState:UIControlStateNormal];
        [qualityBtn addTarget:self action:@selector(qualityBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _qualityBtn;
}

- (HCQualitySheet *)qualitySheet
{
    if (_qualitySheet == nil) {
        HCQualitySheet *qualitySheet = [[HCQualitySheet alloc] init];
        [self.controllView addSubview:qualitySheet];
        _qualitySheet = qualitySheet;
        qualitySheet.clipsToBounds = YES;
        qualitySheet.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
        qualitySheet.hidden = YES;
    }
    return _qualitySheet;
}

// 暂时未用到（用 leftTimeLabel 和 rightTimeLabel取代）
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
        timeLabel.hidden = YES;
    }
    return _timeLabel;
}

- (UILabel *)leftTimeLabel
{
    if (_leftTimeLabel == nil) {
        UILabel *timeLabel = [[UILabel alloc] init];
        [self.bottomBar addSubview:timeLabel];
        _leftTimeLabel = timeLabel;
        timeLabel.font = [UIFont systemFontOfSize:13];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.textAlignment = NSTextAlignmentLeft;
        timeLabel.text = @"00:00";
    }
    return _leftTimeLabel;
}

- (UILabel *)rightTimeLabe
{
    if (_rightTimeLabe == nil) {
        UILabel *timeLabel = [[UILabel alloc] init];
        [self.bottomBar addSubview:timeLabel];
        _rightTimeLabe = timeLabel;
        timeLabel.font = [UIFont systemFontOfSize:13];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.textAlignment = NSTextAlignmentRight;
        timeLabel.text = @"00:00";
    }
    return _rightTimeLabe;
}

- (UIButton *)nextBtn
{
    if (_nextBtn == nil) {
        UIButton *nextBtn = [[UIButton alloc] init];
        [self.bottomBar addSubview:nextBtn];
        _nextBtn = nextBtn;
        [nextBtn setImage:[UIImage vp_imageWithName:@"vp_next"] forState:UIControlStateNormal];
        [nextBtn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextBtn;
}

- (UIButton *)barrageBtn
{
    if (_barrageBtn == nil) {
        UIButton *barrageBtn = [[UIButton alloc] init];
        [self.bottomBar addSubview:barrageBtn];
        _barrageBtn = barrageBtn;
        [barrageBtn setImage:[UIImage vp_imageWithName:@"vp_barrage_n"] forState:UIControlStateNormal];
        [barrageBtn setImage:[UIImage vp_imageWithName:@"vp_barrage_h"] forState:UIControlStateSelected];
        [barrageBtn addTarget:self action:@selector(didClickBarrageBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _barrageBtn;
}

- (UIButton *)barrageSendBtn
{
    if (_barrageSendBtn == nil) {
        UIButton *barrageSendBtn = [[UIButton alloc] init];
        [self.bottomBar addSubview:barrageSendBtn];
        _barrageSendBtn = barrageSendBtn;
        [barrageSendBtn setTitle:@"弹幕走一波" forState:UIControlStateNormal];
        [barrageSendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        barrageSendBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        barrageSendBtn.backgroundColor = kVP_ColorWithHexValueA(0xFFFFFF, 0.25);
        barrageSendBtn.clipsToBounds = YES;
        barrageSendBtn.layer.cornerRadius = 3;
        barrageSendBtn.contentEdgeInsets = UIEdgeInsetsMake(0, -70, 0, 0);
        [barrageSendBtn addTarget:self action:@selector(didClickBarrageSendBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _barrageSendBtn;
}

- (UIButton *)barrageSelColorBtn
{
    if (_barrageSelColorBtn == nil) {
        UIButton *barrageSelColorBtn = [[UIButton alloc] init];
        [self.bottomBar addSubview:barrageSelColorBtn];
        _barrageSelColorBtn = barrageSelColorBtn;
        [barrageSelColorBtn setImage:[UIImage vp_imageWithName:@"vp_barrage_sel_color"] forState:UIControlStateNormal];
        [barrageSelColorBtn addTarget:self action:@selector(didClickBarrageSelColorBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _barrageSelColorBtn;
}

- (UIButton *)episodeBtn
{
    if (_episodeBtn == nil) {
        UIButton *episodeBtn = [[UIButton alloc] init];
        [self.bottomBar addSubview:episodeBtn];
        _episodeBtn = episodeBtn;
        [episodeBtn setTitle:@"选集" forState:UIControlStateNormal];
        episodeBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [episodeBtn sizeToFit];
        [episodeBtn addTarget:self action:@selector(episodeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _episodeBtn;
}

- (HCLoadingView *)activityIndicator
{
    if (_activityIndicator == nil) {
        HCLoadingView *activityIndicator = [[HCLoadingView alloc] init];
        [self.controllContentView addSubview:activityIndicator];
        _activityIndicator = activityIndicator;
        activityIndicator.hidden = YES;
    }
    return _activityIndicator;
}

- (UILabel *)loadSpeedLabel
{
    if (_loadSpeedLabel == nil) {
        UILabel *loadSpeedLabel = [[UILabel alloc] init];
        [self.controllContentView addSubview:loadSpeedLabel];
        _loadSpeedLabel = loadSpeedLabel;
        loadSpeedLabel.font = [UIFont systemFontOfSize:12];
        loadSpeedLabel.textColor = [UIColor whiteColor];
        loadSpeedLabel.text = @"0.0KB/s";
        loadSpeedLabel.textAlignment = NSTextAlignmentCenter;
        loadSpeedLabel.hidden = YES;
    }
    return _loadSpeedLabel;
}

- (UIImageView *)topBarShadow
{
    if (_topBarShadow == nil) {
        UIImageView *topBarShadow = [[UIImageView alloc] init];
        [self.topBar addSubview:topBarShadow];
        _topBarShadow = topBarShadow;
        topBarShadow.image = [UIImage vp_imageWithName:@"vp_topBarBg"];
    }
    return _topBarShadow;
}

- (UIImageView *)topBar
{
    if (_topBar == nil) {
        UIImageView *topBar = [[UIImageView alloc] init];
        [self.controllView addSubview:topBar];
//        topBar.image = [UIImage vp_imageWithName:@"vp_topBarBg"];
        _topBar = topBar;
        topBar.userInteractionEnabled = YES;
    }
    return _topBar;
}

- (UIImageView *)bottomShadow
{
    if (_bottomShadow == nil) {
        UIImageView *bottomShadow = [[UIImageView alloc] init];
        [self.bottomBar addSubview:bottomShadow];
        _bottomShadow = bottomShadow;
        bottomShadow.image = [UIImage vp_imageWithName:@"vp_botBarBg"];
    }
    return _bottomShadow;
}

- (UIImageView *)bottomBar
{
    if (_bottomBar == nil) {
        UIImageView *bottomBar = [[UIImageView alloc] init];
        [self.contentView addSubview:bottomBar];
        _bottomBar = bottomBar;
        bottomBar.alpha = 0.0;
        bottomBar.hidden = YES;
//        bottomBar.backgroundColor = kVP_Color(0, 0, 0, 0.3);
//        bottomBar.image = [UIImage vp_imageWithName:@"vp_botBarBg"];
        bottomBar.userInteractionEnabled = YES;
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(bottomBarPan:)];
        [bottomBar addGestureRecognizer:pan];
    }
    [self.contentView bringSubviewToFront:_bottomBar];
    return _bottomBar;
}

- (UIButton *)cameraBtn
{
    if (_cameraBtn == nil) {
        UIButton *cameraBtn = [[UIButton alloc] init];
        [self.controllView addSubview:cameraBtn];
        _cameraBtn = cameraBtn;
        [cameraBtn setImage:[UIImage vp_imageWithName:@"vp_camera"] forState:UIControlStateNormal];
        [cameraBtn sizeToFit];
        [cameraBtn addTarget:self action:@selector(cameraBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cameraBtn;
}

- (UIButton *)switchBtn
{
    if (_switchBtn == nil) {
        UIButton *switchBtn = [[UIButton alloc] init];
        [self.controllView addSubview:switchBtn];
        _switchBtn = switchBtn;
        //        [switchBtn setTitle:@"切换线路" forState:UIControlStateNormal];
        [switchBtn setImage:[UIImage vp_imageWithName:@"vp_switch"] forState:UIControlStateNormal];
        [switchBtn addTarget:self action:@selector(didClickSwitchBtn:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchBtn;
}

- (HCImageShareView *)imageShareView
{
    if (_imageShareView == nil) {
        HCImageShareView *imageShareView = [[HCImageShareView alloc] init];
        [self.controllView addSubview:imageShareView];
        _imageShareView = imageShareView;
        imageShareView.alpha = 0.0;
        imageShareView.layer.cornerRadius = 5;
        imageShareView.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageShareViewClicked)];
        [imageShareView addGestureRecognizer:tap];
    }
    return _imageShareView;
}

- (UIView *)controllView
{
    if (_controllView == nil) {
        UIView *controllView = [[UIView alloc] init];
        [self.controllContentView addSubview:controllView];
        _controllView = controllView;
        controllView.alpha = 0.0;
        controllView.hidden = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controllerViewClicked:)];
        [controllView addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewDoubleClicked:)];
        doubleTap.numberOfTapsRequired = 2;
        [controllView addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return _controllView;
}

- (UIView *)lockContentView
{
    if (_lockContentView == nil) {
        UIView *lockContentView = [[UIView alloc] init];
        [self.controllContentView addSubview:lockContentView];
        _lockContentView = lockContentView;
        lockContentView.alpha = 0.0;
        lockContentView.hidden = YES;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(lockContentViewClicked)];
        [lockContentView addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewDoubleClicked:)];
        doubleTap.numberOfTapsRequired = 2;
        [lockContentView addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return _lockContentView;
}

- (UIImageView *)lockTopBar
{
    if (_lockTopBar == nil) {
        UIImageView *lockTopBar = [[UIImageView alloc] init];
        [self.lockContentView addSubview:lockTopBar];
        lockTopBar.image = [UIImage vp_imageWithName:@"vp_topBarBg"];
        _lockTopBar = lockTopBar;
    }
    return _lockTopBar;
}

- (UIImageView *)lockBottomBar
{
    if (_lockBottomBar == nil) {
        UIImageView *lockBottomBar = [[UIImageView alloc] init];
        [self.lockContentView addSubview:lockBottomBar];
        lockBottomBar.image = [UIImage vp_imageWithName:@"vp_botBarBg"];
        _lockBottomBar = lockBottomBar;
    }
    return _lockBottomBar;
}

- (UIButton *)lockBtn
{
    if (_lockBtn == nil) {
        UIButton *lockBtn = [[UIButton alloc] init];
        [self.controllContentView addSubview:lockBtn];
        _lockBtn = lockBtn;
        [lockBtn setImage:[UIImage vp_imageWithName:@"vp_unlock"] forState:UIControlStateNormal];
        [lockBtn setImage:[UIImage vp_imageWithName:@"vp_locked"] forState:UIControlStateSelected];
        [lockBtn addTarget:self action:@selector(didClickLockBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lockBtn;
}

- (HCProgressImageView *)progressImageView
{
    if (_progressImageView == nil) {
        _progressImageView = [[HCProgressImageView alloc] init];
    }
    [self.contentView insertSubview:_progressImageView belowSubview:self.bottomBar];
    return _progressImageView;
}

- (UILabel *)messageLabel
{
    if (_messageLabel == nil) {
        UILabel *messageLabel = [[UILabel alloc] init];
        [self addSubview:messageLabel];
        _messageLabel = messageLabel;
        messageLabel.font = [UIFont systemFontOfSize:15];
        messageLabel.backgroundColor = kVP_Color(0, 0, 0, 0.3);
        messageLabel.hidden = YES;
        messageLabel.textColor = [UIColor whiteColor];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.layer.cornerRadius = 3;
        messageLabel.clipsToBounds = YES;
    }
    return _messageLabel;
}

- (HCTVControllView *)tvControllView
{
    if (_tvControllView == nil) {
        HCTVControllView *tvControllView = [[HCTVControllView alloc] init];
        [self.controllContentView addSubview:tvControllView];
        _tvControllView = tvControllView;
        tvControllView.delegate = self;
        tvControllView.hidden = YES;
    }
    return _tvControllView;
}

- (UISlider *)volumeViewSlider
{
    if (_volumeViewSlider == nil) {
        MPVolumeView *volumeView = [[MPVolumeView alloc] init];
        volumeView.showsRouteButton = NO;
        //默认YES
        volumeView.showsVolumeSlider = NO;
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

- (HCFastForwardAndBackView *)fastForwardAndBackView
{
    if (_fastForwardAndBackView == nil) {
        HCFastForwardAndBackView *fastForwardAndBackView = [[HCFastForwardAndBackView alloc] init];
        [self.controllContentView addSubview:fastForwardAndBackView];
        _fastForwardAndBackView = fastForwardAndBackView;
        fastForwardAndBackView.delegate = self;
    }
    [self.controllContentView bringSubviewToFront:_fastForwardAndBackView];
    return _fastForwardAndBackView;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.zoomInWhenVerticalScreen = YES;
        [self setupNotification];
        [self setupBtnsShow];
        [self setupZoomInHiddenBtns];
        [self setupMorePanelBtnsShow];
        [self setBtnsZoomInHidden:YES];
        [self setupProperty];
        [self progressView];
        [self initSetAirPlay];
        [self setupSelfGesture];
        [BrightnessView sharedBrightnessView];
        
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    
    if (self.url) {
        self.urlPlayer.frame = self.contentView.bounds;
    }
    
    [self setupSelfSubviewsFrame];
}

- (void)dealloc
{
    [self stop];
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    VPLog(@"dealloc - HCVideoPlayer");
}

- (void)setupNotification
{
    //监听手动切换横竖屏状态
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // 网速监控
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkReceivedSpeed:) name:NotificationNetworkReceivedSpeed object:nil];
    
    // AirPlay 相关通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPVolumeViewWirelessRoutesAvailableDidChange) name:MPVolumeViewWirelessRoutesAvailableDidChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(MPVolumeViewWirelessRouteActiveDidChange) name:MPVolumeViewWirelessRouteActiveDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(outputDeviceChanged:)name:AVAudioSessionRouteChangeNotification object:[AVAudioSession sharedInstance]];
    
    //
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    //n
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSetTiming:) name:NotificationVideoPlayerDidSetTiming object:nil];
}

- (void)setupProperty
{
    _autoZoom = YES;
    _showBackWhileZoomIn = YES;
    _orgStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
    _orgStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
}

- (void)setupSelfSubviewsFrame {
    [self setupControllContentViewFrame];
    self.controllContentView.hidden = self.vp_width < MIN(kVP_ScreenWidth, kVP_ScreenHeight);
    self.messageLabel.hidden = self.controllContentView.hidden;
    self.bottomBar.hidden = self.controllContentView.hidden;
    self.botProgressView.frame = CGRectMake(0, self.vp_height - 2, self.vp_width, 2);
    self.botProgressView.hidden = !(self.vp_width < MIN(kVP_ScreenWidth, kVP_ScreenHeight));
    [self.contentView insertSubview:self.botProgressView aboveSubview:self.controllContentView];
}

- (void)setupControllContentViewFrame
{
    self.controllContentView.frame = self.bounds;
    
    CGFloat selfW = self.bounds.size.width;
    CGFloat selfH = self.bounds.size.height;
    
    self.barrageView.frame = CGRectMake(0, 20, selfW, self.barrageView.bounds.size.height);
    
    [self.loadErrorLabel sizeToFit];
    CGRect rect = self.loadErrorLabel.frame;
    rect.origin.x = (selfW - rect.size.width) * 0.5;
    rect.origin.y = (selfH - rect.size.height) * 0.5;
    self.loadErrorLabel.frame = rect;
    
    CGFloat totalHeight = self.activityIndicator.frame.size.height + 6 + self.loadSpeedLabel.font.lineHeight;
    rect = self.activityIndicator.frame;
    rect.origin.y = (selfH - totalHeight) * 0.5;
    rect.origin.x = (selfW - rect.size.width) * 0.5;
    self.activityIndicator.frame = rect;
    self.loadSpeedLabel.frame = CGRectMake(0, CGRectGetMaxY(self.activityIndicator.frame) + 6, self.controllContentView.frame.size.width, self.loadSpeedLabel.font.lineHeight);
    
    CGFloat width = 60;
    CGFloat height = 44;
    CGFloat x = 0;
    if (kVP_IS_FullScreen && self.zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        x = 44;
    }
    CGFloat y = (selfH - height) * 0.5;
    self.lockBtn.frame = CGRectMake(x, y, width, height);
    
    [self setupControllViewFrame];
    
    [self setupLockContentViewFrame];
    
    [self setupTVControllViewFrame];
    
    [self.controllContentView bringSubviewToFront:self.lockBtn];
    [self.controllContentView bringSubviewToFront:self.tvControllView];
    
    [self.contentView insertSubview:self.controllContentView aboveSubview:self.urlPlayer];
}

- (void)setupControllViewFrame
{
    // 1.顶部bar
    CGRect rect = self.bounds;
    // iphoneX 横屏去掉两侧安全区宽度
    if (kVP_IS_FullScreen && self.zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        rect.origin.x = 44;
        rect.size.width = rect.size.width - 44 * 2;
    }
    self.controllView.frame = rect;
    CGFloat controllViewW = self.controllView.bounds.size.width;
    CGFloat controllViewH = self.controllView.bounds.size.height;
    
    CGFloat kTopBarMargin = 20;
    // 1.1 backBtn
    if (self.zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        [self.topBar addSubview:self.backBtn];
        self.backBtn.frame = CGRectMake(0, kTopBarMargin, kHCVP_BtnWidth, 44);
    }
    else
    {
        self.backBtn.frame = CGRectMake(15, kTopBarMargin, 0, 44);
        if (_showBackWhileZoomIn) {
            [self.controllContentView addSubview:self.backBtn];
            self.backBtn.frame = CGRectMake(0, kTopBarMargin, kHCVP_BtnWidth, 44);
        }
    }
    
    CGFloat imageW = self.moreBtn.imageView.image.size.width;
    // 1.2 moreBtn
    UIView *view = nil;
    CGFloat width = (self.moreBtn.alpha && !self.moreBtn.hidden) ? kHCVP_BtnWidth : 0;
    CGFloat height = 44;
    CGFloat x = width ? (controllViewW - width - 20 + (width - imageW) * 0.5) : controllViewW;
    CGFloat y = kTopBarMargin;
    self.moreBtn.frame = CGRectMake(x, y, width, height);
    if (width) {
        view = self.moreBtn;
    }
    
    // 1.3 shareBtn
    imageW = self.shareBtn.imageView.image.size.width;
    width = (self.shareBtn.alpha && !self.shareBtn.hidden) ? kHCVP_BtnWidth : 0;
    x = width ? (controllViewW - width - 20 + (width - imageW) * 0.5) : controllViewW;
    x = (CGRectGetMinX(self.moreBtn.frame) == controllViewW) ? x : CGRectGetMinX(self.moreBtn.frame) - width;
    self.shareBtn.frame = CGRectMake(x, y, width, height);
    if (width) {
        view = self.shareBtn;
    }
    
    // 1.4 tvBtn
    imageW = self.tvBtn.imageView.image.size.width;
    width = (self.tvBtn.alpha && !self.tvBtn.hidden) ? kHCVP_BtnWidth : 0;
    x = width ? (controllViewW - width - 20 + (width - imageW) * 0.5) : controllViewW;
    x = (CGRectGetMinX(self.shareBtn.frame) == controllViewW) ? x : CGRectGetMinX(self.shareBtn.frame) - width;
    self.tvBtn.frame = CGRectMake(x, y, width, height);
    if (width) {
        view = self.tvBtn;
    }
    
    // 1.5 titleLabel
    if (view) {
        width = CGRectGetMinX(self.tvBtn.frame) - CGRectGetMaxX(self.backBtn.frame) + 5;
    }
    else {
        width = controllViewW - CGRectGetMaxX(self.backBtn.frame) - 10;
    }
    CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    height = size.height;
    x = CGRectGetMaxX(self.backBtn.frame) - 5;
    y = (self.backBtn.frame.size.height - height) * 0.5 + self.backBtn.frame.origin.y;
    self.titleLabel.frame = CGRectMake(x, y, width, height);
    
    // 1.6 topBar
    x = 0;
    y = 0;//self.zoomStatus == HCVideoPlayerZoomStatusZoomOut ? 20 : 15;
    width = controllViewW;
    height = MAX(66, MAX(CGRectGetMaxY(self.titleLabel.frame), CGRectGetMaxY(self.backBtn.frame)));
    self.topBar.frame = CGRectMake(x, y, width, height);
    
    // 顶部bar阴影
    width = MAX(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    x = (controllViewW - width) * 0.5;
    y = 0;
    self.topBarShadow.frame = CGRectMake(x, y, width, height);
    [self.topBar sendSubviewToBack:self.topBarShadow];
    
    
    // 2.底部bar
    [self setupBottomBarFrame];
    
    self.progressImageView.frame = self.contentView.bounds;
    
    // 3.rightSlide
    CGFloat rightSlideBtnH = 44;
    NSInteger showBtnCount = 0;
    if (self.cameraBtn.alpha && !self.cameraBtn.hidden) {
        showBtnCount += 1;
    }
    if (self.switchBtn.alpha && !self.switchBtn.hidden) {
        showBtnCount += 1;
    }
    CGFloat padding = 20;
    CGFloat totalH = showBtnCount * rightSlideBtnH + (showBtnCount - 1) * padding;
    CGFloat fristY = (controllViewH - totalH) * 0.5;
    
    // 3.1 cameraBtn
    imageW = self.cameraBtn.imageView.image.size.width;
    width = kHCVP_BtnWidth;
    height = (self.cameraBtn.alpha && !self.cameraBtn.hidden) ? rightSlideBtnH : 0;
    x = controllViewW - width - 20 + (width - imageW) * 0.5;
    y = fristY;
    self.cameraBtn.frame = CGRectMake(x, y, width, height);
    
    width = 68;
    height = [self.imageShareView heightToFit];
    x = CGRectGetMinX(self.cameraBtn.frame) - width - 10;
    y = CGRectGetMinY(self.cameraBtn.frame) + (CGRectGetHeight(self.cameraBtn.frame) - height) * 0.5;
    self.imageShareView.frame = CGRectMake(x, y, width, height);
    
    // 3.2 switchBtn
    imageW = self.switchBtn.imageView.image.size.width;
    width = kHCVP_BtnWidth;
    height = (self.switchBtn.alpha && !self.switchBtn.hidden) ? rightSlideBtnH : 0;
    x = controllViewW - width - 20 + (width - imageW) * 0.5;;
    y = CGRectGetMaxY(self.cameraBtn.frame) + ((CGRectGetMaxY(self.cameraBtn.frame) == fristY) ? 0 : padding);
    self.switchBtn.frame = CGRectMake(x, y, width, height);
}

- (void)setupBottomBarFrame
{
    // 2.1 bottomBar
    CGFloat botBarHeight = kHCVP_BottomBarHeight + (self.zoomStatus == HCVideoPlayerZoomStatusZoomOut ? (kVP_IS_FullScreen ? 15 : 0) : 0);
    
    CGRect rect = self.bounds;
    // iphoneX 横屏去掉两侧安全区宽度
    CGFloat x = 0;
    CGFloat width = rect.size.width;
    if (kVP_IS_FullScreen && self.zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        x = 44;
        width = rect.size.width - 44 * 2;
    }
    CGFloat height = botBarHeight;
    CGFloat y = self.contentView.vp_height - height;
    self.bottomBar.frame = CGRectMake(x, y, width, height);
    
    CGFloat barWidth = self.bottomBar.bounds.size.width;
    
    // 底部bar阴影
    width = MAX(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    x = (barWidth - width) * 0.5;
    y = 0;
    self.bottomShadow.frame = CGRectMake(x, y, width, height);
    [self.bottomBar sendSubviewToBack:self.bottomShadow];
    
    // 2.2 leftTimeLabel
    UILabel *label = [[UILabel alloc] init];
    label.font = self.leftTimeLabel.font;
    label.text = self.progressView.totalTime > 3600 ? @"00:00:00" : @"00:00";
    [label sizeToFit];
    x = 20;
    y = (50 - label.vp_height) * 0.5;
    width = label.vp_width + 2;
    height = label.vp_height;
    self.leftTimeLabel.frame = CGRectMake(x, y, width, height);
    
    // 2.3 rightTimeLabel
    x = barWidth - width - 20;
    self.rightTimeLabe.frame = CGRectMake(x, y, width, height);
    
    // 2.4 progressView
    x = CGRectGetMaxX(self.leftTimeLabel.frame) + 8;
    y = 0;
    height = 50;
    width = barWidth - 2 * x;
    self.progressView.frame = CGRectMake(x, y, width, height);
    
    // 2.2 playerBtn
    CGFloat imageW = self.playerBtn.imageView.image.size.width;
    width = kHCVP_BtnWidth;
    x = 20 - (width - imageW) * 0.5;
    y = CGRectGetMaxY(_progressView.frame);
    height = 22;
    self.playerBtn.frame = CGRectMake(x, y, width, height);
    
    // 2.3 nextBtn
    width = (self.nextBtn.alpha && !self.nextBtn.hidden) ? MAX(kHCVP_BtnWidth, self.nextBtn.bounds.size.width) : 0;
    x = CGRectGetMaxX(self.playerBtn.frame);
    self.nextBtn.frame = CGRectMake(x, y, width, height);
    
    // barrageBtn
    width = (self.barrageBtn.alpha) ? 42 : 0;
    x = CGRectGetMaxX(self.nextBtn.frame);
    self.barrageBtn.frame = CGRectMake(x, y, width, height);
    
    width = (self.barrageSelColorBtn.alpha) ? 42 : 0;
    x = CGRectGetMaxX(self.barrageBtn.frame);
    self.barrageSelColorBtn.frame = CGRectMake(x, y, width, height);
    
    // barrageSendBtn
    width = (self.barrageSendBtn.alpha) ? 150 : 0;
    x = CGRectGetMaxX(self.barrageSelColorBtn.frame) + 10;
    self.barrageSendBtn.frame = CGRectMake(x, y, width, height);
    
    // 2.4 zoomBtn
    self.zoomBtn.alpha = (self.zoomStatus == HCVideoPlayerZoomStatusZoomOut ? 0 : _showZoomBtn);
    imageW = self.zoomBtn.imageView.image.size.width;
    width = (self.zoomBtn.alpha) ? kHCVP_BtnWidth : 0;
    x = width ? (barWidth - width - 20 + (width - imageW) * 0.5) : barWidth - 20;
//    width = (self.zoomBtn.alpha && !self.zoomBtn.hidden) ? MAX(kHCVP_TextBtnWidth, self.zoomBtn.bounds.size.width) : 0;
//    x = controllViewW - width - 5;
    self.zoomBtn.frame = CGRectMake(x, y, width, height);
    self.zoomBtn.hidden = (self.zoomStatus == HCVideoPlayerZoomStatusZoomOut);
    
    // 2.5 fullShowBtn
    width = (self.fullShowBtn.alpha && !self.fullShowBtn.hidden) ? MAX(kHCVP_TextBtnWidth, self.fullShowBtn.bounds.size.width) : 0;
    x = (self.zoomBtn.alpha ? (CGRectGetMinX(self.zoomBtn.frame) - width) : (barWidth - width - 5));
    self.fullShowBtn.frame = CGRectMake(x, y, width, height);
    
    
    // 2.5 episodeBtn
    width = (self.episodeBtn.alpha && !self.episodeBtn.hidden) ? MAX(kHCVP_TextBtnWidth, self.episodeBtn.bounds.size.width) : 0;
    x = CGRectGetMinX(self.fullShowBtn.frame) - width;
    self.episodeBtn.frame = CGRectMake(x, y, width, height);
    
    [self setupTimeLabelFrame];
}

- (void)setupBottomBarFrame1
{
    CGFloat controllViewW = self.controllView.bounds.size.width;
    CGFloat controllViewH = self.controllView.bounds.size.height;
    
    // 2.1 bottomBar
    CGFloat botBarHeight = kHCVP_BottomBarHeight + (self.zoomStatus == HCVideoPlayerZoomStatusZoomOut ? kVP_iPhoneXSafeBottomHeight : 0);
    CGFloat x = 0;
    CGFloat width = controllViewW;
    CGFloat height = botBarHeight;
    CGFloat y = controllViewH - height;
    self.bottomBar.frame = CGRectMake(x, y, width, height);
    
    // 底部bar阴影
    width = MAX(CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    x = (controllViewW - width) * 0.5;
    y = 0;
    self.bottomShadow.frame = CGRectMake(x, y, width, height);
    [self.bottomBar sendSubviewToBack:self.bottomShadow];
    
    // 2.2 playerBtn
    CGFloat imageW = self.playerBtn.imageView.image.size.width;
    width = kHCVP_BtnWidth;
    x = 20 - (width - imageW) * 0.5;
    y = 0;
    height = botBarHeight;
    self.playerBtn.frame = CGRectMake(x, y, width, height);
    
    // 2.3 nextBtn
    width = (self.nextBtn.alpha && !self.nextBtn.hidden) ? MAX(kHCVP_BtnWidth, self.nextBtn.bounds.size.width) : 0;
    height = botBarHeight;
    x = CGRectGetMaxX(self.playerBtn.frame);
    y = 0;
    self.nextBtn.frame = CGRectMake(x, y, width, height);
    
    // barrageBtn
    width = (self.barrageBtn.alpha) ? 42 : 0;
    height = botBarHeight;
    x = CGRectGetMaxX(self.nextBtn.frame);
    y = 0;
    self.barrageBtn.frame = CGRectMake(x, y, width, height);
    
    width = (self.barrageSelColorBtn.alpha) ? 42 : 0;
    height = botBarHeight;
    x = CGRectGetMaxX(self.barrageBtn.frame);
    y = 0;
    self.barrageSelColorBtn.frame = CGRectMake(x, y, width, height);
    
    // barrageSendBtn
    width = (self.barrageSendBtn.alpha) ? 100 : 0;
    height = 22;
    x = CGRectGetMaxX(self.barrageSelColorBtn.frame) + 10;
    y = (botBarHeight - height) * 0.5;
    self.barrageSendBtn.frame = CGRectMake(x, y, width, height);
    
    // 2.4 zoomBtn
    imageW = self.zoomBtn.imageView.image.size.width;
    width = (self.zoomBtn.alpha) ? kHCVP_BtnWidth : 0;
    height = botBarHeight;
    x = width ? (controllViewW - width - 20 + (width - imageW) * 0.5) : controllViewW - 20;
    y = 0;
    self.zoomBtn.frame = CGRectMake(x, y, width, height);
    
    // 2.5 episodeBtn
    width = (self.episodeBtn.alpha && !self.episodeBtn.hidden) ? MAX(kHCVP_BtnWidth, self.episodeBtn.bounds.size.width) : 0;
    height = botBarHeight;
    x = CGRectGetMinX(self.zoomBtn.frame) - width;
    y = 0;
    self.episodeBtn.frame = CGRectMake(x, y, width, height);
    
    // 2.6 progressView
    x = CGRectGetMaxX(self.barrageSendBtn.frame) + ((self.barrageSendBtn.alpha) ? 20 : 0);
    y = 0;
    height = botBarHeight;
    width = CGRectGetMinX(self.episodeBtn.frame) - x - (self.episodeBtn.alpha ? 5 : 0);
    self.progressView.frame = CGRectMake(x, y, width, height);
    
    [self setupTimeLabelFrame];
}

- (void)setupTimeLabelFrame
{
    CGSize size = [self.timeLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGFloat x = CGRectGetMaxX(self.progressView.frame) - size.width;
    CGFloat y = CGRectGetMaxY(self.progressView.frame) - self.progressView.frame.size.height * 0.5 + 5;
    CGFloat width = size.width;
    CGFloat height = size.height;
    self.timeLabel.frame = CGRectMake(x, y, width, height);
}

- (void)setupLockContentViewFrame
{
    // 1.顶部bar
    CGRect rect = self.bounds;
    // iphoneX 横屏去掉两侧安全区宽度
//    if (kVP_IS_IPHONE_X && self.zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
//        rect.origin.x = 44;
//        rect.size.width = rect.size.width - 44 * 2;
//    }
    self.lockContentView.frame = rect;
    CGFloat lockContentViewW = self.lockContentView.bounds.size.width;
    CGFloat lockContentViewH = self.lockContentView.bounds.size.height;
    
    // 1. lockTopBar
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = lockContentViewW;
    CGFloat height = 66;
    self.lockTopBar.frame = CGRectMake(x, y, width, height);
    
    // 2. lockBottomBar
    CGFloat botBarHeight = kHCVP_BottomBarHeight + (self.zoomStatus == HCVideoPlayerZoomStatusZoomOut ? kVP_iPhoneXSafeBottomHeight : 0);
    x = 0;
    width = lockContentViewW;
    height = botBarHeight;
    y = lockContentViewH - height;
    self.lockBottomBar.frame = CGRectMake(x, y, width, height);
}

- (void)setupTVControllViewFrame
{
    CGRect rect = self.bounds;
    // iphoneX 横屏去掉两侧安全区宽度
    if (kVP_IS_FullScreen && self.zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        rect.origin.x = 44;
        rect.size.width = rect.size.width - 44 * 2;
    }
    self.tvControllView.frame = rect;
}

- (void)setupBtnsShow
{
    self.showZoomBtn = YES;
    self.showMoreBtn = YES;
    self.showShareBtn = YES;
    self.showTvBtn = YES;
    self.showCameraBtn = YES;
    self.showEpisodeBtn = YES;
    self.showNextBtn = YES;
    self.showSwitchBtn = NO;
    self.showBarrageSendBtn = _isBarrageOpen;
    self.showBarrageSelColorBtn = NO;
}

- (void)setupZoomInHiddenBtns
{
    _zoomInHiddenMoreBtn = YES;
    _zoomInHiddenShareBtn = NO;
    _zoomInHiddenTvBtn = NO;
    _zoomInHiddenCameraBtn = YES;
    _zoomInHiddenNextBtn = NO;
    _zoomInHiddenEpisodeBtn = YES;
    _zoomInHiddenFullShowBtn = YES;
    _zoomInHiddenSwitchBtn = NO;
    _zoomInHiddenLockBtn = YES;
}

- (void)setupMorePanelBtnsShow
{
    _enableDlBtn = YES;
    _enableStBtn = YES;
    _enableAddToMyDefWBBtn = YES;
}

#pragma mark - 重写
- (void)playWithUrl:(NSURL *)url forceReload:(BOOL)forceReload readyComplete:(HCVideoPlayerReadyComplete)readyComplete
{
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground && ![HCAirplayCastTool isAirPlayOnCast]) {
        return;
    }
    
    self.loadErrorLabel.hidden = YES;
    [self setControllViewHidden:YES];
//    if (self.zoomBtn.selected == YES && !_noZoomInShowModel) { // 防止点放大点快了旋转时点到下面一层
//        [[UIView vp_KeyWindow] addSubview:self];
//        self.frame = [UIView vp_KeyWindow].bounds;
//        return;
//    }
    if (![_url.absoluteString isEqualToString:url.absoluteString]) {
        [self stop];
    }
    _url = url;
    // 投屏url排除本地视频
    self.progressView.hiddenLoadProgress = YES;
    if (![_url.absoluteString containsString:@"localhost:"] && ![_url.absoluteString containsString:@"127.0.0.1"]) {
        _castUrl = _url;
        self.progressView.hiddenLoadProgress = NO;
    }
    if (!_url) {
        _url = [NSURL URLWithString:@""];
    }
    
    self.progressImageView.playUrl = (_castUrl ? _castUrl.absoluteString : _url.absoluteString);
    
    @autoreleasepool {
        __weak typeof(self) weakSelf = self;
        [self layoutSubviews];
        if (forceReload || (_urlPlayer.playerState != HCPlayerViewStatePlay && _urlPlayer.playerState != HCPlayerViewStatePause)) {
            [self stop];
            self.playerBtn.selected = NO;
            [self.contentView addSubview:self.urlPlayer];
            self.urlPlayer.volume = _volume;
            
            // 设置全屏或不全屏显示
            BOOL fullScreenShow = [[NSUserDefaults standardUserDefaults] boolForKey:VPFullScreenShow];
            _urlPlayer.displayMode = (fullScreenShow ? HCPlayerViewDisplayModeScaleAspectFill : HCPlayerViewDisplayModeScaleAspectFit);
            
            NSURL *url = [HCAirplayCastTool isAirPlayOnCast] ? _castUrl : _url;
            [self.urlPlayer readyWithUrl:url complete:^(HCPlayerViewState status) {
                if (readyComplete) {
                    readyComplete(weakSelf, [weakSelf status]);
                }
                weakSelf.urlPlayer.rate = weakSelf.rate;
                if (weakSelf.isManualStopOrPausePlay || weakSelf.isInBackground) {
                    [weakSelf.urlPlayer pause];
                }
            }];
            [self showLoading];
        }
        else
        {
            self.playerBtn.selected = YES;
            [self play];
            if (readyComplete) {
                readyComplete(weakSelf, [weakSelf status]);
            }
        }
        
        [self.contentView insertSubview:self.controllContentView aboveSubview:self.urlPlayer];
        [self.contentView insertSubview:self.botProgressView aboveSubview:self.controllContentView];
    }
}

- (void)stop
{
    [super stop];
    self.loadSpeedLabel.text = @"0.0KB/s";
    [self hiddenLoading];
    [self setControllViewHidden:YES];
    self.progressView.playTime = 0;
    self.progressView.loadTime = 0;
    self.progressView.totalTime = 0;
    
    self.botProgressView.playTime = 0;
    self.botProgressView.loadTime = 0;
    self.botProgressView.totalTime = 0;
}

- (void)seekToTime:(NSTimeInterval)time autoPlay:(BOOL)autoPlay complete:(void (^)(BOOL finished))complete
{
    autoPlay = !_isInBackground ? autoPlay : NO;
    [self.urlPlayer seekToTime:time autoPlay:autoPlay complete:^(BOOL finished) {
        if (finished) {
            self.progressView.playTime = time;
            self.botProgressView.playTime = time;
            [self setupAirPlayTVControllViewProgressWithPlayTime:time];
        }
        if (complete) {
            complete(finished);
        }
    }];
}

- (void)playAfterShowOtherView
{
    [self playAfterShow];
}

- (void)addSubViewToControllContentViewBottom:(UIView *)view
{
    [self.controllContentView addSubview:view];
    [self.controllContentView sendSubviewToBack:view];
}

#pragma mark - 外部方法
+ (instancetype)showWithUrl:(NSURL *)url curController:(UIViewController *)curController showComplete:(void (^)(void))showComplete
{
    return [self showWithUrl:url curController:curController autoPlay:YES showComplete:showComplete readyComplete:^(HCVideoPlayer *videoPlayer, HCVideoPlayerStatus status) {
        [videoPlayer play];
    }];
}

+ (instancetype)showWithUrl:(NSURL *)url curController:(UIViewController *)curController autoPlay:(BOOL)autoPlay showComplete:(void (^)(void))showComplete readyComplete:(HCVideoPlayerReadyComplete)readyComplete
{
    if (![url isKindOfClass:[NSURL class]]) {
        return nil;
    }
    HCVideoPlayer *videoPlayer = [[self alloc] initWithCurController:curController];
    [[UIView vp_rootWindow] addSubview:videoPlayer];
    videoPlayer.readyComplete = readyComplete;
    videoPlayer.url = url;
    
    videoPlayer.zoomInWhenVerticalScreen = NO;
    videoPlayer.noZoomInShowModel = YES;
    
    // 放大显示一些按钮比如更多按钮
    [videoPlayer setBtnsZoomInHidden:NO];
    // 放大设置屏幕可转
    [UIResponder setAllowRotation:YES forRootPresentVc:videoPlayer.rootPresentVc];
    
    videoPlayer.zoomStatus = HCVideoPlayerZoomStatusZoomOut;
    [videoPlayer setupControllContentViewPanGesture];
    
    if (videoPlayer.deviceOrientation != UIDeviceOrientationLandscapeLeft && videoPlayer.deviceOrientation != UIDeviceOrientationLandscapeRight) {
        [UIResponder setPortraitOrientation];
        videoPlayer.deviceOrientation = UIDeviceOrientationLandscapeLeft;
    }
    
    CGFloat angle = ((videoPlayer.deviceOrientation == UIDeviceOrientationLandscapeRight) ? -M_PI_2 : M_PI_2);
    videoPlayer.transform = CGAffineTransformMakeRotation(angle);
    videoPlayer.frame = [UIScreen mainScreen].bounds;
    CGRect rect = videoPlayer.frame;
    rect.origin.x = -kVP_ScreenWidth;
    videoPlayer.frame = rect;
    videoPlayer.isOnRotaion = YES;
    videoPlayer.isShowing = YES;
    [UIView animateWithDuration:kVP_AniDuration animations:^{
        CGRect rect = videoPlayer.frame;
        rect.origin.x = 0;
        videoPlayer.frame = rect;
    } completion:^(BOOL finished) {
        if (autoPlay) {
            [videoPlayer playAfterShow];
        }
        videoPlayer.zoomBtn.selected = YES;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [UIApplication sharedApplication].statusBarHidden = videoPlayer.controllView.hidden;
        videoPlayer.statusBar.alpha = videoPlayer.controllView.hidden ? 0 : 1;
        HCOrientController *orVC = [[HCOrientController alloc] init];
        videoPlayer.orVC = orVC;
        orVC.delegate = videoPlayer;
        orVC.orientation = (videoPlayer.deviceOrientation == UIDeviceOrientationLandscapeRight ?UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationLandscapeRight);
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:orVC];
        UITabBarController *tabVc = [[UITabBarController alloc] init];
        [tabVc addChildViewController:nvc];
        
        tabVc.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [videoPlayer.rootPresentVc presentViewController:tabVc animated:NO completion:^{
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [UIApplication sharedApplication].statusBarHidden = videoPlayer.controllView.hidden;
            videoPlayer.statusBar.alpha = videoPlayer.controllView.hidden ? 0 : 1;
            [UIResponder setOrientation:orVC.orientation];// 设置一致方向
        }];
        
        videoPlayer.transform = CGAffineTransformIdentity;
        videoPlayer.frame = [UIScreen mainScreen].bounds;
        videoPlayer.isOnRotaion = NO;
        
        if (showComplete) {
            showComplete();
        }
    }];
    return videoPlayer;
}

+ (instancetype)showWithZoomType:(HCVideoPlayerZoomType)zoomType curController:(UIViewController *)curController showComplete:(void (^)(void))showComplete
{
    HCVideoPlayer *vp = [self showWithVideoPlayer:nil zoomType:zoomType curController:curController showComplete:showComplete];
    return vp;
}

+ (instancetype)showWithVideoPlayer:(HCVideoPlayer *)videoPlayer zoomType:(HCVideoPlayerZoomType)zoomType curController:(UIViewController *)curController showComplete:(void (^)(void))showComplete {
    
    HCVideoPlayer *vp = nil;
    if (zoomType == HCVideoPlayerZoomTypeRotation) {
        vp = [self rotation_showWithVideoPlayer:videoPlayer curController:curController showComplete:showComplete];
    }
    else {
        vp = [self scale_showWithVideoPlayer:videoPlayer curController:curController showComplete:showComplete];
    }
    vp.zoomType = zoomType;
    return vp;
}

/** 配合+showWithUrl:类方法使用 */
- (void)hiddenSelf
{
    if (_zoomType == HCVideoPlayerZoomTypeRotation) {
        [self rotation_hiddenSelf];
    }
    else {
        [self scale_hiddenSelf];
    }
}

- (void)playAfterShow
{
    __weak typeof(self) weakSelf = self;
    if ([_url.absoluteString containsString:@"localhost"] || [_url.absoluteString containsString:@"127.0.0.1"]) { // 本地不用延迟，没有p2p
        [self playWithUrl:_url readyComplete:_readyComplete];
    }
    else { // p2p 延迟解决加载概率出现失败
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf playWithUrl:weakSelf.url readyComplete:weakSelf.readyComplete];
        });
    }
}

- (void)joint_playWithUrl:(NSURL *)url complete:(void(^)(BOOL isJointSuccess))complete
{
    if (_jointPlayerView) {
        return;
    }
    HCPlayerView *newPlayView = [[HCPlayerView alloc] init];
    newPlayView.hidden = YES;
    newPlayView.volume = 0;
    newPlayView.frame = self.urlPlayer.frame;
//    [self.urlPlayer.superview addSubview:newPlayView];
    [self.urlPlayer.superview insertSubview:newPlayView belowSubview:self.urlPlayer];
    _jointPlayerView = self.urlPlayer;
    
    __weak typeof(newPlayView) weakNewPlayView = newPlayView;
    __weak typeof(self) weakSelf = self;
    [newPlayView readyWithUrl:url complete:^(HCPlayerViewState status) {
        if (HCPlayerViewStateReadyed == status) {
            if (weakSelf.isLive) {
                [weakSelf play];
                weakNewPlayView.hidden = NO;
                weakNewPlayView.delegate = weakSelf;
                weakNewPlayView.volume = weakSelf.jointPlayerView.volume;
                [weakSelf setupUrlPlayer:weakNewPlayView];
                [weakNewPlayView.superview sendSubviewToBack:weakNewPlayView];
                weakSelf.progressView.totalTime = weakNewPlayView.totalTime;
                weakSelf.progressView.playTime = weakNewPlayView.currentTime;
                weakSelf.botProgressView.totalTime = weakNewPlayView.totalTime;
                weakSelf.botProgressView.playTime = weakNewPlayView.currentTime;
                
                weakSelf.jointPlayerView.hidden = YES;
                weakSelf.jointPlayerView.delegate = nil;
                weakSelf.jointPlayerView.volume = 0;
                [weakSelf.jointPlayerView stop];
                [weakSelf.jointPlayerView removeFromSuperview];
                weakSelf.jointPlayerView = nil;
                if (complete) {
                    complete(YES);
                }
            }
            else {
                [weakNewPlayView seekToTime:weakSelf.jointPlayerView.currentTime autoPlay:YES complete:^(BOOL finished) {
                    weakNewPlayView.hidden = NO;
                    weakNewPlayView.delegate = weakSelf;
                    weakNewPlayView.volume = weakSelf.jointPlayerView.volume;
                    [weakSelf setupUrlPlayer:weakNewPlayView];
                    [weakNewPlayView.superview sendSubviewToBack:weakNewPlayView];
                    weakSelf.progressView.totalTime = weakNewPlayView.totalTime;
                    weakSelf.progressView.playTime = weakNewPlayView.currentTime;
                    weakSelf.botProgressView.totalTime = weakNewPlayView.totalTime;
                    weakSelf.botProgressView.playTime = weakNewPlayView.currentTime;
                    
                    weakSelf.jointPlayerView.hidden = YES;
                    weakSelf.jointPlayerView.delegate = nil;
                    weakSelf.jointPlayerView.volume = 0;
                    [weakSelf.jointPlayerView stop];
                    [weakSelf.jointPlayerView removeFromSuperview];
                    weakSelf.jointPlayerView = nil;
                    if (complete) {
                        complete(YES);
                    }
                }];
            }
        }
        else if (HCPlayerViewStateError == status) {
            if (complete) {
                complete(NO);
            }
        }
    }];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    self.titleLabel.font = _titleFont;
}

- (void)setBarrageView:(UIView *)barrageView
{
    if (barrageView != nil && ![barrageView isKindOfClass:[UIView class]]) {
        return;
    }
    
    [_barrageView removeFromSuperview];
    _barrageView = barrageView;
    if ([_barrageView isKindOfClass:[UIView class]]) {
        [self.controllContentView addSubview:_barrageView];
    }
    [self.controllContentView sendSubviewToBack:_barrageView];
}

- (void)setShowMoreBtn:(BOOL)showMoreBtn
{
    _showMoreBtn = showMoreBtn;
    self.moreBtn.alpha = _showMoreBtn;
}

- (void)setShowShareBtn:(BOOL)showShareBtn
{
    _showShareBtn  = showShareBtn;
    self.shareBtn.alpha = _showShareBtn;
}

- (void)setShowTvBtn:(BOOL)showTvBtn
{
    _showTvBtn = showTvBtn;
    self.tvBtn.alpha = _showTvBtn;
}

- (void)setShowCameraBtn:(BOOL)showCameraBtn
{
    _showCameraBtn = showCameraBtn;
    self.cameraBtn.alpha = _showCameraBtn;
}

- (void)setShowNextBtn:(BOOL)showNextBtn
{
    _showNextBtn = showNextBtn;
    self.nextBtn.alpha = _showNextBtn;
}

- (void)setShowBarrageBtn:(BOOL)showBarrageBtn
{
    _showBarrageBtn = showBarrageBtn;
    self.barrageBtn.alpha = _showBarrageBtn;
    [self setupBottomBarFrame];
}

- (void)setShowBarrageSelColorBtn:(BOOL)showBarrageSelColorBtn
{
    _showBarrageSelColorBtn = showBarrageSelColorBtn;
    self.barrageSelColorBtn.alpha = _showBarrageSelColorBtn;
    [self setupBottomBarFrame];
}

- (void)setShowBarrageSendBtn:(BOOL)showBarrageSendBtn
{
    _showBarrageSendBtn = showBarrageSendBtn;
    self.barrageSendBtn.alpha = _showBarrageSendBtn;
    [self setupBottomBarFrame];
}

- (void)setShowEpisodeBtn:(BOOL)showEpisodeBtn
{
    _showEpisodeBtn = showEpisodeBtn;
    self.episodeBtn.alpha = _showEpisodeBtn;
}

- (void)setShowFullShowBtn:(BOOL)showFullShowBtn
{
    _showFullShowBtn = showFullShowBtn;
    self.fullShowBtn.alpha = _showFullShowBtn;
}

- (void)setShowSwitchBtn:(BOOL)showSwitchBtn
{
    _showSwitchBtn = showSwitchBtn;
    self.switchBtn.alpha = _showSwitchBtn;
    [self setupSelfSubviewsFrame];
}

- (void)setShowLockBtn:(BOOL)showLockBtn
{
    _showLockBtn = showLockBtn;
    self.lockBtn.alpha = _showLockBtn;
}

- (void)setShowZoomBtn:(BOOL)showZoomBtn
{
    _showZoomBtn = showZoomBtn;
    self.zoomBtn.alpha = _showZoomBtn;
}

- (void)setZoomInHiddenMoreBtn:(BOOL)zoomInHiddenMoreBtn
{
    _zoomInHiddenMoreBtn = zoomInHiddenMoreBtn;
    [self setBtnsZoomInHidden:(self.zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)setZoomInHiddenShareBtn:(BOOL)zoomInHiddenShareBtn
{
    _zoomInHiddenShareBtn = zoomInHiddenShareBtn;
    [self setBtnsZoomInHidden:(self.zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)setZoomInHiddenTvBtn:(BOOL)zoomInHiddenTvBtn
{
    _zoomInHiddenTvBtn = zoomInHiddenTvBtn;
    [self setBtnsZoomInHidden:(self.zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)setZoomInHiddenCameraBtn:(BOOL)zoomInHiddenCameraBtn
{
    _zoomInHiddenCameraBtn = zoomInHiddenCameraBtn;
    [self setBtnsZoomInHidden:(self.zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)setZoomInHiddenNextBtn:(BOOL)zoomInHiddenNextBtn
{
    _zoomInHiddenNextBtn = zoomInHiddenNextBtn;
    [self setBtnsZoomInHidden:(self.zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)setZoomInHiddenEpisodeBtn:(BOOL)zoomInHiddenEpisodeBtn
{
    _zoomInHiddenEpisodeBtn = zoomInHiddenEpisodeBtn;
    [self setBtnsZoomInHidden:(self.zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)setZoomInHiddenFullShowBtn:(BOOL)zoomInHiddenFullShowBtn
{
    _zoomInHiddenFullShowBtn = zoomInHiddenFullShowBtn;
    [self setBtnsZoomInHidden:(self.zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)setZoomInHiddenSwitchBtn:(BOOL)zoomInHiddenSwitchBtn
{
    _zoomInHiddenSwitchBtn = zoomInHiddenSwitchBtn;
    [self setBtnsZoomInHidden:(self.zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)setZoomInHiddenLockBtn:(BOOL)zoomInHiddenLockBtn
{
    _zoomInHiddenLockBtn = zoomInHiddenLockBtn;
    [self setBtnsZoomInHidden:(self.zoomStatus == HCVideoPlayerZoomStatusZoomIn)];
}

- (void)showMsg:(NSString *)msg stopPlay:(BOOL)stopPlay autoHidden:(BOOL)autoHidden
{
    [self showMsg:msg stopPlay:stopPlay autoHidden:autoHidden duration:2];
}

- (void)showMsg:(NSString *)msg stopPlay:(BOOL)stopPlay autoHidden:(BOOL)autoHidden duration:(CGFloat)duration
{
    if (self.vp_width < MIN(kVP_ScreenWidth, kVP_ScreenHeight)) {
        return;
    }
    
    if (![msg isKindOfClass:[NSString class]]) {
        msg = @"";
    }
    if (stopPlay) {
        if (self.status == HCPlayerViewStatePlay || self.status == HCPlayerViewStatePause) {
            [self pause];
        }
        else
        {
            [self stop];
        }
        self.playerBtn.selected = NO;
        self.isManualStopOrPausePlay = YES;
    }
    
    CGSize selfSize = self.frame.size;
    self.messageLabel.text = msg;
    CGSize size = [self.messageLabel sizeThatFits:CGSizeMake(selfSize.width - 30, CGFLOAT_MAX)];
    CGFloat width = size.width + 6;
    CGFloat height = size.height + 6;
    CGFloat y = CGRectEqualToRect(self.loadSpeedLabel.frame, CGRectZero) ? (selfSize.height - height) * 0.5 : CGRectGetMaxY(self.loadSpeedLabel.frame) + 10;
    CGFloat x = (selfSize.width - width) * 0.5;
    self.messageLabel.frame = CGRectMake(x, y, width, height);
    self.messageLabel.hidden = NO;
    self.messageLabel.alpha = 1.0;
    [self insertSubview:self.messageLabel aboveSubview:self.contentView];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (autoHidden) {
            [UIView animateWithDuration:kVP_AniDuration animations:^{
                self.messageLabel.alpha = 0.0;
            } completion:^(BOOL finished) {
                self.messageLabel.hidden = YES;
            }];
        }
    });
}

- (void)hiddenMsgAnimation:(BOOL)animation
{
    if (animation) {
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            self.messageLabel.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.messageLabel.hidden = YES;
        }];
    }
    else
    {
        self.messageLabel.hidden = YES;
    }
}

- (void)setIsLive:(BOOL)isLive
{
    _isLive = isLive;
    self.playerBtn.hidden = _isLive;
    self.nextBtn.hidden = _isLive;
    self.progressView.hidden = _isLive;
    self.leftTimeLabel.hidden = _isLive;
    self.rightTimeLabe.hidden = _isLive;
    self.episodeBtn.hidden = _isLive;
    self.timeLabel.hidden = _isLive;
    self.moreBtn.hidden = _isLive;
    [self setupControllViewFrame];
}

- (void)setIsBarrageOpen:(BOOL)isBarrageOpen
{
    _isBarrageOpen = isBarrageOpen;
    self.barrageBtn.selected = _isBarrageOpen;
}

- (void)stopAndExitFullScreen
{
    [super stopAndExitFullScreen];
    [_orVC dismissViewControllerAnimated:NO completion:^{
    }];
    if (self.zoomType == HCVideoPlayerZoomTypeRotation) {
        [UIResponder setPortraitOrientation];
    }
    [UIResponder setAllowRotation:NO forRootPresentVc:nil];
}

- (void)makeZoomIn
{
    if (self.zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        [self zoomBtnClicked:self.zoomBtn];
    }
    [super makeZoomIn];
}

- (void)makeZoom
{
    [self zoomBtnClicked:self.zoomBtn];
    [super makeZoom];
}

- (void)becomeGoogleCastListener
{
    [HCGoogleCastTool addSessionManagerListener:self];
}

- (void)setCollectStatus:(BOOL)collectStatus
{
    _collectStatus = collectStatus;
    _morePanel.collectStatus = _collectStatus;
}

- (BOOL)isOnCast
{
    return !self.tvControllView.hidden;
}

+ (BOOL)isOnAirPlayCast
{
    return g_airPlayVideoPlayer;
}

#pragma mark - HCPlayerViewDelegate
- (void)playerView:(HCPlayerView *)playerView vedioSize:(CGSize)vedioSize
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
    });
}

- (void)playerView:(HCPlayerView *)playerView totalTime:(NSTimeInterval)totalTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString] || [playerView.url.absoluteString isEqualToString:self.castUrl.absoluteString]) {
            self.progressView.totalTime = totalTime;
            self.botProgressView.totalTime = totalTime;
            _totalTime = totalTime;
        }
        else
        {
            self.progressView.totalTime = 0;
            self.botProgressView.totalTime = 0;
            _totalTime = 0;
        }
        [self onGetTotalTime:_totalTime];
        [self setupBottomBarFrame];
        self.progressImageView.totalSec = totalTime;
    });
}

- (void)playerView:(HCPlayerView *)playerView loadTime:(NSTimeInterval)loadTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString] || [playerView.url.absoluteString isEqualToString:self.castUrl.absoluteString]) {
            self.progressView.loadTime = loadTime;
            self.botProgressView.loadTime = loadTime;
            [self showOrHiddenLoading];
        }
        else
        {
            self.progressView.loadTime = 0;
            self.botProgressView.loadTime = 0;
        }
    });
}

- (void)playerView:(HCPlayerView *)playerView playTime:(NSTimeInterval)playTime
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _lastPanContentViewTime = playTime;
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString] || [playerView.url.absoluteString isEqualToString:self.castUrl.absoluteString]) {
            
            if (fabs(playTime - self.progressView.playTime) <= 10) { // 避免手动改变进度进度条会返回的情况
                self.progressView.playTime = playTime;
                self.botProgressView.playTime = playTime;
                [self showOrHiddenLoading];
            }
            self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", [NSString vp_formateStringFromSec:playTime], [NSString vp_formateStringFromSec:self.progressView.totalTime]];
            self.leftTimeLabel.text = [NSString vp_formateStringFromSec:playTime forceShowHour:self.progressView.totalTime > 3600];
            self.rightTimeLabe.text = [NSString vp_formateStringFromSec:self.progressView.totalTime];
            
            if ([self.delegate respondsToSelector:@selector(videoPlayer:playTime:)]) {
                [self.delegate videoPlayer:self playTime:playTime];
            }
        }
        else
        {
            self.progressView.playTime = 0;
            self.botProgressView.playTime = 0;
            self.timeLabel.text = @"00:00 / 00:00";
        }
        [self setupTimeLabelFrame];
        [self onGetPlayTime:self.progressView.playTime];
        
        [self setupAirPlayTVControllViewProgressWithPlayTime:playTime];
    });
}

- (void)startReadyPlayForPlayerView:(HCPlayerView *)playerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
    });
}

- (void)didReadyForPlayForPlayerView:(HCPlayerView *)playerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString] || [playerView.url.absoluteString isEqualToString:self.castUrl.absoluteString]) {
            self.playerBtn.selected = NO;
        }
    });
}

- (void)didStartPlayForPlayerView:(HCPlayerView *)playerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString] || [playerView.url.absoluteString isEqualToString:self.castUrl.absoluteString]) {
            self.playerBtn.selected = YES;
        }
        
        if ([self.delegate respondsToSelector:@selector(didStartPlayForVideoPlayer:)]) {
            [self.delegate didStartPlayForVideoPlayer:self];
        }
    });
}

- (void)didContinuePlayForPlayerView:(HCPlayerView *)playerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString] || [playerView.url.absoluteString isEqualToString:self.castUrl.absoluteString]) {
            self.playerBtn.selected = YES;
        }
        
        if ([self.delegate respondsToSelector:@selector(didContinuePlayForVideoPlayer:)]) {
            [self.delegate didContinuePlayForVideoPlayer:self];
        }
        [self hiddenPicAd];
    });
}

- (void)didPausePlayForPlayerView:(HCPlayerView *)playerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString] || [playerView.url.absoluteString isEqualToString:self.castUrl.absoluteString]) {
            self.playerBtn.selected = NO;
        }
        if ([self.delegate respondsToSelector:@selector(didPausePlayForVideoPlayer:)]) {
            [self.delegate didPausePlayForVideoPlayer:self];
        }
        [self showPicAd];
    });
}

- (void)didStopPlayForPlayerView:(HCPlayerView *)playerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString] || [playerView.url.absoluteString isEqualToString:self.castUrl.absoluteString]) {
            self.playerBtn.selected = NO;
            self.progressView.loadProgress = 1.0;
        }
        
        if ([self.delegate respondsToSelector:@selector(didStopPlayForVideoPlayer:)]) {
            [self.delegate didStopPlayForVideoPlayer:self];
        }
    });
}

- (void)didPlaybackForPlayerView:(HCPlayerView *)playerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        __weak typeof(self) weakSelf = self;
        if ([playerView.url.absoluteString isEqualToString:self.url.absoluteString] || [playerView.url.absoluteString isEqualToString:self.castUrl.absoluteString]) {
            self.playerBtn.selected = NO;
            self.progressView.playProgress = 0.0;
            if (self.zoomStatus == HCVideoPlayerZoomStatusZoomOut && !_isOnRotaion && !_noZoomInShowModel) {
                [self zoomBtnClicked:self.zoomBtn duration:kVP_rotaionAniDuration complete:^(HCVideoPlayerZoomStatus zoomStatus) {
                    [weakSelf setupControllContentViewPanGesture];
                    if ([weakSelf.delegate respondsToSelector:@selector(didPlaybackForVideoPlayer:)]) {
                        [weakSelf.delegate didPlaybackForVideoPlayer:weakSelf];
                    }
                }];
            }
            else
            {
                if ([self.delegate respondsToSelector:@selector(didPlaybackForVideoPlayer:)]) {
                    [self.delegate didPlaybackForVideoPlayer:self];
                }
            }
        }
    });
}

- (void)didLoadErrorForPlayerView:(HCPlayerView *)playerView
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showLoadError];
    });
}

#pragma mark - HCProgressViewDelegate
- (void)progressView:(HCProgressView *)progressView didChangedSliderValue:(double)sliderValue time:(NSTimeInterval)ftime;
{
    [self startHiddenControllViewTime];
    // 进度图显示
    [self.progressImageView showWithCurSec:ftime];
}

- (void)progressView:(HCProgressView *)progressView didSliderUpAtValue:(CGFloat)value time:(CGFloat)time
{
    @autoreleasepool {
        if (self.url)
        {
//            VPLog(@"seekTime == %f", time);
            [_urlPlayer seekToTime:time autoPlay:YES complete:^(BOOL finished) {
                if (finished) {
                    self.progressView.loadTime = time;
                    self.botProgressView.loadTime = time;
                    if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeProgress:)]) {
                        [self.delegate videoPlayer:self didChangeProgress:time];
                    }
                }
            }];
            [self showLoading];
        }
    }
    if (self.progressImageView.hidden) {
        [self.progressImageView showWithCurSec:time];
    }
    [self.progressImageView hiddenSelf];
}

#pragma mark - HCOrientControllerDelegate
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _isOnRotaion = YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    _isOnRotaion = YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    _isOnRotaion = NO;
}

#pragma mark - HCSelectTvDevControllerDelegate
- (void)selectTvDevController:(HCSelectTvDevController *)selectTvDevController didSelectDlnaDev:(CLUPnPDevice *)dlnaDev
{
    self.tvControllView.style = HCTVControllViewStyleDlna;
    [self showTvControllView];
    [self.controllContentView bringSubviewToFront:self.tvControllView];
    HCTVDeviceItem *deviceItem = [[HCTVDeviceItem alloc] init];
    deviceItem.videoUrl = self.castUrl.absoluteString;
    deviceItem.dlnaDev = dlnaDev;
    deviceItem.seekTime = self.progressView.playTime;
    self.tvControllView.deviceItem = deviceItem;
}

- (void)selectTvDevController:(HCSelectTvDevController *)selectTvDevController didSelectSamsungDev:(id)samsungDev
{
    self.tvControllView.style = HCTVControllViewStyleSamsung;
    [self showTvControllView];
    [self.controllContentView bringSubviewToFront:self.tvControllView];
    HCTVDeviceItem *deviceItem = [[HCTVDeviceItem alloc] init];
    deviceItem.videoUrl = self.castUrl.absoluteString;
    deviceItem.samsungDev = samsungDev;
    deviceItem.seekTime = self.progressView.playTime;
    self.tvControllView.deviceItem = deviceItem;
}

- (void)didClickBackBtnForSelectTvDevController:(HCSelectTvDevController *)selectTvDevController
{
    if (_tvControllView.hidden && ![HCGoogleCastTool isCastingWithUrl:_url.absoluteString]) {
        if (self.urlPlayer.playerState == HCPlayerViewStateStop) {
            [self playWithUrl:_url];
        }
        else
        {
            [self resume];
        }
    }
    
    if (_noZoomInShowModel) {
        // 设置转场动画
        CATransition *transition = [CATransition animation];
        [transition setDuration:kVP_AniDuration];
        transition.type = kCATransitionFade;
        [[UIView vp_rootWindow].layer addAnimation:transition forKey:nil];
    }
}

#pragma mark - HCTVControllViewDelegate
- (void)tvControllView:(HCTVControllView *)tvControllView didClickExitBtnAtPlayTime:(NSTimeInterval)playTime
{
    [self hiddenTvControllView];
    [_tvControllView setupProgressZero];
    if (fabs(playTime - self.progressView.totalTime) <= 1) {
        [self.urlPlayer seekToTime:0 autoPlay:NO];
        [self didPlaybackForPlayerView:self.urlPlayer];
        self.progressView.playTime = 0;
        self.botProgressView.playTime = 0;
        return ;
    }
    [self.urlPlayer seekToTime:playTime autoPlay:YES complete:^(BOOL finished) {
        if (finished) {
            self.progressView.playTime = playTime;
            self.botProgressView.playTime = playTime;
        }
    }];
}

- (void)tvControllView:(HCTVControllView *)tvControllView didClickChangeDevBtnAtPlayTime:(NSTimeInterval)playTime
{
    // 设置换设备后，能接上原来的进度
    [self.timer stop];
    self.progressView.playTime = playTime;
    self.botProgressView.playTime = playTime;
    [self searchDevice];
}

- (void)didClickBackBtnForTvControllView:(HCTVControllView *)tvControllView
{
    [self backBtnClicked];
}

#pragma mark - HCSharePanelDelegate
- (void)sharePanel:(HCSharePanel *)sharePanel didSelectItem:(HCShareItem *)item
{
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didSelectSharePanelItem:shareImage:)]) {
        [self.delegate videoPlayer:self didSelectSharePanelItem:item shareImage:([item.key isEqualToString:ShareListKeyImageShare] ? self.imageShareView.image : nil)];
    }
    [_sharePanel hiddenPanel];
}

- (void)didHiddenSharePanel
{
    [self setControllViewHidden:NO];
}

#pragma mark - HCSelEpisodePanelDelegate
- (void)selEpisodePanel:(HCSelEpisodePanel *)selEpisodePanel didClickItem:(NSString *)item atIndex:(NSInteger)index
{
    if (index == _selEpisodeIndex) {
        return;
    }
    _selEpisodeIndex = index;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didSelectSelEpisodeItem:atIndex:)]) {
        [self.delegate videoPlayer:self didSelectSelEpisodeItem:item atIndex:index];
    }
    [_selEpisodePanel hiddenPanel];
    [self hiddenPicAd];
}

- (void)didHiddenSelEpisodePanel:(HCSelEpisodePanel *)selEpisodePanel
{
    [self setControllViewHidden:NO];
}

#pragma mark - HCMorePanelDelegate
- (void)didHiddenMorePanel
{
    [self setControllViewHidden:NO];
}

- (void)morePanel:(HCMorePanel *)morePanel didSelectRate:(CGFloat)rate
{
    self.rate = rate;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didSelectRate:)]) {
        [self.delegate videoPlayer:self didSelectRate:rate];
    }
}

- (void)morePanel:(HCMorePanel *)morePanel didChangeColloctStatus:(BOOL)status
{
    _collectStatus = status;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeMorePanelColloctStatus:)]) {
        [self.delegate videoPlayer:self didChangeMorePanelColloctStatus:status];
    }
}

- (void)didClickDlBtnForMorePanel:(HCMorePanel *)morePanel
{
    if ([self.delegate respondsToSelector:@selector(didClickMorePanelDLBtnForVideoPlayer:)]) {
        [self.delegate didClickMorePanelDLBtnForVideoPlayer:self];
    }
}

- (void)didClickCtBtnForMorePanel:(HCMorePanel *)morePanel
{
    [self tvBtnClicked:self.tvBtn];
    if ([self.delegate respondsToSelector:@selector(didClickCtBtnForVideoPlayer:)]) {
        [self.delegate didClickCtBtnForVideoPlayer:self];
    }
}

- (void)didClickStBtnForMorePanel:(HCMorePanel *)morePanel
{
    [self didClickSwitchBtn:self.switchBtn];
    [self hiddenPicAd];
    if ([self.delegate respondsToSelector:@selector(didClickStBtnForVideoPlayer:)]) {
        [self.delegate didClickStBtnForVideoPlayer:self];
    }
}

- (void)didClickTimeCloseBtnForMorePanel:(HCMorePanel *)morePanel
{
    HCTimingView *timingView = [HCTimingView showAtView:self.controllContentView];
    timingView.type = self.timingType;
    if ([self.delegate respondsToSelector:@selector(didClickTimeCloseForVideoPlayer:)]) {
        [self.delegate didClickTimeCloseForVideoPlayer:self];
    }
}

- (void)morePanel:(HCMorePanel *)morePanel didChangeFullScreenShowValue:(BOOL)value
{
    _urlPlayer.displayMode = (value ? HCPlayerViewDisplayModeScaleAspectFill : HCPlayerViewDisplayModeScaleAspectFit);
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeFullScreenShowValue:)]) {
        [self.delegate videoPlayer:self didChangeFullScreenShowValue:value];
    }
    self.fullShowBtn.selected = value;
}

- (void)morePanel:(HCMorePanel *)morePanel didChangeAutoSkipValue:(BOOL)value
{
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeAutoSkipValue:)]) {
        [self.delegate videoPlayer:self didChangeAutoSkipValue:value];
    }
}

- (void)morePanel:(HCMorePanel *)morePanel didChangeSmallWindowValue:(BOOL)value
{
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeSmallWindowValue:)]) {
        [self.delegate videoPlayer:self didChangeSmallWindowValue:value];
    }
}

#pragma mark - HCFastForwardAndBackViewDelegate
- (void)fastForwardAndBackView:(HCFastForwardAndBackView *)fastForwardAndBackView fastTime:(CGFloat)fastTime
{
    if ((self.status == HCVideoPlayerStatusPlay || self.status == HCVideoPlayerStatusPause) && self.zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        CGFloat currentProgress = self.progressView.playTime + fastTime;
        if (currentProgress < 0) {
            currentProgress = 0;
        }
        if (currentProgress > self.progressView.totalTime) {
            currentProgress = self.progressView.totalTime;
        }
        self.progressView.playTime = currentProgress;
        self.botProgressView.playTime = currentProgress;
        [self.progressImageView showWithCurSec:currentProgress];
        
        [_urlPlayer seekToTime:self.progressView.playTime autoPlay:YES complete:^(BOOL finished) {
            if (finished) {
                if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeProgress:)]) {
                    [self.delegate videoPlayer:self didChangeProgress:self.progressView.playTime];
                }
            }
        }];
        [self.progressImageView hiddenSelf];
        [self showLoading];
    }
}

# pragma mark - GCKSessionManagerListener
- (void)sessionManager:(GCKSessionManager *)sessionManager didStartSession:(GCKSession *)session {
    VPLog(@"MediaViewController: sessionManager didStartSession %@", session);
    [self switchToRemotePlayback];
}

- (void)sessionManager:(GCKSessionManager *)sessionManager didResumeSession:(GCKSession *)session {
    VPLog(@"MediaViewController: sessionManager didResumeSession %@", session);
    //    [self switchToRemotePlayback];
}

- (void)sessionManager:(GCKSessionManager *)sessionManager didEndSession:(GCKSession *)session
             withError:(NSError *)error {
    VPLog(@"session ended with error: %@", error);
    //    NSString *message = [NSString stringWithFormat:@"The Casting session has ended.\n%@", [error description]];
    [self switchToLocalPlayback];
}

- (void)sessionManager:(GCKSessionManager *)sessionManager didFailToStartSessionWithError:(NSError *)error {
    VPLog(@"session ended with error: %@", error);
}

#pragma mark - 事件
- (void)backBtnClicked
{
    if (_noZoomInShowModel) {
        [self hiddenSelf];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickBackBtnAtZoomStatus:)]) {
            [self.delegate videoPlayer:self didClickBackBtnAtZoomStatus:self.zoomStatus];
        }
        if (self.zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
            [self zoomBtnClicked:self.zoomBtn];
        }
    }
}

- (void)zoomBtnClicked:(UIButton *)zoomBtn
{
    __weak typeof(self) weakSelf = self;
    if (_noZoomInShowModel) {
        [self hiddenSelf];
    }
    else
    {
        if (_zoomType == HCVideoPlayerZoomTypeRotation) {
            [self zoomBtnClicked:zoomBtn duration:kVP_rotaionAniDuration complete:^(HCVideoPlayerZoomStatus zoomStatus) {
                [weakSelf setupControllContentViewPanGesture];
            }];
        }
        else {
            [self scale_zoomBtnClicked:zoomBtn duration:kVP_rotaionAniDuration complete:^(HCVideoPlayerZoomStatus zoomStatus) {
                [weakSelf setupControllContentViewPanGesture];
            }];
        }
    }
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickZoomBtn:)]) {
        [self.delegate videoPlayer:self didClickZoomBtn:zoomBtn];
    }
}


/// 旋转缩放
- (void)zoomBtnClicked:(UIButton *)zoomBtn duration:(NSTimeInterval)duration complete:(void (^)(HCVideoPlayerZoomStatus zoomStatus))complete
{
    if (!self.superview) {
        return;
    }
    @autoreleasepool {
        zoomBtn.selected = !zoomBtn.selected;
        self.zoomStatus = HCVideoPlayerZoomStatusZoomIn;
        if (zoomBtn.selected) {
            self.zoomStatus = HCVideoPlayerZoomStatusZoomOut;
        }
        
        __weak typeof(self) weakSelf = self;
        if (self.zoomStatus == HCVideoPlayerZoomStatusZoomIn) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationVideoPlayerWillZoomIn object:nil userInfo:@{@"toFrame" : [NSValue valueWithCGRect:self.orgRect]}];
            
            // 隐藏分享面板
            [_sharePanel hiddenPanel];
            [_morePanel hiddenPanel];
            
            self.isOnRotaion = YES;
            [self.rootPresentVc dismissViewControllerAnimated:NO completion:^{
                
                if (weakSelf.getPlayerSuperViewBlock) {
                    weakSelf.playSuperView = weakSelf.getPlayerSuperViewBlock(weakSelf);
                }
                if (weakSelf.getPlayerDelegateBlock) {
                    weakSelf.delegate = weakSelf.getPlayerDelegateBlock(weakSelf);
                }
                
                if (CGRectEqualToRect(weakSelf.orgRect, CGRectZero)) {
                    weakSelf.orgRect = [weakSelf getOrgRect];
                }
                
                // 缩小隐藏一些按钮
                [weakSelf setBtnsZoomInHidden:YES];
                // 缩小屏幕不可旋转
                [UIResponder setAllowRotation:NO forRootPresentVc:weakSelf.rootPresentVc];

                CGRect rect = weakSelf.orgRect;
                [UIView animateWithDuration:duration animations:^{
                    weakSelf.transform = CGAffineTransformIdentity;
                    weakSelf.frame = rect;
                    [UIResponder setPortraitOrientation];
                } completion:^(BOOL finished) {
                    [weakSelf.playSuperView addSubview:weakSelf];
                    weakSelf.frame = weakSelf.playSuperView.bounds;

                    if (complete) {
                        complete(HCVideoPlayerZoomStatusZoomIn);
                    }
                    if ([weakSelf.delegate respondsToSelector:@selector(videoPlayer:changedZoomStatus:)]) {
                        [weakSelf.delegate videoPlayer:weakSelf changedZoomStatus:HCVideoPlayerZoomStatusZoomIn];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationVideoPlayerDidZoomIn object:nil userInfo:@{@"toFrame" : [NSValue valueWithCGRect:weakSelf.frame]}];

                    weakSelf.isOnRotaion = NO;
                    [UIResponder setPortraitOrientation];
                }];
            }];
            [UIApplication sharedApplication].statusBarStyle = self.orgStatusBarStyle;
            [UIApplication sharedApplication].statusBarHidden = self.orgStatusBarHidden;
            self.center = [UIView vp_rootWindow].center;
            self.transform = CGAffineTransformMakeRotation(self.deviceOrientation == UIDeviceOrientationLandscapeLeft ? M_PI_2 : -M_PI_2);
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationVideoPlayerWillZoomOut object:nil userInfo:@{@"toFrame" : [NSValue valueWithCGRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)]}];
            
            // 放大显示一些按钮比如更多按钮
            [self setBtnsZoomInHidden:NO];
            // 放大设置屏幕可转
            [UIResponder setAllowRotation:YES forRootPresentVc:self.rootPresentVc];
            
            self.playSuperView = self.superview;
            [[UIView vp_rootWindow] addSubview:self];
            self.orgRect = [self getOrgRect];
            self.frame = self.orgRect;
            self.isOnRotaion = YES;
            
            if (self.deviceOrientation != UIDeviceOrientationLandscapeLeft && self.deviceOrientation != UIDeviceOrientationLandscapeRight) {
                [UIResponder setPortraitOrientation];
                self.deviceOrientation = UIDeviceOrientationLandscapeLeft;
            }
            [UIView animateWithDuration:duration animations:^{
                self.center = [UIView vp_rootWindow].center;
                CGFloat angle = ((self.deviceOrientation == UIDeviceOrientationLandscapeRight) ? -M_PI_2 : M_PI_2);
                self.transform = CGAffineTransformMakeRotation(angle);
                self.frame = [UIScreen mainScreen].bounds;
            } completion:^(BOOL finished) {
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
                [UIApplication sharedApplication].statusBarHidden = self.controllView.hidden;
                self.statusBar.alpha = self.controllView.hidden ? 0 : 1;
                HCOrientController *orVC = [[HCOrientController alloc] init];
                self.orVC = orVC;
                orVC.delegate = self;
                orVC.orientation = (self.deviceOrientation == UIDeviceOrientationLandscapeRight ?UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationLandscapeRight);
                UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:orVC];
                UITabBarController *tabVc = [[UITabBarController alloc] init];
                [tabVc addChildViewController:nvc];
                
                tabVc.modalPresentationStyle = UIModalPresentationFullScreen;
                
                [self.rootPresentVc presentViewController:tabVc animated:NO completion:^{
                    [[UIView vp_rootWindow] bringSubviewToFront:weakSelf];
                    if (complete) {
                        complete(HCVideoPlayerZoomStatusZoomOut);
                    }
                    if ([weakSelf.delegate respondsToSelector:@selector(videoPlayer:changedZoomStatus:)]) {
                        [weakSelf.delegate videoPlayer:weakSelf changedZoomStatus:HCVideoPlayerZoomStatusZoomOut];
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:NotificationVideoPlayerDidZoomOut object:nil userInfo:@{@"toFrame" : [NSValue valueWithCGRect:weakSelf.frame]}];
                    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
                    [UIApplication sharedApplication].statusBarHidden = weakSelf.controllView.hidden;
                    weakSelf.statusBar.alpha = weakSelf.controllView.hidden ? 0 : 1;
                    [UIResponder setOrientation:orVC.orientation];// 设置一致方向
                }];
                
                self.transform = CGAffineTransformIdentity;
                self.frame = [UIScreen mainScreen].bounds;
                self.isOnRotaion = NO;
            }];
        }
    }
}

/// 比例缩放
- (void)scale_zoomBtnClicked:(UIButton *)zoomBtn duration:(NSTimeInterval)duration complete:(void (^)(HCVideoPlayerZoomStatus zoomStatus))complete
{
    if (!self.superview) {
        return;
    }
    @autoreleasepool {
        zoomBtn.selected = !zoomBtn.selected;
        self.zoomStatus = HCVideoPlayerZoomStatusZoomIn;
        if (zoomBtn.selected) {
            self.zoomStatus = HCVideoPlayerZoomStatusZoomOut;
        }
        
        __weak typeof(self) weakSelf = self;
        if (self.zoomStatus == HCVideoPlayerZoomStatusZoomIn) {
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationVideoPlayerWillZoomIn object:nil userInfo:@{@"toFrame" : [NSValue valueWithCGRect:self.orgRect]}];
            
            // 隐藏分享面板
            [_sharePanel hiddenPanel];
            [_morePanel hiddenPanel];
            
            self.isOnRotaion = YES;
            
            // ******************************* start 不同
            if (weakSelf.getPlayerSuperViewBlock) {
                weakSelf.playSuperView = weakSelf.getPlayerSuperViewBlock(weakSelf);
            }
            if (weakSelf.getPlayerDelegateBlock) {
                weakSelf.delegate = weakSelf.getPlayerDelegateBlock(weakSelf);
            }
            
            if (CGRectEqualToRect(weakSelf.orgRect, CGRectZero)) {
                weakSelf.orgRect = [weakSelf getOrgRect];
            }
            
            // 缩小隐藏一些按钮
            [weakSelf setBtnsZoomInHidden:YES];
            [[UIView vp_rootWindow] bringSubviewToFront:weakSelf];
            CGRect rect = weakSelf.orgRect;
            [UIView animateWithDuration:duration animations:^{
                weakSelf.frame = rect;
            } completion:^(BOOL finished) {
                [weakSelf.playSuperView addSubview:weakSelf];
                weakSelf.frame = weakSelf.playSuperView.bounds;
                
                if (complete) {
                    complete(HCVideoPlayerZoomStatusZoomIn);
                }
                if ([weakSelf.delegate respondsToSelector:@selector(videoPlayer:changedZoomStatus:)]) {
                    [weakSelf.delegate videoPlayer:weakSelf changedZoomStatus:HCVideoPlayerZoomStatusZoomIn];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationVideoPlayerDidZoomIn object:nil userInfo:@{@"toFrame" : [NSValue valueWithCGRect:weakSelf.frame]}];
                
                weakSelf.isOnRotaion = NO;
            }];
            
            [UIApplication sharedApplication].statusBarStyle = self.orgStatusBarStyle;
            [UIApplication sharedApplication].statusBarHidden = self.orgStatusBarHidden;
            
            [self.rootPresentVc dismissViewControllerAnimated:NO completion:^{
            }];
            // ******************************* end 不同
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:NotificationVideoPlayerWillZoomOut object:nil userInfo:@{@"toFrame" : [NSValue valueWithCGRect:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width)]}];
            
            // 放大显示一些按钮比如更多按钮
            [self setBtnsZoomInHidden:NO];
            
            self.playSuperView = self.superview;
            [[UIView vp_rootWindow] addSubview:self];
            self.orgRect = [self getOrgRect];
            self.frame = self.orgRect;
            self.isOnRotaion = YES;
            
            // ******************************* start 不同
            [UIView animateWithDuration:duration animations:^{
                self.frame = [UIScreen mainScreen].bounds;
            } completion:^(BOOL finished) {
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
                [UIApplication sharedApplication].statusBarHidden = self.controllView.hidden;
                self.statusBar.alpha = self.controllView.hidden ? 0 : 1;
                [[UIView vp_rootWindow] bringSubviewToFront:weakSelf];
                if (complete) {
                    complete(HCVideoPlayerZoomStatusZoomOut);
                }
                if ([weakSelf.delegate respondsToSelector:@selector(videoPlayer:changedZoomStatus:)]) {
                    [weakSelf.delegate videoPlayer:weakSelf changedZoomStatus:HCVideoPlayerZoomStatusZoomOut];
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:NotificationVideoPlayerDidZoomOut object:nil userInfo:@{@"toFrame" : [NSValue valueWithCGRect:weakSelf.frame]}];
                [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
                [UIApplication sharedApplication].statusBarHidden = weakSelf.controllView.hidden;
                weakSelf.statusBar.alpha = weakSelf.controllView.hidden ? 0 : 1;
                self.isOnRotaion = NO;
                
                // 弹方向，便于弹出其他窗口
                HCOrientController *orVC = [[HCOrientController alloc] init];
                self.orVC = orVC;
                orVC.delegate = self;
                orVC.orientation = ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight ?UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationLandscapeRight);
                UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:orVC];
                UITabBarController *tabVc = [[UITabBarController alloc] init];
                [tabVc addChildViewController:nvc];
                
                tabVc.modalPresentationStyle = UIModalPresentationFullScreen;
                
                [self.rootPresentVc presentViewController:tabVc animated:NO completion:^{
                }];
            }];
            // ******************************* end 不同
        }
    }
}

- (void)playerBtnClicked:(UIButton *)playerBtn
{
    [self startHiddenControllViewTime];
    @autoreleasepool {
        self.isManualStopOrPausePlay = NO;
        self.messageLabel.hidden = YES;
        if (self.url)
        {
            if (self.urlPlayer.playerState == HCPlayerViewStateReadying) {
                return;
            }
            else if (self.urlPlayer.playerState == HCPlayerViewStatePlay)
            {
                [self.urlPlayer pause];
                self.isManualStopOrPausePlay = YES;
                [self showMsg:@"已暂停" stopPlay:NO autoHidden:YES];
            }
            else if (self.urlPlayer.playerState == HCPlayerViewStatePause || self.urlPlayer.playerState == HCPlayerViewStatePlayback || self.urlPlayer.playerState == HCPlayerViewStateReadyed)
            {
                [self.urlPlayer play];
            }
            else if (self.urlPlayer.playerState == HCPlayerViewStateStop || self.urlPlayer.playerState == HCPlayerViewStateIdle || self.urlPlayer.playerState == HCPlayerViewStateError)
            {
                [self showLoading];
                [self.urlPlayer readyWithUrl:self.url];
            }
        }
        if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickPlayBtn:)]) {
            [self.delegate videoPlayer:self didClickPlayBtn:playerBtn];
        }
        [self hiddenPicAd];
    }
}

- (void)controllContentViewClicked
{
//    if ((!(self.urlPlayer.playerState == HCPlayerViewStateReadyed || self.urlPlayer.playerState == HCPlayerViewStatePlay|| self.urlPlayer.playerState == HCPlayerViewStatePause|| self.urlPlayer.playerState == HCPlayerViewStatePlayback)) && !_noZoomInShowModel) {
//        return;
//    }
    if ([self.delegate respondsToSelector:@selector(didClickControllContentViewFroVideoPlayer:)]) {
        [self.delegate didClickControllContentViewFroVideoPlayer:self];
    }
    [self startHiddenControllViewTime];
    if (self.lockBtn.selected) {
        self.lockContentView.hidden = NO;
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            self.lockContentView.alpha = 1.0;
        }];
    }
    else
    {
        [self setControllViewHidden:NO];
//        [UIView animateWithDuration:kVP_AniDuration animations:^{
        [self setControllViewAlpha:1.0];
//        }];
    }
    
    if (self.zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        self.statusBar.alpha = 1;
    }
    
    if (_endEditWhenClickSelf) {
        [[UIViewController vp_currentVC].view endEditing:YES];
    }
    [self showOrHiddenLockBtnWhenCan];
}

- (void)viewDoubleClicked:(UIGestureRecognizer *)sender
{
    if (self.lockBtn.selected || _isLive) { // 锁屏状态 或 直播
        return;
    }
    CGPoint point = [sender locationInView:self];
    if (self.status == HCVideoPlayerStatusPause || (self.status == HCVideoPlayerStatusPlay && (point.x > 130) && (point.x < CGRectGetWidth(self.frame) - 130))) {
        [self playerBtnClicked:self.playerBtn];
    }
    else if (self.status == HCVideoPlayerStatusPlay && self.zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        self.fastForwardAndBackView.frame = self.controllContentView.bounds;
        if (point.x < 130) {
            [self.fastForwardAndBackView showLeft];
        }
        else if (point.x > CGRectGetWidth(self.frame) - 130)
        {
            [self.fastForwardAndBackView showRight];
        }
    }
}

- (void)controllContentViewPan:(UIPanGestureRecognizer *)pan
{
    if (self.lockBtn.selected) { // 锁屏状态
        return;
    }
    
    CGPoint location = [pan locationInView:self.controllContentView];
    CGPoint translation = [pan translationInView:self.controllContentView];
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        _slideDirection = 0;
        _volumeLastY = 0;
        _brightLastY = 0;
    }
    else if (pan.state == UIGestureRecognizerStateChanged) {
        if (_slideDirection == 0) { // 定这次滑动的方向
            _slideDirection = fabs(translation.y) > fabs(translation.x) ? -1 : 1;
        }
        
        if (_slideDirection == -1) { // 上下滑动
            // 调节系统音量
            if (location.x > self.controllContentView.frame.size.width * 0.5) {
                if (fabs(translation.y - _volumeLastY) > 5) {
                    Float32 systemVolume = _volumeViewSlider.value;
                    systemVolume = systemVolume + ((translation.y - _volumeLastY) > 0 ? -0.0667 : 0.0667);
                    if (systemVolume > 1.0) {
                        systemVolume = 1.0;
                    }
                    if (systemVolume < 0.0) {
                        systemVolume = 0.0;
                    }
                    // change system volume, the value is between 0.0f and 1.0f
                    [self.volumeViewSlider setValue:systemVolume animated:YES];
                    _volumeLastY = translation.y;
                }
            }
            // 调节系统屏幕亮度
            else
            {
                if (fabs(translation.y - _brightLastY) > 5) {
                    CGFloat systemBright = [UIScreen mainScreen].brightness;
                    systemBright = systemBright + ((translation.y - _brightLastY) > 0 ? -0.0667 : 0.0667);
                    if (systemBright > 1.0) {
                        systemBright = 1.0;
                    }
                    if (systemBright < 0.0) {
                        systemBright = 0.0;
                    }
                    // change system volume, the value is between 0.0f and 1.0f
                    //            [UIScreen mainScreen].brightness = systemBright;
                    [[UIScreen mainScreen] setBrightness:systemBright];
                    _brightLastY = translation.y;
                }
                VPLog(@"在左边滑动 %f", translation.y);
            }
        }
        else { // 左右滑动
            if (_isLive) { // 直播情况
                return;
            }
            if ((self.status == HCVideoPlayerStatusPlay || self.status == HCVideoPlayerStatusPause) && self.zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
//                [self pause];
                _currentPanContentViewTime = _lastPanContentViewTime + translation.x;
                if (_currentPanContentViewTime < 0) {
                    _currentPanContentViewTime = 0;
                }
                if (_currentPanContentViewTime > self.progressView.totalTime) {
                    _currentPanContentViewTime = self.progressView.totalTime;
                }
                self.progressView.playTime = _currentPanContentViewTime;
                self.botProgressView.playTime = _currentPanContentViewTime;
                [self.progressImageView showWithCurSec:_currentPanContentViewTime];
                
//                self.controllView.hidden = NO;
//                [UIView animateWithDuration:kVP_AniDuration animations:^{
//                    self.controllView.alpha = 1.0;
//                }];
            }
        }
    }
    else if (pan.state == UIGestureRecognizerStateEnded) {
        if (_slideDirection == 1 && !_isLive) { // 左右滑动
            [_urlPlayer seekToTime:self.progressView.playTime autoPlay:YES complete:^(BOOL finished) {
                if (finished) {
                    if ([self.delegate respondsToSelector:@selector(videoPlayer:didChangeProgress:)]) {
                        [self.delegate videoPlayer:self didChangeProgress:self.progressView.playTime];
                    }
                }
            }];
            [self.progressImageView hiddenSelf];
            _lastPanContentViewTime = _currentPanContentViewTime;
            [self showLoading];
        }
    }
}

- (void)controllerViewClicked:(UIView *)view
{
    if (view && [self.delegate respondsToSelector:@selector(didClickcontrollerViewFroVideoPlayer:)]) {
        [self.delegate didClickcontrollerViewFroVideoPlayer:self];
    }
    
    [UIView animateWithDuration:kVP_AniDuration animations:^{
        [self setControllViewAlpha:0.0];
        self.imageShareView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self setControllViewHidden:YES];
        CGRect rect = self.qualitySheet.frame;
        self.qualitySheet.hidden = YES;
        rect.size.height = 0;
        rect.origin.y = self.bottomBar.frame.origin.y;
        self.qualitySheet.frame = rect;
    }];
    if (self.zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        self.statusBar.alpha = 0;
    }
    
    if (_endEditWhenClickSelf) {
        [[UIViewController vp_currentVC].view endEditing:YES];
    }
    [self showOrHiddenLockBtnWhenCan];
}

- (void)lockContentViewClicked
{
    [UIView animateWithDuration:kVP_AniDuration animations:^{
        self.lockContentView.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.lockContentView.hidden = YES;
    }];
    if (self.zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        self.statusBar.alpha = 0;
    }
    
    if (_endEditWhenClickSelf) {
        [[UIViewController vp_currentVC].view endEditing:YES];
    }
    [self showOrHiddenLockBtnWhenCan];
}

- (void)qualityBtnClicked:(UIButton *)qualityBtn
{
    [self startHiddenControllViewTime];
    CGRect rect = self.qualitySheet.frame;
    if (self.qualitySheet.hidden) {
        self.qualitySheet.hidden = NO;
        self.qualitySheet.alpha = 1.0;
        rect.size.height = 100;
        rect.origin.y = self.bottomBar.frame.origin.y - rect.size.height;
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            self.qualitySheet.frame = rect;
        }];
    }
    else
    {
        rect.size.height = 0;
        rect.origin.y = self.bottomBar.frame.origin.y;
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            self.qualitySheet.alpha = 0.0;
        }completion:^(BOOL finished) {
            self.qualitySheet.hidden = YES;
            self.qualitySheet.frame = rect;
        }];
    }
}

- (void)bottomBarPan:(UIPanGestureRecognizer *)recognizer
{
    [self startHiddenControllViewTime];
    if (_isLive) {  // 直播情况
        return;
    }
    CGPoint point =  [recognizer translationInView:self.progressView];
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        CGFloat x = self.panStartProgress * self.progressView.bounds.size.width;
        self.progressView.playProgress = (point.x + x) / self.progressView.bounds.size.width;
        [self progressView:self.progressView didSliderUpAtValue:self.progressView.playProgress time:self.progressView.playTime];
        [self.urlPlayer play];
//        self.progressView.loadTime = 0;
        self.isPan = NO;
        [self.progressImageView hiddenSelf];
    }
    else {
        if (!self.isPan) {
            self.panStartProgress = self.progressView.playProgress;
        }
        self.isPan = YES;
//        [self.urlPlayer pause];
        CGFloat x = self.panStartProgress * self.progressView.bounds.size.width;
        self.progressView.playProgress = (point.x + x) / self.progressView.bounds.size.width;
        
        // 进度图显示
        [self.progressImageView showWithCurSec:self.progressView.playTime];
    }
}

- (void)loadErrorLabelClicked
{
    if (_url.absoluteString.length) {
        [self playWithUrl:_url];
    }
    else
    {
        if ([self.delegate respondsToSelector:@selector(didClickErrorTextForvideoPlayer:)]) {
            [self.delegate didClickErrorTextForvideoPlayer:self];
        }
    }
}

- (void)moreBtnClicked:(UIButton *)btn
{
    [self startHiddenControllViewTime];
    BOOL isExecute = YES;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickMoreBtn:)]) {
        isExecute = [self.delegate videoPlayer:self didClickMoreBtn:btn];
    }
    if (!isExecute) {
        return;
    }
    
    HCMorePanel *morePanel = [[HCMorePanel alloc] init];
    morePanel.rate = _rate;
    morePanel.delegate = self;
    morePanel.collectStatus = _collectStatus;
    morePanel.enableDlBtn = _enableDlBtn;
    morePanel.enableStBtn = _enableStBtn;
    morePanel.enableAddToMyDefWBBtn = _enableAddToMyDefWBBtn;
    [morePanel showPanelAtView:self.controllContentView];
    _morePanel = morePanel;
    [self setControllViewHidden:YES];
}

- (void)shareBtnClicked:(UIButton *)btn
{
    [self startHiddenControllViewTime];
    BOOL isExecute = YES;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickShareBtn:)]) {
        isExecute = [self.delegate videoPlayer:self didClickShareBtn:btn];
    }
    if (!isExecute) {
        return;
    }
    
    HCSharePanel *sharePanel = [[HCSharePanel alloc] init];
    [sharePanel showPanelAtView:self.controllContentView key:ShareListKeyLinkShare];
    sharePanel.delegate = self;
    _sharePanel = sharePanel;
    [self setControllViewHidden:YES];
}

- (void)tvBtnClicked:(UIButton *)btn
{
    [self startHiddenControllViewTime];
    [self hiddenPicAd];
    BOOL isExecute = YES;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickTVBtn:)]) {
        isExecute = [self.delegate videoPlayer:self didClickTVBtn:btn];
    }
    if (!isExecute) {
        return;
    }
    
    if (self.urlPlayer.playerState == HCPlayerViewStateReadyed || self.urlPlayer.playerState == HCPlayerViewStatePlay || self.urlPlayer.playerState == HCPlayerViewStatePause || self.urlPlayer.playerState == HCPlayerViewStatePlayback) {
        [self pause];
    }
    else
    {
        [self stop];
    }
    _isManualStopOrPausePlay = YES;
    [self searchDevice];
}

- (void)nextBtnClicked:(UIButton *)btn
{
    [self startHiddenControllViewTime];
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickNextBtn:)]) {
        [self.delegate videoPlayer:self didClickNextBtn:btn];
    }
    [self hiddenPicAd];
}

- (void)didClickBarrageBtn:(UIButton *)btn
{
    [self startHiddenControllViewTime];
    self.isBarrageOpen = !self.isBarrageOpen;
    self.showBarrageSendBtn = self.isBarrageOpen;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickBarrageBtn:)]) {
        [self.delegate videoPlayer:self didClickBarrageBtn:btn];
    }
}

- (void)didClickBarrageSelColorBtn:(UIButton *)btn
{
    [self startHiddenControllViewTime];
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickBarrageSelColorBtn:)]) {
        [self.delegate videoPlayer:self didClickBarrageSelColorBtn:btn];
    }
}

- (void)didClickBarrageSendBtn
{
    [self startHiddenControllViewTime];
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickBarrageSendBtn:)]) {
        [self.delegate videoPlayer:self didClickBarrageSendBtn:self.barrageSendBtn];
    }
}

- (void)episodeBtnClicked:(UIButton *)btn
{
    [self startHiddenControllViewTime];
    BOOL isExecute = YES;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickEpisodeBtn:)]) {
        isExecute = [self.delegate videoPlayer:self didClickEpisodeBtn:btn];
    }
    if (!isExecute) {
        return;
    }
    
    HCSelEpisodePanel *selEpisodePanel = [[HCSelEpisodePanel alloc] init];
    [selEpisodePanel showPanelAtView:self.controllContentView];
    _selEpisodePanel = selEpisodePanel;
    selEpisodePanel.delegate = self;
    selEpisodePanel.items = _episodeTitles;
    selEpisodePanel.isBigType = _isBigSelEpisodeType;
    selEpisodePanel.selIndex = _selEpisodeIndex;
    [self setControllViewHidden:YES];
}

- (void)cameraBtnClicked:(UIButton *)btn
{
    [self startHiddenControllViewTime];
    BOOL isExecute = YES;
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickCameraBtn:)]) {
        isExecute = [self.delegate videoPlayer:self didClickCameraBtn:btn];
    }
    if (!isExecute) {
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    if (self.imageShareView.alpha == 0) {
        [self.urlPlayer getCurrentTimeImageComplete:^(UIImage *image) {
            weakSelf.imageShareView.image = image;
            [UIView animateWithDuration:kVP_AniDuration animations:^{
                weakSelf.imageShareView.alpha = 1 - weakSelf.imageShareView.alpha;;
            }];
            
            UIImageWriteToSavedPhotosAlbum(image, nil, nil, NULL);
        }];
    }
    else
    {
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            self.imageShareView.alpha = 1 - self.imageShareView.alpha;;
        }];
    }
}

- (void)didClickSwitchBtn:(UIButton *)btn
{
    [self startHiddenControllViewTime];
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickSwitchBtn:)]) {
        [self.delegate videoPlayer:self didClickSwitchBtn:btn];
    }
}

- (void)imageShareViewClicked
{
    [self startHiddenControllViewTime];
    HCSharePanel *sharePanel = [[HCSharePanel alloc] init];
    [sharePanel showPanelAtView:self.controllContentView key:ShareListKeyImageShare];
    sharePanel.delegate = self;
    
    _sharePanel = sharePanel;
    [self setControllViewHidden:YES];
    self.imageShareView.alpha = 0.0;
}

- (void)didClickLockBtn
{
    [self startHiddenControllViewTime];
    self.lockBtn.selected = !self.lockBtn.selected;
    
    if (self.lockBtn.selected) {
        if ([self isControllContentViewShowContent]) {
            self.lockContentView.alpha = 1.0;
            self.lockContentView.hidden = NO;
        }
        [self setControllViewHidden:YES];
        [self setControllViewAlpha:0.0];
    }
    else
    {
        if ([self isControllContentViewShowContent]) {
            [self setControllViewAlpha:1.0];
            [self setControllViewHidden:NO];
        }
        self.lockContentView.hidden = YES;
        self.lockContentView.alpha = 0;
    }
    
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickLockBtn:)]) {
        [self.delegate videoPlayer:self didClickLockBtn:self.lockBtn];
    }
}

- (void)didPinSelf:(UIPinchGestureRecognizer *)recognizer
{
    CGFloat scale = recognizer.scale;
    _urlPlayer.displayMode = scale > 1 ? HCPlayerViewDisplayModeScaleAspectFill : HCPlayerViewDisplayModeScaleAspectFit;
}

- (void)didClickFullShowBtn:(UIButton *)btn
{
    [self startHiddenControllViewTime];
    _fullShowBtn.selected = !_fullShowBtn.selected;
    [[NSUserDefaults standardUserDefaults] setBool:_fullShowBtn.selected forKey:VPFullScreenShow];
    [[NSUserDefaults standardUserDefaults] synchronize];
    self.urlPlayer.displayMode = _fullShowBtn.selected ? HCPlayerViewDisplayModeScaleAspectFill : HCPlayerViewDisplayModeScaleAspectFit;
}

#pragma mark - 通知事件
- (void)orientationDidChange:(id)change
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_zoomType == HCVideoPlayerZoomTypeScale) {
            _deviceOrientation = [UIDevice currentDevice].orientation;
            return;
        }
        
        UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
        if (orientation == UIDeviceOrientationLandscapeLeft) {
            _deviceOrientation = UIDeviceOrientationLandscapeLeft;
            if (_autoZoom && [self isInCurrentShowControllerForSelf] && self.zoomStatus == HCVideoPlayerZoomStatusZoomIn && !_isOnRotaion && (_urlPlayer.playerState == HCPlayerViewStatePlay || _urlPlayer.playerState == HCPlayerViewStatePause || _urlPlayer.playerState == HCPlayerViewStateReadyed)) {
                [self zoomBtnClicked:self.zoomBtn];
            }
            VPLog(@"UIDeviceOrientationLandscapeLeft");
        }
        if (orientation == UIDeviceOrientationLandscapeRight) {
            _deviceOrientation = UIDeviceOrientationLandscapeRight;
            if (_autoZoom && [self isInCurrentShowControllerForSelf] && self.zoomStatus == HCVideoPlayerZoomStatusZoomIn && !_isOnRotaion && (_urlPlayer.playerState == HCPlayerViewStatePlay || _urlPlayer.playerState == HCPlayerViewStatePause || _urlPlayer.playerState == HCPlayerViewStateReadyed)) {
                [self zoomBtnClicked:self.zoomBtn];
            }
            VPLog(@"UIDeviceOrientationLandscapeRight");
        }
        if (orientation == UIDeviceOrientationPortrait && !self.lockBtn.selected) {
            if (_zoomInWhenVerticalScreen) {
                if (_autoZoom && [self isInCurrentShowControllerForSelf] && self.zoomStatus == HCVideoPlayerZoomStatusZoomOut && !_isOnRotaion) {
                    [self zoomBtnClicked:self.zoomBtn];
                }
            }
            VPLog(@"UIDeviceOrientationPortrait");
        }
        if (orientation == UIDeviceOrientationPortraitUpsideDown) {
            VPLog(@"UIDeviceOrientationPortraitUpsideDown");
        }
    });
}

- (void)networkReceivedSpeed:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadSpeedLabel.text = notification.userInfo[@"received"];
    });
}

- (void)applicationWillResignActive
{
    self.isInBackground = YES;
    // 投屏不做处理
    if (self.tvControllView.hidden == NO) {
        return;
    }
    //
//    if (self.urlPlayer.playerState == HCPlayerViewStatePlay || self.urlPlayer.playerState == HCPlayerViewStatePause || self.urlPlayer.playerState == HCPlayerViewStateReadyed) {
        [self pause];
//    }
//    else
//    {
//        [self stop];
//    }
}

- (void)applicationDidBecomeActive
{
    self.isInBackground = NO;
    if (_whenAppActiveNotToPlay) {
        return;
    }
    
    NSURL *p2pUrl = [HCPTPTool PTPStreamURLForURL:_url];
    BOOL isSamePTPUrl = [_urlPlayer.p2pUrl.absoluteString.lowercaseString isEqualToString:p2pUrl.absoluteString.lowercaseString];
    
    __weak typeof(self) weakSelf = self;
    if (_urlPlayer.p2pUrl && !isSamePTPUrl) { // 使用p2p，但p2p url 已变的情况
        if (self.tvControllView.hidden == NO && self.tvControllView.style == HCTVControllViewStyleAirPlay) {
            return;
        }
        [self playWithUrl:_url forceReload:YES readyComplete:^(HCVideoPlayer *videoPlayer, HCVideoPlayerStatus status) {
            if (status == HCVideoPlayerStatusReadyed) {
                [weakSelf seekToTime:weakSelf.progressView.lastPlayTime autoPlay:NO complete:^(BOOL finished) {
                    if (finished) {
                        // 正在投屏或是之前是手动暂停的，暂停播放
                        if (weakSelf.tvControllView.hidden == NO || weakSelf.isManualStopOrPausePlay) {
                            [weakSelf pause];
                        }
                        else
                        {
                            [weakSelf play];
                        }
                    }
                }];
            }
        }];
    }
    else // 不使用p2p的情况
    {
        // 投屏不做处理
        if (self.tvControllView.hidden == NO) {
            return;
        }
        //
        if (self.isManualStopOrPausePlay == YES) {
            return;
        }
//        if (self.urlPlayer.playerState == HCPlayerViewStatePause || self.urlPlayer.playerState == HCPlayerViewStatePlay) {
            [self play];
//        }
//        else
//        {
//            [self playWithUrl:_url forceReload:NO readyComplete:^(HCVideoPlayer *videoPlayer, HCVideoPlayerStatus status) {
//                if (status == HCVideoPlayerStatusReadyed) {
//                    [weakSelf seekToTime:weakSelf.progressView.lastPlayTime autoPlay:NO complete:^(BOOL finished) {
//                    }];
//                }
//            }];
//        }
    }
}

- (void)didSetTiming:(NSNotification *)notification
{
    NSDictionary *dict = notification.userInfo;
    HCTimingType timingType = (HCTimingType)[dict[@"type"] integerValue];
    
    switch (timingType) {
        case HCTimingTypeUnuse:
        {
            [self.timingTimer stop];
            self.timingType = HCTimingTypeUnuse;
        }
            break;
        case HCTimingTypePlayTheEps:
        {
            self.timingType = HCTimingTypePlayTheEps;
        }
            break;
        case HCTimingTypePlay30:
        {
            [self.timingTimer stop];
            self.timingTimer = [HCWeakTimer scheduledTimerWithTimeInterval:1800 target:self selector:@selector(timingTimerEvent) userInfo:nil repeats:NO];
            self.timingType = HCTimingTypePlay30;
        }
            break;
        case HCTimingTypePlay60:
        {
            [self.timingTimer stop];
            self.timingTimer = [HCWeakTimer scheduledTimerWithTimeInterval:3600 target:self selector:@selector(timingTimerEvent) userInfo:nil repeats:NO];
            self.timingType = HCTimingTypePlay60;
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - time 事件
- (void)hiddenControllViewTimeEvent
{
    if ([_orVC respondsToSelector:@selector(presentedViewController)] && _orVC.presentedViewController) {
        return;
    }
    [self controllerViewClicked:nil];
    [self lockContentViewClicked];
}

- (void)timingTimerEvent
{
    [self backBtnClicked];
}

#pragma mark AirPlay 相关通知
- (void)MPVolumeViewWirelessRoutesAvailableDidChange
{
    dispatch_async(dispatch_get_main_queue(), ^{
//    [self setupIsWirelessRouteActive];
    });
}

- (void)MPVolumeViewWirelessRouteActiveDidChange
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupIsWirelessRouteActive];
    });
}

- (void)outputDeviceChanged:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.volume = self.volume;
        if (_isBluetoothOutput && ![HCAirplayCastTool isBluetoothOutput]) {
            [self pause];
        }
        if (!_isBluetoothOutput && [HCAirplayCastTool isBluetoothOutput] && !_isManualStopOrPausePlay && !(self.urlPlayer.isCalling)) {
            [self play];
        }
        _isBluetoothOutput = [HCAirplayCastTool isBluetoothOutput];
        [self setupIsWirelessRouteActive];
    });
}

#pragma mark - 内部方法
- (void)setupUrlPlayer:(HCPlayerView *)urlPlayer
{
    _urlPlayer = urlPlayer;
}

- (void)showOrHiddenLoading
{
    if (((fabs(self.progressView.loadTime - _progressView.playTime) < 1) && _urlPlayer.playerState == HCPlayerViewStatePlay) || _urlPlayer.playerState == HCPlayerViewStateReadying) {
        [self showLoading];
    }
    else
    {
        [self hiddenLoading];
    }
}

- (void)showLoading
{
    if ([_url.absoluteString containsString:@"localhost"] || [_url.absoluteString containsString:@"127.0.0.1"] || [_url.absoluteString containsString:@"file:"]) {
        return;
    }
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    self.loadSpeedLabel.hidden = NO;
    [[HCNetWorkSpeed shareNetworkSpeed] startMonitoringNetworkSpeed];
}

- (void)hiddenLoading
{
    self.activityIndicator.hidden = YES;
    [self.activityIndicator stopAnimating];
    
    self.loadSpeedLabel.hidden = YES;
    [[HCNetWorkSpeed shareNetworkSpeed] stopMonitoringNetworkSpeed];
}

- (void)showLoadError
{
    [self hiddenLoading];
    self.loadErrorLabel.hidden = NO;
    [self.controllContentView bringSubviewToFront:self.loadErrorLabel];
}

- (void)hiddenLoadError
{
    self.loadErrorLabel.hidden = YES;
}

- (UIViewController *)viewControllerForView:(UIView *)view {
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (CGRect)getOrgRect
{
    CGRect rect = [self.playSuperView convertRect:self.playSuperView.bounds toView:[UIView vp_rootWindow]];
    // 打印
//#ifdef DEBUG
//    if ((![self viewControllerForView:self.playSuperView].navigationController || [self viewControllerForView:self.playSuperView].navigationController.navigationBarHidden) && ![UIApplication sharedApplication].statusBarHidden)
//    {
//        rect.origin.y += kVP_StatusBarHeight;
//    }
//#else
//    if ([self viewControllerForView:self.playSuperView].navigationController && [UIApplication sharedApplication].statusBarHidden) {
//        rect.origin.y -= kVP_StatusBarHeight;
//    }
//    else if ((![self viewControllerForView:self.playSuperView].navigationController || [self viewControllerForView:self.playSuperView].navigationController.navigationBarHidden) && ![UIApplication sharedApplication].statusBarHidden)
//    {
//        rect.origin.y += kVP_StatusBarHeight;
//    }
//#endif /* DEBUG */
    return rect;
}

- (void)setBtnsZoomInHidden:(BOOL)hidden
{
    if (_zoomInHiddenTvBtn) {
        self.tvBtn.hidden = hidden;
    }
    if (_zoomInHiddenMoreBtn) {
        self.moreBtn.hidden = hidden;
    }
    if (_zoomInHiddenShareBtn) {
        self.shareBtn.hidden = hidden;
    }
    if (_zoomInHiddenNextBtn) {
        self.nextBtn.hidden = _isLive ? YES : hidden;
    }
    if (_zoomInHiddenEpisodeBtn) {
        self.episodeBtn.hidden = _isLive ? YES : hidden;
    }
    if (_zoomInHiddenFullShowBtn) {
        self.fullShowBtn.hidden = hidden;
    }
    if (_zoomInHiddenCameraBtn) {
        self.cameraBtn.hidden = hidden;
    }
    if (_zoomInHiddenSwitchBtn) {
        self.switchBtn.hidden = hidden;
    }
    [self showOrHiddenLockBtnWhenCan];
    //
    self.imageShareView.alpha = 0.0;
}

- (void)setupControllContentViewPanGesture
{
    if (self.zoomStatus == HCVideoPlayerZoomStatusZoomIn) {
        for (UIGestureRecognizer *gr in self.controllContentView.gestureRecognizers) {
            if ([gr isKindOfClass:[UIPanGestureRecognizer class]]) {
                [self.controllContentView removeGestureRecognizer:gr];
                break;
            }
        }
    }
    else
    {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(controllContentViewPan:)];
        [self.controllContentView addGestureRecognizer:pan];
    }
}

- (void)searchDevice {
    [self.timer stop];
    if (_noZoomInShowModel) {
        HCSelectTvDevController *selectTvDevController = [[HCSelectTvDevController alloc] init];
        _tvVc = selectTvDevController;
        selectTvDevController.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:selectTvDevController];
        
        GCKUICastContainerViewController *castContainerVC;
        castContainerVC = [[GCKCastContext sharedInstance]
                           createCastContainerControllerForViewController:nav];
        castContainerVC.miniMediaControlsItemEnabled = YES;
        _tvVc.castContainerVC = castContainerVC;
        
        UIViewController *vc = castContainerVC;
        if (vc == nil) {
            vc = nav;
        }
        vc.modalPresentationStyle = UIModalPresentationFullScreen;
        [_orVC presentViewController:vc animated:NO completion:^{
        }];
        
        // 设置转场动画
        CATransition *transition = [CATransition animation];
        [transition setDuration:kVP_AniDuration];
        transition.type = kCATransitionFade;
        [[UIView vp_rootWindow].layer addAnimation:transition forKey:nil];
    }
    else
    {
        __weak typeof(self) weakSelf = self;
        if (self.zoomStatus == HCVideoPlayerZoomStatusZoomOut)
        {
            [self zoomBtnClicked:self.zoomBtn duration:0 complete:^(HCVideoPlayerZoomStatus zoomStatus) {
                [weakSelf setupControllContentViewPanGesture];
            }];
        }
        HCSelectTvDevController *selectTvDevController = [[HCSelectTvDevController alloc] init];
        _tvVc = selectTvDevController;
        selectTvDevController.delegate = self;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:selectTvDevController];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.rootPresentVc presentViewController:nav animated:YES completion:nil];
    }
}

+ (instancetype)rotation_showWithVideoPlayer:(HCVideoPlayer *)videoPlayer curController:(UIViewController *)curController showComplete:(void (^)(void))showComplete
{
    if (videoPlayer == nil) {
        videoPlayer = [[self alloc] initWithCurController:curController];
    }
    else {
        videoPlayer.curController = curController;
    }
    [[UIView vp_rootWindow] addSubview:videoPlayer];
    
    videoPlayer.zoomInWhenVerticalScreen = NO;
    videoPlayer.noZoomInShowModel = YES;
    
    // 放大显示一些按钮比如更多按钮
    [videoPlayer setBtnsZoomInHidden:NO];
    // 放大设置屏幕可转
    [UIResponder setAllowRotation:YES forRootPresentVc:videoPlayer.rootPresentVc];
    
    videoPlayer.zoomStatus = HCVideoPlayerZoomStatusZoomOut;
    [videoPlayer setupControllContentViewPanGesture];
    
    if (videoPlayer.deviceOrientation != UIDeviceOrientationLandscapeLeft && videoPlayer.deviceOrientation != UIDeviceOrientationLandscapeRight) {
        [UIResponder setPortraitOrientation];
        videoPlayer.deviceOrientation = UIDeviceOrientationLandscapeLeft;
    }
    
    CGFloat angle = ((videoPlayer.deviceOrientation == UIDeviceOrientationLandscapeRight) ? -M_PI_2 : M_PI_2);
    videoPlayer.transform = CGAffineTransformMakeRotation(angle);
    videoPlayer.frame = [UIScreen mainScreen].bounds;
    CGRect rect = videoPlayer.frame;
    rect.origin.x = -kVP_ScreenWidth;
    videoPlayer.frame = rect;
    videoPlayer.isOnRotaion = YES;
    videoPlayer.isShowing = YES;
    [UIView animateWithDuration:kVP_AniDuration animations:^{
        CGRect rect = videoPlayer.frame;
        rect.origin.x = 0;
        videoPlayer.frame = rect;
    } completion:^(BOOL finished) {
        [videoPlayer showLoading];
        videoPlayer.zoomBtn.selected = YES;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [UIApplication sharedApplication].statusBarHidden = videoPlayer.controllView.hidden;
        videoPlayer.statusBar.alpha = videoPlayer.controllView.hidden ? 0 : 1;
        HCOrientController *orVC = [[HCOrientController alloc] init];
        videoPlayer.orVC = orVC;
        orVC.delegate = videoPlayer;
        orVC.orientation = (videoPlayer.deviceOrientation == UIDeviceOrientationLandscapeRight ?UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationLandscapeRight);
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:orVC];
        UITabBarController *tabVc = [[UITabBarController alloc] init];
        [tabVc addChildViewController:nvc];
        
        tabVc.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [videoPlayer.rootPresentVc presentViewController:tabVc animated:NO completion:^{
            [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
            [UIApplication sharedApplication].statusBarHidden = videoPlayer.controllView.hidden;
            videoPlayer.statusBar.alpha = videoPlayer.controllView.hidden ? 0 : 1;
            [UIResponder setOrientation:orVC.orientation];// 设置一致方向
        }];
        
        videoPlayer.transform = CGAffineTransformIdentity;
        videoPlayer.frame = [UIScreen mainScreen].bounds;
        videoPlayer.isOnRotaion = NO;
        
        if (showComplete) {
            showComplete();
        }
    }];
    return videoPlayer;
}

+ (instancetype)scale_showWithVideoPlayer:(HCVideoPlayer *)videoPlayer curController:(UIViewController *)curController showComplete:(void (^)(void))showComplete
{
    if (videoPlayer == nil) {
        videoPlayer = [[self alloc] initWithCurController:curController];
    }
    else {
        videoPlayer.curController = curController;
    }
    videoPlayer.curController = curController;
    [[UIView vp_rootWindow] addSubview:videoPlayer];
    
    videoPlayer.zoomInWhenVerticalScreen = NO;
    videoPlayer.noZoomInShowModel = YES;
    
    // 放大显示一些按钮比如更多按钮
    [videoPlayer setBtnsZoomInHidden:NO];
    videoPlayer.zoomStatus = HCVideoPlayerZoomStatusZoomOut;
    [videoPlayer setupControllContentViewPanGesture];
    
    // ******************************* start 不同
    videoPlayer.frame = [UIScreen mainScreen].bounds;
    CGRect rect = videoPlayer.frame;
    rect.origin.x = -kVP_ScreenWidth;
    videoPlayer.frame = rect;
    videoPlayer.isOnRotaion = YES;
    videoPlayer.isShowing = YES;
    [UIView animateWithDuration:kVP_AniDuration animations:^{
        CGRect rect = videoPlayer.frame;
        rect.origin.x = 0;
        videoPlayer.frame = rect;
    } completion:^(BOOL finished) {
        [videoPlayer showLoading];
        videoPlayer.zoomBtn.selected = YES;
        [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
        [UIApplication sharedApplication].statusBarHidden = videoPlayer.controllView.hidden;
        videoPlayer.statusBar.alpha = videoPlayer.controllView.hidden ? 0 : 1;
        videoPlayer.frame = [UIScreen mainScreen].bounds;
        videoPlayer.isOnRotaion = NO;
        
        if (showComplete) {
            showComplete();
        }
        
        // 弹方向，便于弹出其他窗口
        HCOrientController *orVC = [[HCOrientController alloc] init];
        videoPlayer.orVC = orVC;
        orVC.delegate = videoPlayer;
        orVC.orientation = ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight ?UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationLandscapeRight);
        UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:orVC];
        UITabBarController *tabVc = [[UITabBarController alloc] init];
        [tabVc addChildViewController:nvc];
        
        tabVc.modalPresentationStyle = UIModalPresentationFullScreen;
        
        [videoPlayer.rootPresentVc presentViewController:tabVc animated:NO completion:^{
        }];
    }];
    // ******************************* end 不同
    return videoPlayer;
}

- (void)rotation_hiddenSelf
{
    if (!_isShowing) {
        return;
    }
    _isShowing = NO;
    [self.timer stop];
    _isOnRotaion = YES;
    [self.rootPresentVc dismissViewControllerAnimated:NO completion:^{
        // 缩小屏幕不可旋转
        [UIResponder setAllowRotation:NO forRootPresentVc:self.rootPresentVc];
        
        [UIView animateWithDuration:kVP_AniDuration animations:^{
            CGRect rect = self.frame;
            rect.origin.y = kVP_ScreenHeight;
            self.frame = rect;
        } completion:^(BOOL finished) {
            _isOnRotaion = NO;
            self.zoomStatus = HCVideoPlayerZoomStatusZoomIn;
            BOOL exeNext = YES;
            if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickBackBtnAtZoomStatus:)]) {
                exeNext = [self.delegate videoPlayer:self didClickBackBtnAtZoomStatus:self.zoomStatus];
            }
            
            if (exeNext) {
                if (![HCAirplayCastTool isAirPlayOnCast]) {
                    [self stop];
                }
                [self removeFromSuperview];
            }
            else {
                self.transform = CGAffineTransformIdentity;
                [self setupSelfSubviewsFrame];
            }
        }];
        
        // 消除方向对键盘的影响
        [UIResponder setPortraitOrientation];
    }];
    [UIApplication sharedApplication].statusBarStyle = _orgStatusBarStyle;
    [UIApplication sharedApplication].statusBarHidden = _orgStatusBarHidden;
    self.center = [UIView vp_rootWindow].center;
    self.transform = CGAffineTransformMakeRotation(_deviceOrientation == UIDeviceOrientationLandscapeLeft ? M_PI_2 : -M_PI_2);
}

- (void)scale_hiddenSelf
{
    if (!_isShowing) {
        return;
    }
    _isShowing = NO;
    [self.timer stop];
    _isOnRotaion = YES;
    
    // ******************************* start 不同
    [UIView animateWithDuration:kVP_AniDuration animations:^{
        CGRect rect = self.frame;
        rect.origin.y = kVP_ScreenHeight;
        self.frame = rect;
    } completion:^(BOOL finished) {
        self.isOnRotaion = NO;
        self.zoomStatus = HCVideoPlayerZoomStatusZoomIn;
        BOOL exeNext = YES;
        if ([self.delegate respondsToSelector:@selector(videoPlayer:didClickBackBtnAtZoomStatus:)]) {
            exeNext = [self.delegate videoPlayer:self didClickBackBtnAtZoomStatus:self.zoomStatus];
        }
        
        if (exeNext) {
            if (![HCAirplayCastTool isAirPlayOnCast]) {
                [self stop];
            }
            [self removeFromSuperview];
        }
        else {
            [self setupSelfSubviewsFrame];
        }
    }];
    
    [UIApplication sharedApplication].statusBarStyle = _orgStatusBarStyle;
    [UIApplication sharedApplication].statusBarHidden = _orgStatusBarHidden;
    
    [self.rootPresentVc dismissViewControllerAnimated:NO completion:^{
    }];
    // ******************************* end 不同
}

- (void)showOrHiddenLockBtnWhenCan
{
    if (self.controllView.alpha != 0  || self.lockContentView.alpha != 0) {
        if (_zoomInHiddenLockBtn) {
            if (self.zoomStatus == HCVideoPlayerZoomStatusZoomOut) {
                self.lockBtn.hidden = NO;
            }
            else {
                self.lockBtn.hidden = YES;
            }
        }
        else {
            self.lockBtn.hidden = NO;
        }
    }
    else {
        self.lockBtn.hidden = YES;
    }
}

- (BOOL)isControllContentViewShowContent
{
    return (!_controllView.hidden && _controllView.alpha == 1) || (!_lockContentView.hidden && _lockContentView.alpha == 1);
}

- (BOOL)isInCurrentShowControllerForSelf
{
    if ((self.vp_myController.isViewLoaded && self.vp_myController.view.window) || self.superview == [UIView vp_rootWindow]) {
        return YES;
    }
    return NO;
}

- (void)startHiddenControllViewTime
{
    [self.timer stop];
    self.timer = [HCWeakTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(hiddenControllViewTimeEvent) userInfo:nil repeats:NO];
}

- (void)setupSelfGesture
{
    UIPinchGestureRecognizer *pin = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(didPinSelf:)];
    [self addGestureRecognizer:pin];
}

- (void)showTvControllView {
    self.tvControllView.hidden = NO;
    
    NSString *type = [self castTypeWithStyle:_tvControllView.style];
    
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didStartCast:)]) {
        [self.delegate videoPlayer:self didStartCast:type];
    }
}

- (void)hiddenTvControllView {
    self.tvControllView.hidden = YES;
    
    [self.tvControllView stopAll];
    
    NSString *type = [self castTypeWithStyle:_tvControllView.style];
    
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didEndCast:)]) {
        [self.delegate videoPlayer:self didEndCast:type];
    }
}

- (NSString *)castTypeWithStyle:(HCTVControllViewStyle)style
{
    NSString *type = nil;
    switch (style) {
        case HCTVControllViewStyleDlna:
            type = @"DLNA投屏";
            break;
        case HCTVControllViewStyleAirPlay:
            type = @"AirPlay投屏";
            break;
        case HCTVControllViewStyleGoogleCast:
            type = @"谷歌投屏";
            break;
        case HCTVControllViewStyleSamsung:
            type = @"三星投屏";
            break;
        default:
            break;
    }
    return type;
}

- (void)setControllViewHidden:(BOOL)hidden
{
    self.controllView.hidden = hidden;
    self.bottomBar.hidden = hidden;
}

- (void)setControllViewAlpha:(CGFloat)alpha
{
    self.controllView.alpha = alpha;
    self.bottomBar.alpha = alpha;
}

#pragma mark AirPlay 投屏 内部方法
/// 初始化进行AirPlay投屏设置
- (void)initSetAirPlay
{
    [g_airPlayVideoPlayer stop];
    g_airPlayVideoPlayer = nil;
    [self setupIsWirelessRouteActive];
}

/// AirPlay投屏设置
- (void)setupIsWirelessRouteActive
{
    if (_url.absoluteString.length && ((!_morePanel && !_tvVc && !_tvControllView)/* || [HCAirplayCastTool isAirPlayOnCast]*/) && self.status != HCPlayerViewStateReadying && self.status != HCPlayerViewStateReadyed) {
        [self playWithUrl:_url];
    }
    
    if ([HCAirplayCastTool isAirPlayOnCast]) {
        // 1.只有url为空可能是，先链接airplay然后，打开播放器的情况，这时不需要执行下面的播放方法，进来时会不用p2pURL播放
        // 2.url不为空，表示先播放，在链接airplay，如果这时是p2p播放，这时要去掉p2pUrl重新播放；
        // 3.self.tvControllView.hidden == YES 保证只执行下面代码一次；
        if (!_url.absoluteString.length) {
            if (self.tvControllView.hidden == NO) {
                return;
            }
            g_airPlayVideoPlayer = self;
            self.tvControllView.style = HCTVControllViewStyleAirPlay;
            self.tvControllView.videoPlayer = self;
            [self showTvControllView];
            return;
        }
        
        if (self.tvControllView.hidden == NO) {
            return;
        }
        if (_urlPlayer.isP2pPlay || ![_castUrl.absoluteString isEqualToString:_url.absoluteString]) {
            if (self.urlPlayer.currentTime > 0) {
                self.airPlayProgress = self.urlPlayer.currentTime;
            }
            NSURL *url = _url;
            [self showLoading];
            __weak typeof(self) weakSelf = self;
            [self playWithUrl:_castUrl forceReload:YES readyComplete:^(HCVideoPlayer *videoPlayer, HCVideoPlayerStatus status) {
                if (status == HCVideoPlayerStatusReadyed) {
                    [weakSelf seekToTime:weakSelf.airPlayProgress autoPlay:YES complete:^(BOOL finished) {
                        weakSelf.progressView.playTime = weakSelf.airPlayProgress;
                        weakSelf.botProgressView.playTime = weakSelf.airPlayProgress;
                    }];
                }
            }];
            _url = url;
        }
        else
        {
            [self playWithUrl:_url];
        }
        
        g_airPlayVideoPlayer = self;
        self.tvControllView.style = HCTVControllViewStyleAirPlay;
        self.tvControllView.videoPlayer = self;
        [self showTvControllView];
    }
    // 1.当从AirPlay投屏状态切换到非AirPlay投屏状态，且_tvControllView还未隐藏的情况，执行以下代码；
    else if (_tvControllView.hidden == NO && _tvControllView.style == HCTVControllViewStyleAirPlay) {
        g_airPlayVideoPlayer = nil;
        [self hiddenTvControllView];
        self.tvControllView.videoPlayer = nil;
        
        if (!_url.absoluteString.length) {
            return;
        }
        if (_urlPlayer.isP2pPlay || ![_castUrl.absoluteString isEqualToString:_url.absoluteString]) {
            if (self.urlPlayer.currentTime > 0) {
                self.airPlayProgress = self.urlPlayer.currentTime;
            }
            [self showLoading];
            __weak typeof(self) weakSelf = self;
            [self playWithUrl:_url forceReload:YES readyComplete:^(HCVideoPlayer *videoPlayer, HCVideoPlayerStatus status) {
                if (status == HCVideoPlayerStatusReadyed) {
                    [weakSelf seekToTime:weakSelf.airPlayProgress autoPlay:YES complete:^(BOOL finished) {
                        weakSelf.progressView.playTime = weakSelf.airPlayProgress;
                        weakSelf.botProgressView.playTime = weakSelf.airPlayProgress;
                    }];
                }
            }];
        }
        else
        {
            [self playWithUrl:_url];
        }
    }
}

- (void)setupAirPlayTVControllViewProgressWithPlayTime:(NSTimeInterval)playTime
{
    if ([HCAirplayCastTool isAirPlayOnCast]) {
        _tvControllView.totalTime = self.progressView.totalTime;
        _tvControllView.loadTime = 0;
        _tvControllView.playTime = playTime;
    }
    else
    {
        _tvControllView.totalTime = 0;
        _tvControllView.loadTime = 0;
        _tvControllView.playTime = 0;
    }
}

#pragma mark - googleCast 内部方法
- (void)switchToRemotePlayback {
    if ([_castUrl isKindOfClass:[NSURL class]] && !_castUrl.absoluteString.length) {
        [self showMsg:@"播放地址不存在" stopPlay:YES autoHidden:YES];
        return;
    }
    [_urlPlayer stop];
    self.tvControllView.style = HCTVControllViewStyleGoogleCast;
    [self showTvControllView];
    [HCGoogleCastTool startRemotePlaybackWithStreamType:GCKMediaStreamTypeBuffered title:_title description:nil studio:nil photo:_photo urlStr:_castUrl.absoluteString];
    
//    [KTHudTool showAlertHudWithText:@"正在投屏中，您可以点击底部栏控制进度条等操作" image:@"alert_success" duration:5 atView:kKeyWindow];
}

- (void)switchToLocalPlayback {
    if ([_url isKindOfClass:[NSURL class]] && !_url.absoluteString.length) {
        [self showMsg:@"播放地址不存在" stopPlay:YES autoHidden:YES];
        return;
    }
    [self playWithUrl:_url];
    [self hiddenTvControllView];
}
@end

