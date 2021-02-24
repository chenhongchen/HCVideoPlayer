//
//  HCNavigationBarView.m
//  FLAnimatedImage
//
//  Created by chc on 2019/10/18.
//

#import "HCNavigationBarView.h"
#import "HCVideoPlayerConst.h"
#import "HCVPTool.h"

@interface HCNavigationBarView ()
@property (nonatomic, weak) UIButton *backBtn;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray *rightBtnsM;
@property (nonatomic, weak) UIView *botLine;
@end

@implementation HCNavigationBarView

#pragma mark - 懒加载
- (UIButton *)backBtn
{
    if (_backBtn == nil) {
        UIButton *backBtn = [[UIButton alloc] init];
        [self addSubview:backBtn];
        [backBtn setImage:[UIImage vp_imageWithName:@"vp_backNav"] forState:UIControlStateNormal];
        [backBtn setImage:[UIImage vp_imageWithName:@"vp_backNav"] forState:UIControlStateHighlighted];
        [backBtn addTarget:self action:@selector(backBtnClicked) forControlEvents:UIControlEventTouchUpInside];
        _backBtn = backBtn;
    }
    return _backBtn;
}

- (UILabel *)titleLabel
{
    if (_titleLabel == nil) {
        UILabel *titleLabel = [[UILabel alloc] init];
        [self addSubview:titleLabel];
        _titleLabel = titleLabel;
        titleLabel.font = [UIFont systemFontOfSize:18];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (NSMutableArray *)rightBtnsM
{
    if (_rightBtnsM == nil) {
        _rightBtnsM = [NSMutableArray array];
    }
    return _rightBtnsM;
}

- (UIView *)botLine
{
    if (_botLine == nil) {
        UIView *botLine = [[UIView alloc] init];
        [self addSubview:botLine];
        _botLine = botLine;
    }
    return _botLine;
}

#pragma mark - 外部方法
- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = _title;
    [self setupFrame];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    self.titleLabel.textColor = _titleColor;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    self.titleLabel.font = _titleFont;
    [self setupFrame];
}

- (void)setBotLineColor:(UIColor *)botLineColor
{
    _botLineColor = botLineColor;
    self.botLine.backgroundColor = _botLineColor;
    [self setupFrame];
}

- (void)setBarHeight:(CGFloat)barHeight
{
    _barHeight = barHeight;
    self.vp_height = kVP_StatusBarHeight + _barHeight;
}

- (void)setBackBtnColor:(UIColor *)backBtnColor
{
    _backBtnColor = backBtnColor;
    UIImage *image = [UIImage vp_imageWithName:@"back_white"];
    if (_backBtnColor) {
        image = [image vp_imageMaskWithColor:_backBtnColor];
    }
    [self.backBtn setImage:image forState:UIControlStateNormal];
    [self.backBtn setImage:image forState:UIControlStateHighlighted];
}

- (void)setHiddenBackBtn:(BOOL)hiddenBackBtn
{
    _hiddenBackBtn = hiddenBackBtn;
    self.backBtn.hidden = _hiddenBackBtn;
}

- (void)addRightBtn:(UIButton *)rightBtn
{
    [self.rightBtnsM addObject:rightBtn];
    [self addSubview:rightBtn];
    [self setupFrame];
}

- (NSArray *)rightBtns
{
    return self.rightBtnsM;
}

- (void)setRightBtns:(NSArray *)rightBtns
{
    for (UIView *view in self.rightBtnsM) {
        [view removeFromSuperview];
    }
    [self.rightBtnsM removeAllObjects];
    [self.rightBtnsM addObjectsFromArray:rightBtns];
    [self setupFrame];
}

- (CGFloat)titleCenterX
{
    return self.titleLabel.vp_centerX;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kVP_ThemeColor;
        self.barHeight = 44;
        self.autoAddRightBtnsW = 20;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self setupFrame];
}

#pragma mark - 内部方法
- (void)setupFrame
{
    CGFloat kMargin = 15;
    CGFloat kPadding = 15;
    CGFloat barHeight = _barHeight;
    
    CGFloat btnAddHalfW = _autoAddRightBtnsW * 0.5;
    CGFloat btnAddW = _autoAddRightBtnsW;
    
    self.backBtn.vp_width = self.backBtn.imageView.image.size.width + kMargin * 2;
    self.backBtn.vp_height = barHeight;
    self.backBtn.vp_x = 0;
    self.backBtn.vp_y = self.vp_height - barHeight;
    
    UIButton *lastRightBtn = nil;
    for (UIButton *rightBtn in self.rightBtnsM) {
        CGSize size = [rightBtn sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
        if (size.width > rightBtn.vp_width || size.height > rightBtn.vp_height) {
            [rightBtn sizeToFit];
            rightBtn.vp_width += btnAddW;
        }
        rightBtn.vp_y = floor((barHeight - rightBtn.vp_height) * 0.5 + kVP_StatusBarHeight);
        rightBtn.vp_x = floor((lastRightBtn ? CGRectGetMinX(lastRightBtn.frame) : kVP_ScreenWidth) - rightBtn.vp_width - (lastRightBtn ? kPadding - btnAddW : 20 - btnAddHalfW));
        lastRightBtn = rightBtn;
    }
    
    CGFloat lMargin = CGRectGetMaxX(self.backBtn.frame) + 10;
    CGFloat rMargin = (lastRightBtn ? kVP_ScreenWidth - lastRightBtn.vp_x + 10 : 20);
    CGFloat width = kVP_ScreenWidth - lMargin - rMargin;
    CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    self.titleLabel.vp_width = MIN(width, size.width);
    _titleLabel.vp_height = barHeight;
    CGFloat x = (kVP_ScreenWidth - self.titleLabel.vp_width) * 0.5;
    if (lastRightBtn && (x + self.titleLabel.vp_width > lastRightBtn.vp_x - 10)) {
        x = lastRightBtn.vp_x - 10 - self.titleLabel.vp_width;
    }
    if (_backBtn && (x < CGRectGetMaxX(self.backBtn.frame) + 10)) {
        x = CGRectGetMaxX(self.backBtn.frame) + 10;
    }
    self.titleLabel.vp_x = floor(x);
    self.titleLabel.vp_y = floor(self.vp_height - barHeight);
    
    self.botLine.vp_x = 0;
    self.botLine.vp_height = (1.0 / [UIScreen mainScreen].scale);
    self.botLine.vp_y = self.vp_height - self.botLine.vp_height;
    self.botLine.vp_width = self.vp_width;
}

#pragma mark - 事件
- (void)backBtnClicked
{
    if ([self.delegate respondsToSelector:@selector(didClickBackBtnForNavigationBarView:)]) {
        [self.delegate didClickBackBtnForNavigationBarView:self];
    }
    else
    {
        [[HCVPTool myControllerWithView:self].navigationController popViewControllerAnimated:YES];
    }
}

@end
