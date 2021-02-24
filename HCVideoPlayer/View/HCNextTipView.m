//
//  HCNextTipView.m
//  HCVideoPlayer
//
//  Created by chc on 2019/5/13.
//  Copyright © 2019 chc. All rights reserved.
//

#import "HCNextTipView.h"

@interface HCNextTipView ()
@property (nonatomic, weak) UILabel *tipLabel;
@property (nonatomic, weak) UIButton *cancelBtn;
@property (nonatomic, weak) UIView *hHline;
@end

@implementation HCNextTipView
#pragma mark - 懒加载
- (UILabel *)tipLabel
{
    if (_tipLabel == nil) {
        UILabel *tipLabel = [[UILabel alloc] init];
        [self addSubview:tipLabel];
        _tipLabel = tipLabel;
        tipLabel.font = [UIFont systemFontOfSize:12];
        tipLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tipLabel;
}

- (UIButton *)cancelBtn
{
    if (_cancelBtn == nil) {
        UIButton *cancelBtn = [[UIButton alloc] init];
        [self addSubview:cancelBtn];
        _cancelBtn = cancelBtn;
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
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
    NSString *str = @"秒后播放下一个";
    NSString *msg = [NSString stringWithFormat:@"%@%@", _sec,str];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:msg];
    NSMutableDictionary *dictM = [NSMutableDictionary dictionary];
    dictM[NSForegroundColorAttributeName] = [UIColor colorWithRed:31/255.0 green:147/255.0 blue:234/255.0 alpha:1.0];
    NSRange range = NSMakeRange(0, msg.length);
    [attrStr setAttributes:dictM range:range];
    
    dictM[NSForegroundColorAttributeName] = [UIColor whiteColor];
    range = [msg rangeOfString:str];
    [attrStr setAttributes:dictM range:range];
    self.tipLabel.attributedText = attrStr;
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
    CGFloat width = 157;
    CGFloat height = 38;
    
    self.bounds = CGRectMake(x, y, width, height);
    
    width = 112;
    self.tipLabel.frame = CGRectMake(x, y, width, height);
    
    width = 1.0;
    height = 12;
    x = CGRectGetMaxX(self.tipLabel.frame);
    y = (CGRectGetHeight(self.frame) - height) *0.5;
    self.hHline.frame = CGRectMake(x, y, width, height);
    
    x = CGRectGetMaxX(self.hHline.frame);
    y = 0;
    width = CGRectGetWidth(self.frame) - x;
    height = CGRectGetHeight(self.frame);
    self.cancelBtn.frame = CGRectMake(x, y, width, height);
}

#pragma mark - 事件
- (void)didClickCancelBtn
{
    self.sec = @"0";
    if ([self.delegate respondsToSelector:@selector(didClickCancelBtnForNextTipView:)]) {
        [self.delegate didClickCancelBtnForNextTipView:self];
    }
}
@end
