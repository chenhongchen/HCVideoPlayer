//
//  HCNavWebController.m
//  FLAnimatedImage
//
//  Created by chc on 2019/10/18.
//

#import "HCNavWebController.h"
#import "AppDelegate+VP.h"
#import "HCNavigationBarView.h"
#import "HCWebView.h"
#import "HCVideoPlayerConst.h"

@interface HCNavWebController ()<HCNavigatioBarViewDelegate>
@property (nonatomic, weak) HCNavigationBarView *navBar;
@property (nonatomic, weak) HCWebView *webView;

@end

@implementation HCNavWebController

#pragma mark - 懒加载
- (HCNavigationBarView *)navBar
{
    if (_navBar == nil) {
        HCNavigationBarView *navBar = [[HCNavigationBarView alloc] init];
        [self.view addSubview:navBar];
        _navBar = navBar;
        navBar.title = self.title;
        navBar.delegate = self;
    }
    return _navBar;
}

- (HCWebView *)webView
{
    if (_webView == nil) {
        HCWebView *webView = [[HCWebView alloc] init];
        [self.view addSubview:webView];
        _webView = webView;
        webView.alwaysShowControllBar = YES;
    }
    return _webView;
}

#pragma mark - 初始化
- (void)viewDidLoad
{
    [super viewDidLoad];
    // 播放广告方向
//    [AppDelegate setUseAppRotationMethod:NO];// 用app的旋转配置方法
//    [KTGlobal shareGlobal].allowOrientation = UIInterfaceOrientationMaskAllButUpsideDown;
    self.view.backgroundColor = [UIColor whiteColor];
    self.webView.url = self.url;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self setupFrame];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    kVP_StatusBarHidden(NO);
}

#pragma mark - HCNavigatioBarDelegate
- (void)didClickBackBtnForNavigationBarView:(HCNavigationBarView *)navigationBarView
{
    // 播放广告方向
//    [AppDelegate setUseAppRotationMethod:YES]; // 用播放器框架的旋转配置方法
//    [KTGlobal shareGlobal].allowOrientation = UIInterfaceOrientationMaskPortrait;
    
    if ([self.delegate respondsToSelector:@selector(didClickBackBtnForNavWebController:)]) {
        [self.delegate didClickBackBtnForNavWebController:self];
    }
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - 内部方法
- (void)setupFrame
{
    self.navBar.vp_height = kVP_NavigationBarHeight;
    self.navBar.vp_width = kVP_ScreenWidth;
    
    self.webView.vp_y = kVP_NavigationBarHeight;
    self.webView.vp_width = kVP_ScreenWidth;
    self.webView.vp_height = kVP_ScreenHeight - kVP_NavigationBarHeight;
}

#pragma mark - UIViewControllerRotation
- (BOOL)shouldAutorotate
{
    VPLog(@"shouldAutorotate");
    return NO;
    // 播放广告方向
//    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
    // 播放广告方向
//    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
    // 播放广告方向
//    return _presentationOrientation;
}

@end
