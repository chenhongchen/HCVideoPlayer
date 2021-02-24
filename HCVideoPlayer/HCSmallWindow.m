//
//  HCSmallWindow.m
//
//  Created by chc on 2019/12/27.
//  Copyright © 2019. All rights reserved.
//

#define kSelfW (kVP_isIPad ? 440 : 220)
#define kSelfH (kVP_isIPad ? 248 : 124)
#define kLitte 0.1
#define kKeySmallwindowX @"smallwindowx"
#define kKeySmallwindowY @"smallwindowy"

#import "HCSmallWindow.h"
#import "HCVideoPlayerConst.h"
#import "HCVideoPlayer.h"

@interface HCSmallWindow ()
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIView *coverView;
@property (nonatomic, weak) UIButton *closeBtn;
@property (nonatomic, assign) CGPoint touchBeginPoint;
@property (nonatomic, copy) BOOL (^onClick)(UIView *rootView);
@property (nonatomic, copy) void (^onClose)(UIView *rootView);
@end

@implementation HCSmallWindow

HCSmallWindow *g_smallWindow;
#pragma mark - 懒加载
- (UIView *)contentView
{
    if (_contentView == nil) {
        UIView *contentView = [[UIView alloc] init];
        [self addSubview:contentView];
        _contentView = contentView;
        contentView.clipsToBounds = YES;
        contentView.layer.cornerRadius = 5;
        contentView.backgroundColor = [UIColor blackColor];
    }
    return _contentView;
}

- (UIView *)coverView
{
    if (_coverView == nil) {
        UIView *coverView = [[UIView alloc] init];
        [self addSubview:coverView];
        _coverView = coverView;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didClickCoverView)];
        [coverView addGestureRecognizer:tap];
    }
    return _coverView;
}

- (UIButton *)closeBtn
{
    if (_closeBtn == nil) {
        UIButton *closeBtn = [[UIButton alloc] init];
        [self.coverView addSubview:closeBtn];
        _closeBtn = closeBtn;
        [closeBtn setImage:[UIImage vp_imageWithName:@"vp_psw_close"] forState:UIControlStateNormal];
        [closeBtn addTarget:self action:@selector(didClickCloseBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

#pragma mark - 外部方法
+ (HCSmallWindow *)curSmallWindow
{
    return g_smallWindow;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [HCSmallWindow removeSmallWindow];
        
        g_smallWindow = self;
        
        [self setupSelfUI];
        [self contentView];
        [self coverView];
    }
    return self;
}

+ (instancetype)showWithRootView:(UIView *)rootView onClick:(BOOL (^)(UIView *rootView))onClick onClose:(void (^)(UIView *rootView))onClose
{
    HCSmallWindow *window = [[self alloc] init];
    [window.contentView addSubview:rootView];
    window.onClick = onClick;
    window.onClose = onClose;
    return window;
}

+ (void)removeSmallWindow
{
    if (g_smallWindow == nil) {
        return;
    }
    CGPoint point = g_smallWindow ? g_smallWindow.frame.origin : CGPointZero;
    [[NSUserDefaults standardUserDefaults] setDouble:point.x forKey:kKeySmallwindowX];
    [[NSUserDefaults standardUserDefaults] setDouble:point.y forKey:kKeySmallwindowY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    g_smallWindow.hidden = YES;
    [g_smallWindow removeFromSuperview];
    g_smallWindow = nil;
}

- (void)setupSelfUI {
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    // 设置阴影偏移量
    self.layer.shadowOffset = CGSizeMake(0,0);
    // 设置阴影透明度
    self.layer.shadowOpacity = 0.6;
    // 设置阴影半径
    self.layer.shadowRadius = 5;
    self.clipsToBounds = NO;
    
    self.windowLevel = UIWindowLevelAlert;
    self.hidden = NO;
    self.layer.cornerRadius = 5;
    self.backgroundColor = [UIColor clearColor];
}

- (void)setFrame:(CGRect)frame
{
    frame.size.width = kSelfW;
    frame.size.height = kSelfH;
    
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat maxX = screenW - kSelfW;
    CGFloat maxY = screenH - kSelfH;
    
    if (frame.origin.x <= 0 && frame.origin.y <= 0) {
        frame.origin.x = [[NSUserDefaults standardUserDefaults] doubleForKey:kKeySmallwindowX];
        frame.origin.y = [[NSUserDefaults standardUserDefaults] doubleForKey:kKeySmallwindowY];
    }
    
    if (frame.origin.x <= 0 && frame.origin.y <= 0) {
        frame.origin.x = kVP_ScreenWidth - kSelfW;
        frame.origin.y = kVP_ScreenHeight - kSelfH - kVP_iPhoneXSafeBottomHeight - 100;
    }
    
    if (frame.origin.x < 0) {
        frame.origin.x = kLitte;
    }
    if (frame.origin.y < 0) {
        frame.origin.y = kLitte;
    }
    if (frame.origin.x > maxX) {
        frame.origin.x = maxX;
    }
    if (frame.origin.y > maxY) {
        frame.origin.y = maxY;
    }
    
    [super setFrame:frame];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    self.contentView.subviews.firstObject.frame = self.contentView.bounds;
    
    self.coverView.frame = self.bounds;
    
    [self.closeBtn sizeToFit];
    self.closeBtn.vp_width = self.closeBtn.vp_width + 12;
    self.closeBtn.vp_height = self.closeBtn.vp_height + 12;
    self.closeBtn.vp_x = self.vp_width - self.closeBtn.vp_width;
    self.closeBtn.vp_y = 0;
}

#pragma mark - 事件
- (void)didClickCoverView
{
    BOOL isClose = NO;
    if (self.onClick) {
        isClose = self.onClick(self.contentView.subviews.firstObject);
    }
    
    if (isClose) {
        [HCSmallWindow removeSmallWindow];
    }
}

- (void)didClickCloseBtn {
    if (self.onClose) {
        self.onClose(self.contentView.subviews.firstObject);
    }
    [HCSmallWindow removeSmallWindow];
}

#pragma mark - 手势
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    self.touchBeginPoint = [self pointWithTouches:touches];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self justPosition];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint currentPoint = [self pointWithTouches:touches];
    CGFloat sx = currentPoint.x - self.touchBeginPoint.x;
    CGFloat sy = currentPoint.y - self.touchBeginPoint.y;
    CGFloat x = self.vp_centerX + sx;
    CGFloat y = self.vp_centerY + sy;
    self.center = CGPointMake(x, y);
    self.touchBeginPoint = currentPoint;
}

// 获取触摸点
- (CGPoint)pointWithTouches:(NSSet *)touches
{
    UITouch *touch = [touches anyObject];
    return [touch locationInView:[UIView vp_rootWindow]];
}

- (void)justPosition {
    CGPoint center = self.center;
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    CGFloat maxCenterX = screenW - kSelfW * 0.5;
    CGFloat maxCenterY = screenH - kSelfH * 0.5;
    BOOL needJust = NO;
    if (center.x < kSelfW * 0.5) {
        center.x = kSelfW * 0.5 + kLitte;
        needJust = YES;
    }
    if (center.y < kSelfH * 0.5) {
        center.y = kSelfH * 0.5 + kLitte;
        needJust = YES;
    }
    if (center.x > maxCenterX) {
        center.x = maxCenterX;
        needJust = YES;
    }
    if (center.y > maxCenterY) {
        center.y = maxCenterY;
        needJust = YES;
    }
    if (needJust == NO) {
        return;
    }
    [UIView animateWithDuration:0.233 animations:^{
        self.center = center;
    }];
}
@end
