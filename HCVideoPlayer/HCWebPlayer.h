//
//  HCWebPlayer.h
//  HCVideoPlayer
//
//  Created by chc on 2019/12/14.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "HCVideoAdsItem.h"

@class HCWebPlayer;
@protocol HCWebPlayerDelegate <NSObject>
@optional
- (void)didClickBackBtnForWebPlayer:(HCWebPlayer *)webPlayer;
@end

API_AVAILABLE(ios(8.0))
@interface HCWebPlayer : UIView
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) id <HCWebPlayerDelegate> delegate;
/** 贴片广告模型 */
@property (nonatomic, strong) HCVideoAdsItem *videoAdsItem;
/** 暂停图片广告 */
@property (nonatomic, strong) NSArray <HCVideoAdItem *> *picAdsItem;
@end

API_AVAILABLE(ios(8.0))
@interface HCWebProgressBar : UIView
@property (nonatomic, assign, readonly) CGFloat progress;
@property (nonatomic, strong) UIColor *progressColor;
- (void)addObserverForWebView:(WKWebView *)webView;
- (void)removeObserverForWebView;
@end
