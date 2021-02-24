//
//  HCFastForwardAndbackView.h
//  HCVideoPlayer
//
//  Created by chc on 2018/11/12.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCFastForwardAndBackView;
@protocol HCFastForwardAndBackViewDelegate <NSObject>
@optional
- (void)fastForwardAndBackView:(HCFastForwardAndBackView *)fastForwardAndBackView fastTime:(CGFloat)fastTime;
@end

@interface HCFastForwardAndBackView : UIView
@property (nonatomic, weak) id <HCFastForwardAndBackViewDelegate> delegate;
- (void)showLeft;
- (void)showRight;
@end
