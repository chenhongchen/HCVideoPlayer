//
//  HCTVControllView.h
//  HCVideoPlayer
//
//  Created by chc on 2018/1/6.
//  Copyright © 2018年 chc. All rights reserved.
//

typedef enum {
    HCTVControllViewStyleDlna,
    HCTVControllViewStyleAirPlay,
    HCTVControllViewStyleGoogleCast,
}HCTVControllViewStyle;

#import <UIKit/UIKit.h>
#import "HCVideoPlayerConst.h"
#import "HCVideoPlayerBase.h"

@class HCTVControllView;
@protocol HCTVControllViewDelegate <NSObject>
- (void)tvControllView:(HCTVControllView *)tvControllView didClickExitBtnAtPlayTime:(NSTimeInterval)playTime;
- (void)tvControllView:(HCTVControllView *)tvControllView didClickChangeDevBtnAtPlayTime:(NSTimeInterval)playTime;
- (void)didClickBackBtnForTvControllView:(HCTVControllView *)tvControllView;
@end

@interface HCTVControllView : UIView <CLUPnPResponseDelegate>
@property (nonatomic, strong) HCTVDeviceItem *deviceItem;
@property (nonatomic, weak) id <HCTVControllViewDelegate> delegate;
//@property (nonatomic, assign) BOOL isAirPlayOnCast;
@property (nonatomic, assign) HCTVControllViewStyle style;
@property (nonatomic, weak) HCVideoPlayerBase *videoPlayer;

@property (nonatomic, assign) NSTimeInterval totalTime;
@property (nonatomic, assign) NSTimeInterval playTime;
@property (nonatomic, assign) NSTimeInterval loadTime;

- (void)stopAll;
- (void)setupProgressZero;
@end
