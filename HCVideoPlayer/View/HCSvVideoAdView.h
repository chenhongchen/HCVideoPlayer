//
//  HCVideoAdView.h
//  HCVideoPlayer
//
//  Created by chc on 2019/5/24.
//  Copyright © 2019 chc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCVideoAdsItem.h"

@class HCSvVideoAdView;
@protocol HCSvVideoAdViewDelegate <NSObject>
@optional
- (void)didClickBackBtnForSvVideoAdView:(HCSvVideoAdView *)svVideoAdView;
- (void)didClickSkipBtnForSvVideoAdView:(HCSvVideoAdView *)svVideoAdView;
- (void)svVideoAdView:(HCSvVideoAdView *)svVideoAdView didClickAdItem:(HCVideoAdItem *)adItem;
- (void)didAdsPlayCompleteForSvVideoAdView:(HCSvVideoAdView *)svVideoAdView;
@end

@interface HCSvVideoAdView : UIView
@property (nonatomic, strong) HCVideoAdsItem *adsItem;
@property (nonatomic, weak) id <HCSvVideoAdViewDelegate> delegate;
/** 是否显示返回按钮（默认是）*/
@property (nonatomic, assign) BOOL showBack;
@property (nonatomic, assign) BOOL isManualStopOrPausePlay;
@property (nonatomic, assign) BOOL whenAppActiveNotToPlay;
@property (nonatomic, assign) BOOL mute;

- (void)play;
- (void)pause;
- (void)stop;
@end
