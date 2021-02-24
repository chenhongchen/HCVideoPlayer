//
//  HCSelectTvDevController.h
//  HCVideoPlayer
//
//  Created by chc on 2018/1/7.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCVideoPlayerConst.h"
#import <GoogleCast/GoogleCast.h>

@class HCSelectTvDevController;
@protocol HCSelectTvDevControllerDelegate <NSObject>
@optional
- (void)selectTvDevController:(HCSelectTvDevController *)selectTvDevController didSelectDlnaDev:(CLUPnPDevice *)dlnaDev;
- (void)selectTvDevController:(HCSelectTvDevController *)selectTvDevController didSelectSamsungDev:(id)samsungDev;
- (void)didClickBackBtnForSelectTvDevController:(HCSelectTvDevController *)selectTvDevController;
@end

@interface HCSelectTvDevController : UIViewController
@property (nonatomic, weak) id <HCSelectTvDevControllerDelegate> delegate;
@property (nonatomic, weak) GCKUICastContainerViewController *castContainerVC;
@end
