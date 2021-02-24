//
//  HCVideoAdView.h
//  HCVideoPlayer
//
//  Created by chc on 2019/5/24.
//  Copyright © 2019 chc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCVideoAdsItem.h"

@class HCVideoAdView;
@protocol HCVideoAdViewDelegate <NSObject>
@optional
- (void)didClickBackBtnForVideoAdView:(HCVideoAdView *)videoAdView;
- (void)didClickSkipBtnForVideoAdView:(HCVideoAdView *)videoAdView;
- (void)didClickZoomBtnForVideoAdView:(HCVideoAdView *)videoAdView;
- (void)videoAdView:(HCVideoAdView *)videoAdView didClickAdItem:(HCVideoAdItem *)adItem;
- (void)didAdsPlayCompleteForVideoAdView:(HCVideoAdView *)videoAdView;
@end

@interface HCVideoAdView : UIView
@property (nonatomic, strong) HCVideoAdsItem *adsItem;
@property (nonatomic, weak) id <HCVideoAdViewDelegate> delegate;
/** 是否显示返回按钮（默认是）*/
//@property (nonatomic, assign) BOOL showBack;
//@property (nonatomic, assign) BOOL isManualStopOrPausePlay;
//@property (nonatomic, assign) BOOL whenAppActiveNotToPlay;
//@property (nonatomic, assign) BOOL mute;
/** 是否显示缩放按钮（默认是）*/
@property (nonatomic, assign) BOOL showZoom;

- (void)play;
- (void)pause;
- (void)stop;
@end
