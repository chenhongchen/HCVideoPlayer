//
//  HCVideoAdJumpView.m
//
//  Created by chc on 2019/5/24.
//  Copyright © 2019. All rights reserved.
//

#import "HCVideoAdJumpView.h"

@interface HCVideoAdJumpView ()
@property (nonatomic, weak) UILabel *tipLabel;
@property (nonatomic, weak) UIButton *cancelBtn;
@property (nonatomic, weak) UIView *hHline;
@end

@implementation HCVideoAdJumpView
#pragma mark - 懒加载
- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        UILabel *tipLabel = [[UILabel alloc] init];
        [self addSubview:tipLabel];
        _tipLabel = tipLabel;
        tipLabel.font = [UIFont systemFontOfSize:14];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        tipLabel.textColor = [UIColor whiteColor];
    }
    return _tipLabel;
}

- (UIButton *)cancelBtn
{
    if (_cancelBtn == nil) {
        UIButton *cancelBtn = [[UIButton alloc] init];
        [self addSubview:cancelBtn];
        _cancelBtn = cancelBtn;
        [cancelBtn setTitle:@"跳过广告" forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [cancelBtn addTarget:self action:@selector(didClickCancelBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIView *)hHline
{
    if (_hHline == nil) {
        UIView *hLine = [[UIView alloc] init];
        [self addSubview:hLine];
        _hHline = hLine;
        hLine.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.8];
    }
    return _hHline;
}

#pragma mark - 外部方法
- (void)setSec:(NSString *)sec
{
    _sec = sec;
    if (sec.integerValue <= 0) {
        self.hidden = YES;
        return;
    }
    self.hidden = NO;
    NSString *msg = [NSString stringWithFormat:@"%@", _sec];
    self.tipLabel.text = msg;
    [self setupFrame];
}

- (void)setCanJump:(BOOL)canJump
{
    _canJump = canJump;
    [self setupFrame];
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.layer.cornerRadius = 4;
        self.clipsToBounds = YES;
        self.hidden = YES;
        [self setupFrame];
    }
    return self;
}

- (void)setupFrame
{
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat width = 0;
    CGFloat height = 0;
    
    if (_canJump) {
        [self.tipLabel sizeToFit];
        width = self.tipLabel.bounds.size.width;
        height = 38;
        x = 12;
        y = 0;
        self.tipLabel.frame = CGRectMake(x, y, width, height);
        
        width = 1.0;
        height = 12;
        x = CGRectGetMaxX(self.tipLabel.frame) + 8;
        y = (CGRectGetHeight(self.frame) - height) *0.5;
        self.hHline.frame = CGRectMake(x, y, width, height);
        
        [self.cancelBtn sizeToFit];
        x = CGRectGetMaxX(self.hHline.frame) + 8;
        y = 0;
        width = self.cancelBtn.bounds.size.width;
        height = 38;
        self.cancelBtn.frame = CGRectMake(x, y, width, height);
        
        width = CGRectGetMaxX(self.cancelBtn.frame) + 12;
        self.bounds = CGRectMake(0, 0, width, height);
    }
    else {
        width = 38;
        height = 38;
        x = 0;
        y = 0;
        self.tipLabel.frame = CGRectMake(x, y, width, height);
        
        width = CGRectGetMaxX(self.tipLabel.frame);
        self.bounds = CGRectMake(0, 0, width, height);
    }
}

#pragma mark - 事件
- (void)didClickCancelBtn
{
    self.sec = @"0";
    if ([self.delegate respondsToSelector:@selector(didClickJumpBtnForAdJumpView:)]) {
        [self.delegate didClickJumpBtnForAdJumpView:self];
    }
}
@end
