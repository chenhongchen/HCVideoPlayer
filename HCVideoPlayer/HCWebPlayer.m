//
//  HCWebPlayer.m
//  HCVideoPlayer
//
//  Created by chc on 2019/12/14.
//

#import "HCWebPlayer.h"
#import <WebKit/WebKit.h>
#import "UIView+VP.h"
//#import "UIImage+VP.h"
#import "HCVideoPlayerConst.h"
#import "HCAirplayCastTool.h"
#import "HCVideoAdView.h"
#import "HCNavWebController.h"
#import "UIViewController+VP.h"

@interface HCWebPlayer ()<WKNavigationDelegate, WKUIDelegate, HCVideoAdViewDelegate, HCNavWebControllerDelegate>
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) HCWebProgressBar *progressBar;
@property (nonatomic, weak) UIActivityIndicatorView *indecatorView;
@property (nonatomic, weak) UIView *blackBgView;
@property (nonatomic, weak) UIButton *backBtn;
@property (nonatomic, weak) HCVideoAdView *videoAdView;
@end

@implementation HCWebPlayer
#pragma mark - 懒加载
- (WKWebView *)webView
{
    if (_webView == nil) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.allowsInlineMediaPlayback = NO;
        if (@available(iOS 10.0, *)) {
            config.mediaTypesRequiringUserActionForPlayback = YES;
        } else {
            config.mediaPlaybackRequiresUserAction = YES;
        }
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
        [self addSubview:webView];
        _webView = webView;
        webView.navigationDelegate = self;
        webView.UIDelegate = self;
        webView.scrollView.scrollEnabled = NO;
        [self setSubviewsColor:[UIColor blackColor] forView:webView];
    }
    return _webView;
}

- (HCWebProgressBar *)progressBar
{
    if (_progressBar == nil) {
        HCWebProgressBar *progressBar = [[HCWebProgressBar alloc] init];
        [self addSubview:progressBar];
        _progressBar = progressBar;
        progressBar.progressColor = [UIColor colorWithRed:210/255.0 green:233/255.0 blue:250/255.0 alpha:1.0];
    }
    return _progressBar;
}

- (UIActivityIndicatorView *)indecatorView
{
    if (_indecatorView == nil) {
        UIActivityIndicatorView *indecatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [self.blackBgView addSubview:indecatorView];
        _indecatorView = indecatorView;
    }
    return _indecatorView;
}

- (UIView *)blackBgView
{
    if (_blackBgView == nil) {
        UIView *blackBgView = [[UIView alloc] init];
        [self addSubview:blackBgView];
        _blackBgView = blackBgView;
        blackBgView.backgroundColor = [UIColor blackColor];
        blackBgView.hidden = YES;
        
    }
    return _blackBgView;
}

- (UIButton *)backBtn
{
    if (_backBtn == nil) {
        UIButton *backBtn = [[UIButton alloc] init];
        [self addSubview:backBtn];
        _backBtn = backBtn;
        [backBtn addTarget:self action:@selector(didClickBackBtn) forControlEvents:UIControlEventTouchUpInside];
        [backBtn setImage:[UIImage vp_imageWithName:@"vp_back"] forState:UIControlStateNormal];
    }
    return _backBtn;
}

#pragma mark - 外部方法
- (void)setUrl:(NSURL *)url
{
    _url = url;
    [self loadUrl];
}

- (void)setVideoAdsItem:(HCVideoAdsItem *)videoAdsItem
{
    _videoAdsItem = videoAdsItem;
    [self showVideoAd];
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        [self setUpNotification];
        [self.progressBar addObserverForWebView:self.webView];
    }
    return self;
}

- (void)dealloc
{
    [self.progressBar removeObserverForWebView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupFrame];
    [self setupVideoAdViewFrame];
}

- (void)setUpNotification {
    //    [[NSNotificationCenter defaultCenter] addObserver:self
    //                                             selector:@selector(videoStarted:)
    //                                                 name:@"AVPlayerItemBecameCurrentNotification"
    //                                               object:self.view.window];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoZoomOut:)
                                                 name:UIWindowDidBecomeVisibleNotification
                                               object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoZoomIn:)
                                                 name:UIWindowDidBecomeHiddenNotification
                                               object:self.window];
}

#pragma mark - 事件
- (void)didClickBackBtn
{
    if ([self.delegate respondsToSelector:@selector(didClickBackBtnForWebPlayer:)]) {
        [self.delegate didClickBackBtnForWebPlayer:self];
    }
}

#pragma mark - 内部方法
- (void)loadUrl
{
    if ([[UIApplication sharedApplication] canOpenURL:_url]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:_url];
        [self.webView loadRequest:request];
    }
}

- (void)setupFrame
{
    self.webView.frame = self.bounds;
    
    self.blackBgView.frame = self.bounds;
    self.backBtn.frame = CGRectMake(0, 20, 50, 44);
    
    self.indecatorView.vp_centerX = self.blackBgView.vp_width * 0.5;
    self.indecatorView.vp_centerY = self.blackBgView.vp_height * 0.5;
    
    self.progressBar.vp_height = 2;
    self.progressBar.vp_width = self.vp_width;
    self.progressBar.vp_y = 0;
    self.progressBar.vp_x = 0;
    
    [self bringSubviewToFront:self.blackBgView];
    [self bringSubviewToFront:self.backBtn];
}

- (void)setSubviewsColor:(UIColor *)color forView:(UIView *)view
{
    view.backgroundColor = [UIColor blackColor];
    for (UIView *subView in view.subviews) {
        subView.backgroundColor = color;
        [self setSubviewsColor:color forView:subView];
    }
}

#pragma mark - 播放器上广告
/** 显示贴片广告 */
- (void)showVideoAd
{
    if (![HCAirplayCastTool isAirPlayOnCast] && _videoAdsItem.ads.count) {
        
        [_videoAdView removeFromSuperview];
        _videoAdView = nil;
        
        HCVideoAdView *videoAdView = [[HCVideoAdView alloc] init];
        _videoAdView = videoAdView;
        [self addSubview:videoAdView];
        videoAdView.delegate = self;
        videoAdView.adsItem = _videoAdsItem;
        [self setupVideoAdViewFrame];
        //
        videoAdView.showZoom = NO;
    }
}

- (void)setupVideoAdViewFrame {
    _videoAdView.frame = self.bounds;
    [self bringSubviewToFront:_videoAdView];
}

/** 隐藏贴片广告 */
- (void)hiddenVideoAd
{
    [_videoAdView removeFromSuperview];
    _videoAdView = nil;
    _videoAdsItem = nil;
}

- (void)openAdWithAdItem:(HCVideoAdItem *)adItem
{
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
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[UIViewController vp_currentVC] presentViewController:vc animated:NO completion:nil];
        });
    }
}

#pragma mark - WKNavigationDelegate
#pragma mark - 追踪加载过程函数:
/// 2 页面开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self.indecatorView startAnimating];
    self.blackBgView.hidden = NO;
}

/// 4 开始获取到网页内容时返回
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    
}

/// 5 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self.indecatorView stopAnimating];
    self.blackBgView.hidden = YES;
}

/// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
{
    [self.indecatorView stopAnimating];
    self.blackBgView.hidden = YES;
}

#pragma mark - KTVideoAdViewDelegate
- (void)didClickBackBtnForVideoAdView:(HCVideoAdView *)videoAdView
{
    if ([self.delegate respondsToSelector:@selector(didClickBackBtnForWebPlayer:)]) {
        [self.delegate didClickBackBtnForWebPlayer:self];
    }
}

- (void)didClickSkipBtnForVideoAdView:(HCVideoAdView *)videoAdView
{
    [self hiddenVideoAd];
}

- (void)didClickZoomBtnForVideoAdView:(HCVideoAdView *)videoAdView
{
}

- (void)videoAdView:(HCVideoAdView *)videoAdView didClickAdItem:(HCVideoAdItem *)adItem
{
    [self openAdWithAdItem:adItem];
}

- (void)didAdsPlayCompleteForVideoAdView:(HCVideoAdView *)videoAdView
{
    [self hiddenVideoAd];
}

#pragma mark - 通知
- (void)videoStarted:(NSNotification *)notification {
    
}

- (void)videoZoomOut:(NSNotification *)notification
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}

- (void)videoZoomIn:(NSNotification *)notification {
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
}
@end


@interface HCWebProgressBar ()
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) UIView *progressBar;
@end

@implementation HCWebProgressBar
#pragma mark - 懒加载
- (UIView *)progressBar
{
    if (_progressBar == nil) {
        UIView *progressBar = [[UIView alloc] init];
        [self addSubview:progressBar];
        _progressBar = progressBar;
        progressBar.backgroundColor = [UIColor colorWithRed:21/255.0 green:126/255.0 blue:251/255.0 alpha:1.0];
    }
    return _progressBar;
}

#pragma mark - 初始化
- (void)dealloc
{
}

#pragma mark - 外部方法
- (void)addObserverForWebView:(WKWebView *)webView
{
    if (![webView isKindOfClass:[WKWebView class]]) {
        return;
    }
    
    _webView = webView;
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserverForWebView
{
    if (@available(iOS 8.0, *)) {
        if (![_webView isKindOfClass:[WKWebView class]]) {
            return;
        }
    } else {
        // Fallback on earlier versions
    }
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    CGFloat selfWidth = self.bounds.size.width;
    CGRect rect = self.bounds;
    rect.size.width = selfWidth * _progress;
    [UIView animateWithDuration:0.33333 animations:^{
        self.progressBar.frame = rect;
    }];
    if (_progress == 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.333333 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.333333 animations:^{
                self.progressBar.alpha = 0.0;
            } completion:^(BOOL finished) {
                CGRect rect = self.bounds;
                rect.size.width = 0.0;
                self.progressBar.frame = rect;
                self.progress = 0.0;
                self.progressBar.alpha = 1.0;
            }];
        });
    }
}

- (void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    self.progressBar.backgroundColor = _progressColor;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progress = self.webView.estimatedProgress;
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
@end
