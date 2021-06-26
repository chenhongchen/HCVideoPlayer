//
//  UIView+VP.m
//  kt_player
//
//  Created by chc on 2019/10/18.
//

#import "UIView+VP.h"

@implementation UIView (VP)
- (void)setVp_x:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)vp_x
{
    return self.frame.origin.x;
}

- (void)setVp_y:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)vp_y
{
    return self.frame.origin.y;
}

- (void)setVp_centerX:(CGFloat)centerX
{
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)vp_centerX
{
    return self.center.x;
}

- (void)setVp_centerY:(CGFloat)centerY
{
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)vp_centerY
{
    return self.center.y;
}

- (void)setVp_width:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)vp_width
{
    return self.frame.size.width;
}

- (void)setVp_height:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)vp_height
{
    return self.frame.size.height;
}

- (void)setVp_size:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (CGSize)vp_size
{
    return self.frame.size;
}

- (void)setVp_origin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGPoint)vp_origin {
    return self.frame.origin;
}
@end
