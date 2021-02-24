//
//  HCVerButton.m
//  HCVideoPlayer
//
//  Created by chc on 2018/1/9.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "HCVerButton.h"
#import "HCVideoPlayerConst.h"

@implementation HCVerButton

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleFont = [UIFont systemFontOfSize:10];
        self.padding = 8;
    }
    return self;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat width = [self.currentTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : (_titleFont ? _titleFont : [UIFont systemFontOfSize:10])} context:nil].size.width;
    CGFloat height = self.titleFont.lineHeight;
    CGFloat x = (self.bounds.size.width - width) * 0.5;
    CGFloat y = (self.currentImage.size.width > 0) ? (self.bounds.size.width * self.currentImage.size.height / self.currentImage.size.width) + self.padding : 0;
    return CGRectMake(x, y, width, height);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    CGFloat width = self.bounds.size.width;
    CGFloat height = (self.currentImage.size.width > 0) ? width * self.currentImage.size.height / self.currentImage.size.width : 0;
    CGFloat x = 0;
    CGFloat y = 0;
    return CGRectMake(x, y, width, height);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - 外部方法
- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    self.titleLabel.font = _titleFont;
    [self setTitle:self.titleLabel.text forState:UIControlStateNormal];
}

- (CGFloat)heightToFitWidth:(CGFloat)width
{
    if (self.currentImage.size.width > 0) {
        CGFloat height = (width * self.currentImage.size.height / self.currentImage.size.width) + self.padding + self.titleFont.lineHeight;
        return height;
    }
    return self.titleFont.lineHeight;
}

- (CGFloat)btnXWithTitleX:(CGFloat)titleX btnWidth:(CGFloat)btnWidth;
{
    CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGFloat x = (size.width - btnWidth) * 0.5;
    x = titleX + x;
    return x;
}

- (void)setShareItem:(HCShareItem *)shareItem
{
    [self addBtnWithShareItem:shareItem operation:_operation];
}

- (void)setOperation:(void (^)(HCShareItem *))operation
{
    [self addBtnWithShareItem:_shareItem operation:operation];
}

- (void)addBtnWithShareItem:(HCShareItem *)shareItem operation:(void (^)(HCShareItem *shareItem))operation
{
    [self setImage:[UIImage vp_imageWithName:shareItem.norImage] forState:UIControlStateNormal];
    [self setImage:[UIImage vp_imageWithName:shareItem.higImage] forState:UIControlStateHighlighted];
    [self setTitle:shareItem.title forState:UIControlStateNormal];
    _operation = operation;
    _shareItem = shareItem;
}
@end
