//
//  HCLoading.m
//  HCVideoPlayer
//
//  Created by chc on 2019/5/9.
//  Copyright © 2019 chc. All rights reserved.
//

#import "HCLoadingView.h"
#import "HCVideoPlayerConst.h"

@interface HCLoadingView ()
@property (nonatomic, weak) UIImageView *loadingIcon;
@end

@implementation HCLoadingView
#pragma mark - 懒加载
- (UIImageView *)loadingIcon
{
    if (_loadingIcon == nil) {
        UIImage *image = [UIImage vp_imageWithName:@"vp_loading"];
        UIImageView *loadingIcon = [[UIImageView alloc] initWithImage:image];
        [self addSubview:loadingIcon];
        _loadingIcon = loadingIcon;
        loadingIcon.hidden = YES;
    }
    return _loadingIcon;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.bounds = self.loadingIcon.bounds;
    }
    return self;
}

#pragma mark - 外部方法
- (void)startAnimating
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.isLoading) {
            return;
        }
        _loadingIcon.hidden = NO;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //默认是顺时针效果，若将fromValue和toValue的值互换，则为逆时针效果
        animation.fromValue = [NSNumber numberWithFloat:0.f];
        animation.toValue = [NSNumber numberWithFloat: M_PI *2];
        animation.duration = 3;
        animation.autoreverses = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.repeatCount = MAXFLOAT; //如果这里想设置成一直自旋转，可以设置为MAXFLOAT，否则设置具体的数值则代表执行多少次
        [self.loadingIcon.layer addAnimation:animation forKey:@"HCLoadingView.loading"];
    });
}

- (void)stopAnimating
{
    _loadingIcon.hidden = YES;
    [self.loadingIcon.layer removeAnimationForKey:@"HCLoadingView.loading"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        _loadingIcon.hidden = YES;
        [self.loadingIcon.layer removeAnimationForKey:@"HCLoadingView.loading"];
    });
}

- (BOOL)isLoading
{
    if ([self.loadingIcon.layer animationForKey:@"HCLoadingView.loading"]) {
        return YES;
    }
    else {
        return NO;
    }
}
@end
