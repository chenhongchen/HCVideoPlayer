//
//  HCTimingView.h
//  HCVideoPlayer
//
//  Created by chc on 2019/1/14.
//  Copyright © 2019年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCVideoPlayerConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface HCTimingView : UIView
+ (HCTimingView *)showAtView:(UIView *)view;
@property (nonatomic, assign) HCTimingType type;
@end

NS_ASSUME_NONNULL_END
