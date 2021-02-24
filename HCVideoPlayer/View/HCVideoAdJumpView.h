//
//  HCVideoAdJumpView.h
//
//  Created by chc on 2019/5/24.
//  Copyright © 2019. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCVideoAdJumpView;
@protocol HCVideoAdJumpViewDelegate <NSObject>
- (void)didClickJumpBtnForAdJumpView:(HCVideoAdJumpView *)adJumpView;
@end

@interface HCVideoAdJumpView : UIView
@property (nonatomic, copy) NSString *sec;
@property (nonatomic, assign) BOOL canJump;
@property (nonatomic, weak) id <HCVideoAdJumpViewDelegate> delegate;
@end
