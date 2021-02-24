//
//  HCMorePanel.h
//  HCVideoPlayer
//
//  Created by chc on 2018/1/10.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCMorePanel;
@protocol HCMorePanelDelegate <NSObject>
@optional
- (void)didHiddenMorePanel;
- (void)morePanel:(HCMorePanel *)morePanel didSelectRate:(CGFloat)rate;
- (void)morePanel:(HCMorePanel *)morePanel didChangeColloctStatus:(BOOL)status;
- (void)didClickDlBtnForMorePanel:(HCMorePanel *)morePanel;
- (void)didClickCtBtnForMorePanel:(HCMorePanel *)morePanel;
- (void)didClickStBtnForMorePanel:(HCMorePanel *)morePanel;
- (void)didClickTimeCloseBtnForMorePanel:(HCMorePanel *)morePanel;
- (void)morePanel:(HCMorePanel *)morePanel didChangeFullScreenShowValue:(BOOL)value;
- (void)morePanel:(HCMorePanel *)morePanel didChangeAutoSkipValue:(BOOL)value;
- (void)morePanel:(HCMorePanel *)morePanel didChangeSmallWindowValue:(BOOL)value;
@end

@interface HCMorePanel : UIView
@property (nonatomic, weak) id <HCMorePanelDelegate> delegate;
@property (nonatomic, assign) CGFloat rate;
@property (nonatomic, assign) BOOL collectStatus;
- (void)showPanelAtView:(UIView *)view;
- (void)hiddenPanel;

@property (nonatomic, assign) BOOL enableDlBtn;
@property (nonatomic, assign) BOOL enableStBtn;
@property (nonatomic, assign) BOOL enableAddToMyDefWBBtn;
@end
