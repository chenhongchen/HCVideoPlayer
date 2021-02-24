//
//  HCOrientationsController.m
//  HCVideoPlayer
//
//  Created by chc on 2017/11/28.
//  Copyright © 2017年 chc. All rights reserved.
//

#import "HCOrientController.h"
#import "HCVideoPlayerConst.h"
#import "HCVideoPlayer.h"

@interface HCOrientController ()
@end

@implementation HCOrientController

#pragma mark - 初始化
- (instancetype)init
{
    if (self = [super init]) {
        self.orientation = UIDeviceOrientationLandscapeLeft;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    [self stupNavi];
}

- (void)stupNavi
{
    UINavigationBar *bar = self.navigationController.navigationBar;
    
    // 设置bar背景
    [bar setBackgroundImage:[UIImage vp_imageWithColor:kVP_ColorWithHexValueA(0xFFFFFF, 1.0)] forBarMetrics:UIBarMetricsDefault];
    UIImage *shadowImage = [UIImage vp_imageWithColor:kVP_HRectangleSeparatorColor];
    [bar setShadowImage:shadowImage];
}

//- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures
//{
//    return UIRectEdgeAll;
//}
- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    for (HCVideoPlayer *player in [UIView vp_rootWindow].subviews) {
        if ([player isKindOfClass:[HCVideoPlayer class]]) {
            [[UIView vp_rootWindow] bringSubviewToFront:player];
            break;
        }
    }
}

- (void)dealloc
{
    VPLog(@"dealloc - HCOrientController");
    if (self.destroyBlock) {
        self.destroyBlock();
    }
}

#pragma mark - UIViewControllerRotation
- (BOOL)shouldAutorotate
{
    VPLog(@"shouldAutorotate");
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
//    VPLog(@"UIInterfaceOrientationMaskLandscape");
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
//    VPLog(@"preferredInterfaceOrientationForPresentation %ld", self.orientation);
    return _orientation;
}

#pragma mark -
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([self.delegate respondsToSelector:@selector(willRotateToInterfaceOrientation:duration:)]) {
        [self.delegate willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}

//获取旋转中的状态
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if ([self.delegate respondsToSelector:@selector(willAnimateRotationToInterfaceOrientation:duration:)]) {
        [self.delegate willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    }
}
//屏幕旋转完成的状态
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    if ([self.delegate respondsToSelector:@selector(didRotateFromInterfaceOrientation:)]) {
        [self.delegate didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    }
}

@end
