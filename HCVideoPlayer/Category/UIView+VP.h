//
//  UIView+VP.h
//  kt_player
//
//  Created by chc on 2019/10/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (VP)
@property (assign, nonatomic) CGFloat vp_x;
@property (assign, nonatomic) CGFloat vp_y;
@property (assign, nonatomic) CGFloat vp_centerX;
@property (assign, nonatomic) CGFloat vp_centerY;
@property (assign, nonatomic) CGFloat vp_width;
@property (assign, nonatomic) CGFloat vp_height;
@property (assign, nonatomic) CGSize vp_size;
@property (assign, nonatomic) CGPoint vp_origin;
+ (UIWindow *)vp_rootWindow;
@end

NS_ASSUME_NONNULL_END
