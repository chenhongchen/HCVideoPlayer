//
//  HCMsgBtnPanel.m
//  HCVideoPlayer
//
//  Created by chc on 2019/5/14.
//  Copyright © 2019 chc. All rights reserved.
//

#import "HCMsgBtnPanel.h"
#import "HCVideoPlayerConst.h"

@interface HCMsgBtnPanel ()
@property (nonatomic, copy) NSString *type;
@property (nonatomic, weak) UILabel *msgLabel;
@property (nonatomic, weak) UIButton *okBtn;
@property (nonatomic, copy) ClickedOkBtnBLC clickedOkBtn;
@end

@implementation HCMsgBtnPanel

#pragma mark - 懒加载

- (UILabel *)msgLabel
{
    if (_msgLabel == nil) {
        UILabel *msgLabel = [[UILabel alloc] init];
        [self addSubview:msgLabel];
        _msgLabel = msgLabel;
        msgLabel.textAlignment = NSTextAlignmentCenter;
        msgLabel.numberOfLines = 1;
        msgLabel.font = [UIFont systemFontOfSize:14];
        msgLabel.textColor = [UIColor whiteColor];
    }
    return _msgLabel;
}

- (UIButton *)okBtn
{
    if (_okBtn == nil) {
        UIButton *okBtn = [[UIButton alloc] init];
        [self addSubview:okBtn];
        _okBtn = okBtn;
        okBtn.clipsToBounds = YES;
        okBtn.backgroundColor = kVP_Color(255, 255, 255, 0.2);
        okBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [okBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [okBtn addTarget:self action:@selector(didClickOkBtn) forControlEvents:UIControlEventTouchUpInside];
    }
    return _okBtn;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kVP_Color(0, 0, 0, 0.75);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selfTap)];
        [self addGestureRecognizer:tap];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selfDoubleTap)];
        doubleTap.numberOfTapsRequired = 2;
        [self addGestureRecognizer:doubleTap];
    }
    return self;
}

- (void)dealloc
{
    VPLog(@"dealloc - HCMsgBtnPanel");
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupFrame];
}

- (void)setupFrame
{
    CGFloat selfW = self.bounds.size.width;
    CGFloat selfH = self.bounds.size.height;
    
    CGFloat padding = 10;
    CGFloat margin = 15;
    
    CGFloat msgLabelW = selfW - margin - margin;
    CGFloat msgLabelH = 20;
    
    CGFloat okBtnW = 96;
    CGFloat okBtnH = 36;
    
    CGFloat totalH = msgLabelH + okBtnH + padding;
    
    CGFloat y = (selfH - totalH) * 0.5;
    CGFloat x = margin;
    self.msgLabel.frame = CGRectMake(x, y, msgLabelW, msgLabelH);
    
    x = (selfW - okBtnW) * 0.5;
    y = CGRectGetMaxY(self.msgLabel.frame) + padding;
    self.okBtn.frame = CGRectMake(x, y, okBtnW, okBtnH);
    self.okBtn.layer.cornerRadius = okBtnH * 0.5;
}

#pragma mark - 外部方法
+ (instancetype)showPanelAtView:(UIView *)view type:(NSString *)type msg:(NSString *)msg title:(NSString *)title clickedOkBtn:(ClickedOkBtnBLC)clickedOkBtn
{
    if (![view isKindOfClass:[UIView class]]) {
        return nil;
    }
    
    [self hiddenPanelAtView:view type:type];
    
    HCMsgBtnPanel *panel = [[self alloc] init];
    [view addSubview:panel];
    panel.type = type;
    panel.msgLabel.text = msg;
    [panel.okBtn setTitle:title forState:UIControlStateNormal];
    panel.clickedOkBtn = clickedOkBtn;
    panel.frame = view.bounds;
    
    return panel;
}

+ (void)hiddenPanelAtView:(UIView *)view type:(NSString *)type
{
    if (![view isKindOfClass:[UIView class]]) {
        return;
    }
    
    for (HCMsgBtnPanel *panel in view.subviews) {
        if ([panel isKindOfClass:[HCMsgBtnPanel class]] && ([panel.type isEqualToString:type] || type == nil)) {
            [panel removeFromSuperview];
        }
    }
}

- (void)hiddenPanel
{
    [self removeFromSuperview];
}

#pragma mark - 内部方法

#pragma mark - 事件
- (void)didClickOkBtn
{
    [self hiddenPanel];
    if (_clickedOkBtn) {
        _clickedOkBtn(_type);
    }
}

- (void)selfTap
{
}

- (void)selfDoubleTap
{
    
}

@end
