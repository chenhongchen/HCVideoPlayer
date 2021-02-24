//
//  HCNextTipView.h
//  HCVideoPlayer
//
//  Created by chc on 2019/5/13.
//  Copyright © 2019 chc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCNextTipView;
@protocol HCNextTipViewDelegate <NSObject>
- (void)didClickCancelBtnForNextTipView:(HCNextTipView *)nextTipView;
@end

@interface HCNextTipView : UIView
@property (nonatomic, copy) NSString *sec;
@property (nonatomic, weak) id <HCNextTipViewDelegate> delegate;
@end
