//
//  HCVediosCastManualController.m
//  FLAnimatedImage
//
//  Created by chc on 2019/10/19.
//

#import "HCVediosCastManualController.h"
#import "FLAnimatedImageView.h"
#import "FLAnimatedImage.h"
#import "HCVideoPlayerConst.h"

@interface HCVediosCastManualController ()
@property (nonatomic, weak) UIView *customNavBar;
@property (nonatomic, weak) UIButton *navBarCloseBtn;
@property (nonatomic, weak) FLAnimatedImageView *imageView;
@end

@implementation HCVediosCastManualController

#pragma mark - 懒加载
- (FLAnimatedImageView *)imageView
{
    if (_imageView == nil) {
        FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
        [self.view addSubview:imageView];
        _imageView = imageView;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        NSString *dirPath = [[NSBundle mainBundle] pathForResource:@"HCVideoPlayer" ofType:@"bundle"];
        NSString *filePath = [dirPath stringByAppendingPathComponent:@"vp_vedios_castManual.gif"];
        NSData *imageData = [NSData dataWithContentsOfFile:filePath];
        imageView.animatedImage = [FLAnimatedImage animatedImageWithGIFData:imageData];
    }
    return _imageView;
}

- (UIView *)customNavBar
{
    if (_customNavBar == nil) {
        UIView *customNavBar = [[UIView alloc] init];
        [self.view addSubview:customNavBar];
        _customNavBar = customNavBar;
    }
    return _customNavBar;
}

- (UIButton *)navBarCloseBtn
{
    if (_navBarCloseBtn == nil) {
        UIButton *navBarCloseBtn = [[UIButton alloc] init];
        [self.customNavBar addSubview:navBarCloseBtn];
        _navBarCloseBtn = navBarCloseBtn;
        [navBarCloseBtn setImage:[UIImage vp_imageWithName:@"vp_close"] forState:UIControlStateNormal];
        [navBarCloseBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    }
    return _navBarCloseBtn;
}

#pragma mark - 初始化
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.fd_prefersNavigationBarHidden = YES;
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self setupFrame];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:animated];;
}

#pragma mark - 事件
- (void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 内部方法
- (void)setupFrame
{
    CGFloat width = kVP_ScreenWidth;
    CGFloat height = 44;
    CGFloat x = 0;
    CGFloat y = kVP_iPhoneXSafeTopHeight;
    self.customNavBar.frame = CGRectMake(x, y, width, height);
    
    width = self.navBarCloseBtn.imageView.image.size.width + 40;
    height = self.customNavBar.vp_height;
    x = kVP_ScreenWidth - width - ((kVP_ScreenWidth > kVP_ScreenHeight) ? kVP_iPhoneXSafeBottomHeight : 0);
    y = 0;
    self.navBarCloseBtn.frame = CGRectMake(x, y, width, height);
    
    self.imageView.frame = self.view.bounds;
    
    [self.view sendSubviewToBack:self.imageView];
}

@end
