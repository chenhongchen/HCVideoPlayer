//
//  HCFastForwardAndbackView.m
//  HCVideoPlayer
//
//  Created by chc on 2018/11/12.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "HCFastForwardAndBackView.h"
#import "HCArcEdgeView.h"
#import "HCVideoPlayerConst.h"

@interface HCFastForwardAndBackView ()
@property (nonatomic, weak) HCArcEdgeView *leftView;
@property (nonatomic, weak) HCArcEdgeView *rightView;
@property (nonatomic, weak) UILabel *leftTimeLabel;
@property (nonatomic, weak) UILabel *rightTimeLabel;
@property (nonatomic, weak) UIImageView *leftArrowIcon;
@property (nonatomic, weak) UIImageView *rightArrowIcon;
@property (nonatomic, strong) HCWeakTimer *leftTimer;
@property (nonatomic, strong) HCWeakTimer *rightTimer;

@property (nonatomic, assign) CGFloat leftTime;
@property (nonatomic, assign) CGFloat rightTime;

@end

@implementation HCFastForwardAndBackView
#pragma mark - 懒加载
- (HCArcEdgeView *)leftView
{
    if (_leftView == nil) {
        HCArcEdgeView *leftView = [[HCArcEdgeView alloc] init];
        [self addSubview:leftView];
        _leftView = leftView;
        leftView.backgroundColor = kVP_Color(31, 147, 234, 0.8);
        leftView.type = HCArcEdgeViewTypeRight;
        leftView.alpha = 0.0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapLeftView)];
        [leftView addGestureRecognizer:tap];
    }
    return _leftView;
}

- (HCArcEdgeView *)rightView
{
    if (_rightView == nil) {
        HCArcEdgeView *rightView = [[HCArcEdgeView alloc] init];
        [self addSubview:rightView];
        _rightView = rightView;
        rightView.backgroundColor = kVP_Color(31, 147, 234, 0.8);
        rightView.type = HCArcEdgeViewTypeLeft;
        rightView.alpha = 0.0;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapRightView)];
        [rightView addGestureRecognizer:tap];
    }
    return _rightView;
}

- (UILabel *)leftTimeLabel
{
    if (_leftTimeLabel == nil) {
        UILabel *leftTimeLabel = [[UILabel alloc] init];
        [self.leftView addSubview:leftTimeLabel];
        _leftTimeLabel = leftTimeLabel;
        leftTimeLabel.font = [UIFont systemFontOfSize:22];
        leftTimeLabel.textColor = [UIColor whiteColor];
        leftTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _leftTimeLabel;
}

- (UILabel *)rightTimeLabel
{
    if (_rightTimeLabel == nil) {
        UILabel *rightTimeLabel = [[UILabel alloc] init];
        [self.rightView addSubview:rightTimeLabel];
        _rightTimeLabel = rightTimeLabel;
        rightTimeLabel.font = [UIFont systemFontOfSize:22];
        rightTimeLabel.textColor = [UIColor whiteColor];
        rightTimeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _rightTimeLabel;
}

- (UIImageView *)leftArrowIcon
{
    if (_leftArrowIcon == nil) {
        UIImageView *leftArrowIcon = [[UIImageView alloc] init];
        [self.leftView addSubview:leftArrowIcon];
        _leftArrowIcon = leftArrowIcon;
        leftArrowIcon.image = [UIImage vp_imageWithName:@"vp_fastBack"];
    }
    return _leftArrowIcon;
}

- (UIImageView *)rightArrowIcon
{
    if (_rightArrowIcon == nil) {
        UIImageView *rightArrowIcon = [[UIImageView alloc] init];
        [self.rightView addSubview:rightArrowIcon];
        _rightArrowIcon = rightArrowIcon;
        rightArrowIcon.image = [UIImage vp_imageWithName:@"vp_fastForward"];
    }
    return _rightArrowIcon;
}

#pragma mark - 外部方法
- (void)showLeft
{
    self.userInteractionEnabled = YES;
    [_leftTimer stop];
    _leftTimer = [HCWeakTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(leftTimeEvent) userInfo:nil repeats:NO];
    [self.leftView.layer removeAllAnimations];
    [UIView animateWithDuration:0.1 animations:^{
        self.leftView.alpha = 1;
    }];
    
    _leftTime += 10;
    NSString *leftTimeStr = [NSString stringWithFormat:@"快退%0.0f秒", _leftTime];
    self.leftTimeLabel.text = leftTimeStr;
}

- (void)showRight
{
    self.userInteractionEnabled = YES;
    [_rightTimer stop];
    _rightTimer = [HCWeakTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(rightTimeEvent) userInfo:nil repeats:NO];
    [self.rightView.layer removeAllAnimations];
    [UIView animateWithDuration:0.1 animations:^{
        self.rightView.alpha = 1;
    }];
    
    _rightTime += 10;
    NSString *rightTimeStr = [NSString stringWithFormat:@"快进%0.0f秒", _rightTime];
    self.rightTimeLabel.text = rightTimeStr;
}

#pragma mark - 时间
- (void)leftTimeEvent
{
    self.userInteractionEnabled = NO;
    if ([self.delegate respondsToSelector:@selector(fastForwardAndBackView:fastTime:)]) {
        [self.delegate fastForwardAndBackView:self fastTime:-_leftTime];
    }
    _leftTime = 0;
    
    [UIView animateWithDuration:0.1 animations:^{
        self.leftView.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}

- (void)rightTimeEvent
{
    self.userInteractionEnabled = NO;
    if ([self.delegate respondsToSelector:@selector(fastForwardAndBackView:fastTime:)]) {
        [self.delegate fastForwardAndBackView:self fastTime:_rightTime];
    }
    _rightTime = 0;
    [UIView animateWithDuration:0.1 animations:^{
        self.rightView.alpha = 0;
    } completion:^(BOOL finished) {
    }];
}

#pragma mark - 事件
- (void)didTapLeftView
{
    [self showLeft];
}

- (void)didTapRightView
{
    [self showRight];
}

- (void)didTapSelfView
{
    
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.userInteractionEnabled = NO;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSelfView)];
        [self addGestureRecognizer:singleTap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapSelfView)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
        
        [singleTap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat selfW = self.bounds.size.width;
    CGFloat selfH = self.bounds.size.height;
//    CGFloat halfSelfW = selfW * 0.5;
    CGFloat fullScreenSafeArea = (kVP_IS_FullScreen ? 34 : 0);
    CGFloat contentViewW = 130;
    CGFloat arcEdgeViewW = contentViewW + fullScreenSafeArea;
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = arcEdgeViewW;
    CGFloat height = selfH;
    self.leftView.frame = CGRectMake(x, y, width, height);
    
    x = selfW - arcEdgeViewW;
    self.rightView.frame = CGRectMake(x, y, width, height);
    
    x = 0 + fullScreenSafeArea;
    width = contentViewW;
    height = 30;
    y = (selfH - (height + 10 + self.leftArrowIcon.image.size.height)) * 0.5;
    self.leftTimeLabel.frame = CGRectMake(x, y, width, height);
    
    width = self.leftArrowIcon.image.size.width;
    height = self.leftArrowIcon.image.size.height;
    x = (contentViewW - width) * 0.5 + fullScreenSafeArea;
    y = CGRectGetMaxY(self.leftTimeLabel.frame) + 10;
    self.leftArrowIcon.frame = CGRectMake(x, y, width, height);
    
    x = 0;
    width = contentViewW;
    height = 30;
    y = (selfH - (height + 10 + self.rightArrowIcon.image.size.height)) * 0.5;
    self.rightTimeLabel.frame = CGRectMake(x, y, width, height);
    
    width = self.rightArrowIcon.image.size.width;
    height = self.rightArrowIcon.image.size.height;
    x = (contentViewW - width) * 0.5;
    y = CGRectGetMaxY(self.rightTimeLabel.frame) + 10;
    self.rightArrowIcon.frame = CGRectMake(x, y, width, height);
}

@end
