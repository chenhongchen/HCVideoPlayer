//
//  HCSvSharePanel.h
//  HCVideoPlayer
//
//  Created by chc on 2019/5/14.
//  Copyright © 2019 chc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCVideoPlayerConst.h"

@class HCSvSharePanel;
@protocol HCSvSharePanelDelegate <NSObject>
@optional
- (void)didClickRePlayBtnForSvSharePanel:(HCSvSharePanel *)svSharePanel;
- (void)svSharePanel:(HCSvSharePanel *)svSharePanel didClickWechatItem:(HCShareItem *)item;
- (void)svSharePanel:(HCSvSharePanel *)svSharePanel didClickCircleItem:(HCShareItem *)item;
@end

@interface HCSvSharePanel : UIView
+ (instancetype)showPanelAtView:(UIView *)view clickedReplayBtn:(void (^)(void))clickedReplayBtn;
+ (void)hiddenPanelAtView:(UIView *)view;
@property (nonatomic, weak) id <HCSvSharePanelDelegate> delegate;
@end
