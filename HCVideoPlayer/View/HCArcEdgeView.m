//
//  HCArcEdgeView.m
//  HCVideoPlayer
//
//  Created by chc on 2018/11/12.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "HCArcEdgeView.h"

@implementation HCArcEdgeView
-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        _height = 50;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self updateLayer:_height];
}

- (void)updateLayer:(CGFloat) height
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setFillColor:[[UIColor whiteColor] CGColor]];
    float x = 0;
    float y = 0;
    float t_width = CGRectGetWidth(self.frame);
    float t_height = CGRectGetHeight(self.frame);
    
    if (_type == HCArcEdgeViewTypeTop) {
        CGFloat c = sqrt(pow(t_width * 0.5, 2) + pow(height, 2));
        CGFloat sin_bc = height / c;
        CGFloat radius = c / (sin_bc * 2);
        CGFloat re = asin((radius - height) / radius);
        CGFloat rs = M_PI - re;
        
        CGFloat cx = t_width * 0.5;
        CGFloat cy = radius;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path,NULL, x, height);
        CGPathAddArc(path,NULL, cx, cy, radius, rs, re, NO);
        CGPathAddLineToPoint(path,NULL, t_width, t_height);
        CGPathAddLineToPoint(path,NULL, x, t_height);
        CGPathCloseSubpath(path);
        [shapeLayer setPath:path];
        CFRelease(path);
        self.layer.mask = shapeLayer;
        
    }
    else if (_type == HCArcEdgeViewTypeLeft) {
        CGFloat c = sqrt(pow(t_height * 0.5, 2) + pow(height, 2));
        CGFloat sin_bc = height / c;
        CGFloat radius = c / (sin_bc * 2);
        CGFloat rs = -asin((radius - height) / radius);
        CGFloat re = (M_PI - rs);
        
        CGFloat cx = radius;
        CGFloat cy = t_height * 0.5;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path,NULL, height,t_height);
        CGPathAddArc(path,NULL, cx, cy, radius, rs, re, NO);
        CGPathAddLineToPoint(path,NULL, t_width, y);
        CGPathAddLineToPoint(path,NULL, t_width, t_height);
        CGPathCloseSubpath(path);
        [shapeLayer setPath:path];
        CFRelease(path);
        self.layer.mask = shapeLayer;
    }
    else if (_type == HCArcEdgeViewTypeBottom) {
        CGFloat c = sqrt(pow(t_width * 0.5, 2) + pow(height, 2));
        CGFloat sin_bc = height / c;
        CGFloat radius = c / (sin_bc * 2);
        CGFloat rs = asin((radius - height) / radius);
        CGFloat re = M_PI - rs;
        
        CGFloat cx = t_width * 0.5;
        CGFloat cy = t_height - radius;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path,NULL, t_width,t_height - height);
        CGPathAddArc(path,NULL, cx, cy, radius, rs, re, NO);
        CGPathAddLineToPoint(path,NULL, x, y);
        CGPathAddLineToPoint(path,NULL, t_width, y);
        CGPathCloseSubpath(path);
        [shapeLayer setPath:path];
        CFRelease(path);
        self.layer.mask = shapeLayer;
    }
    else if (_type == HCArcEdgeViewTypeRight) {
        CGFloat c = sqrt(pow(t_height * 0.5, 2) + pow(height, 2));
        CGFloat sin_bc = height / c;
        CGFloat radius = c / (sin_bc * 2);
        CGFloat rs = -asin((radius - height) / radius);
        CGFloat re = (M_PI - rs);
        
        CGFloat cx = t_width - radius;
        CGFloat cy = t_height * 0.5;
        
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathMoveToPoint(path,NULL, t_width - height,0);
        CGPathAddArc(path,NULL, cx, cy, radius, rs, re, NO);
        CGPathAddLineToPoint(path,NULL, x, t_height);
        CGPathAddLineToPoint(path,NULL, x, y);
        CGPathCloseSubpath(path);
        [shapeLayer setPath:path];
        CFRelease(path);
        self.layer.mask = shapeLayer;
    }
}

@end
