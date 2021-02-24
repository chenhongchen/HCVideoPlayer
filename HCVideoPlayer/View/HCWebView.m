//
//  HCWebView.m
//  FLAnimatedImage
//
//  Created by chc on 2019/10/18.
//

#import "HCWebView.h"
#import <WebKit/WebKit.h>
#import "HCWebViewProgressBar.h"
#import "HCVideoPlayerConst.h"

@interface HCWebView ()<WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate>
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) HCWebViewProgressBar *progressBar;
@property (nonatomic, weak) UIView *controllBar;
@property (nonatomic, weak) UIButton *goBackBtn;
@property (nonatomic, weak) UIButton *goForwardBtn;
/// 遮罩（拦截 去safari打开）
@property(nonatomic,weak) UIButton *maskView;
@end

@implementation HCWebView

#pragma mark - 懒加载
- (WKWebView *)webView
{
    if (_webView == nil) {
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        
        // h5内嵌播放
        config.allowsInlineMediaPlayback = YES;
        
        // 表示音视频的播放不需要用户手势触发, 即为自动播放
        if (@available(iOS 10.0, *)) {
            config.mediaTypesRequiringUserActionForPlayback = WKAudiovisualMediaTypeNone;
        } else {
            config.mediaPlaybackRequiresUserAction = NO;
        }
        
        WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, kVP_ScreenWidth, 0) configuration:config];
        [self addSubview:webView];
        _webView = webView;
        webView.navigationDelegate = self;
        webView.UIDelegate = self;
        webView.scrollView.delegate = self;
        //开启手势触摸
        webView.allowsBackForwardNavigationGestures = YES;
    }
    return _webView;
}

- (HCWebViewProgressBar *)progressBar
{
    if (_progressBar == nil) {
        HCWebViewProgressBar *progressBar = [[HCWebViewProgressBar alloc] init];
        [self.webView addSubview:progressBar];
        _progressBar = progressBar;
        progressBar.progressColor = kVP_ColorWithHexValueA(0xD2E9FA,1);
    }
    return _progressBar;
}

- (UIView *)controllBar
{
    if (_controllBar == nil) {
        UIView *controllBar = [[UIView alloc] init];
        [self addSubview:controllBar];
        _controllBar = controllBar;
        controllBar.backgroundColor = [UIColor whiteColor];
    }
    return _controllBar;
}

- (UIButton *)goBackBtn
{
    if (_goBackBtn == nil) {
        UIButton *goBackBtn = [[UIButton alloc] init];
        [self.controllBar addSubview:goBackBtn];
        _goBackBtn = goBackBtn;
        goBackBtn.selected = YES;
        UIImage *image = [UIImage vp_imageWithName:@"web_goback"];
        UIImage *norImage = [image vp_imageMaskWithColor:kVP_ColorWithHexValueA(0x000000,1)];
        UIImage *disImage = [image vp_imageMaskWithColor:kVP_ColorWithHexValueA(0xB3B3B3,1)];
        [goBackBtn setImage:norImage forState:UIControlStateNormal];
        [goBackBtn setImage:disImage forState:UIControlStateSelected];
        [goBackBtn addTarget:self action:@selector(didClickGoBackBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goBackBtn;
}

- (UIButton *)goForwardBtn
{
    if (_goForwardBtn == nil) {
        UIButton *goForwardBtn = [[UIButton alloc] init];
        [self.controllBar addSubview:goForwardBtn];
        _goForwardBtn = goForwardBtn;
        goForwardBtn.selected = YES;
        UIImage *image = [UIImage vp_imageWithName:@"web_goforword"];
        UIImage *norImage = [image vp_imageMaskWithColor:kVP_ColorWithHexValueA(0x000000,1)];
        UIImage *disImage = [image vp_imageMaskWithColor:kVP_ColorWithHexValueA(0xB3B3B3,1)];
        [goForwardBtn setImage:norImage forState:UIControlStateNormal];
        [goForwardBtn setImage:disImage forState:UIControlStateSelected];
        [goForwardBtn addTarget:self action:@selector(didClickGoForwardBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _goForwardBtn;
}

- (UIButton *)maskView
{
    if(_maskView == nil) {
        UIButton *maskView = [[UIButton alloc] init];
        [self addSubview:maskView];
        _maskView = maskView;
        maskView.hidden = YES;
        [maskView addTarget:self action:@selector(didClickMaskView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _maskView;
}

#pragma mark - 外部方法
- (void)setUrl:(NSURL *)url
{
    _url = url;
    [self loadUrl];
}

- (void)setJump_url:(NSURL *)jump_url
{
    _jump_url = jump_url;
    self.maskView.hidden = !_jump_url;
}

- (void)setIsConsideSafeBottom:(BOOL)isConsideSafeBottom
{
    _isConsideSafeBottom = isConsideSafeBottom;
    [self setupFrame];
}

- (void)reload
{
    [_webView reload];
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
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
    [self bringSubviewToFront:self.controllBar];
}

- (void)loadUrl
{
    if ([[UIApplication sharedApplication] canOpenURL:_url]) {
        NSURLRequest *request = [NSURLRequest requestWithURL:_url];
        [self.webView loadRequest:request];
    }
}

- (void)setupFrame
{
    self.progressBar.vp_height = 2;
    self.progressBar.vp_width = kVP_ScreenWidth;
    self.progressBar.vp_y = 0;
    self.progressBar.vp_x = 0;
    
    self.controllBar.vp_width = kVP_ScreenWidth;
    self.controllBar.vp_height = 44 + (_isConsideSafeBottom ? kVP_iPhoneXSafeBottomHeight : 0);
    self.controllBar.vp_x = 0;
    self.controllBar.vp_y = self.vp_height - (_alwaysShowControllBar ? self.controllBar.vp_height : 0);
    
    self.webView.vp_y = 0;
    self.webView.vp_width = kVP_ScreenWidth;
    self.webView.vp_height = self.vp_height - (_alwaysShowControllBar ? self.controllBar.vp_height : 0);
    
    CGFloat width = 100;
    self.goBackBtn.vp_x = (self.controllBar.vp_width - 2 * 100) * 0.5;
    self.goBackBtn.vp_y = 0;
    self.goBackBtn.vp_width = width;
    self.goBackBtn.vp_height = 44;
    
    self.goForwardBtn.vp_x = CGRectGetMaxX(self.goBackBtn.frame);
    self.goForwardBtn.vp_y = 0;
    self.goForwardBtn.vp_width = width;
    self.goForwardBtn.vp_height = 44;
    
    self.maskView.frame = self.bounds;
    
    [self bringSubviewToFront:self.controllBar];
    [self bringSubviewToFront:self.maskView];
}

#pragma mark - WKNavigationDelegate
#pragma mark - 追踪加载过程函数:
/// 2 页面开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    [self setupControllStatus];
}

/// 4 开始获取到网页内容时返回
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation
{
    [self setupControllStatus];
}

/// 5 页面加载完成之后调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    [self setupControllStatus];
}

/// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
{
    [self setupControllStatus];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    // 如果是跳转一个新页面
    if (navigationAction.targetFrame == nil) {
        [webView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (_alwaysShowControllBar) {
        return;
    }
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    if (translation.y>0) {
        //        VPLog(@"向下滑动");
        [UIView animateWithDuration:0.333333 animations:^{
            self.controllBar.vp_y = self.vp_height - self.controllBar.vp_height;
        }];
    } else if(translation.y<0) {
        [UIView animateWithDuration:0.333333 animations:^{
            self.controllBar.vp_y = self.vp_height;
        }];
    }
    
    [self bringSubviewToFront:self.controllBar];
}

#pragma mark - 事件
- (void)didClickGoBackBtn
{
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }
    else
    {
        self.goBackBtn.selected = YES;
    }
}

- (void)didClickGoForwardBtn
{
    if (self.webView.canGoForward) {
        [self.webView goForward];
    }
    else
    {
        self.goForwardBtn.selected = YES;
    }
}

- (void)didClickMaskView
{
    if (_jump_url) {
        if ([[UIApplication sharedApplication] canOpenURL:_jump_url]) {
            [[UIApplication sharedApplication] openURL:_jump_url];
        }
    }
}

#pragma mark - 内部方法
- (void)setupControllStatus
{
    self.goBackBtn.selected = !self.webView.canGoBack;
    self.goForwardBtn.selected = !self.webView.canGoForward;
}

@end
