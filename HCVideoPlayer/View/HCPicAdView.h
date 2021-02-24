//
//  HCPicAdView.h
//  HCVideoPlayer
//
//  Created by chc on 2018/9/30.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCVideoAdItem.h"

@class HCPicAdView;
@protocol HCPicAdViewDelegate <NSObject>
@optional
- (void)didClickCloseBtnForVpPicAdView:(HCPicAdView *)vpPicAdView;
- (void)vpPicAdView:(HCPicAdView *)vpPicAdView didClickAdItem:(HCVideoAdItem *)adItem;
@end

@interface HCPicAdView : UIView
@property (nonatomic, strong) NSArray <HCVideoAdItem *> *picItems;
@property (nonatomic, weak) id <HCPicAdViewDelegate> delegate;
@end
