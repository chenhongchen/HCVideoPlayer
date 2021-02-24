//
//  HCWebView.h
//  FLAnimatedImage
//
//  Created by chc on 2019/10/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HCWebView : UIView
/// 本地加载的Url
@property (nonatomic, strong) NSURL *url;
/// 跳转的Url，如果存在，则点击webView会跳safari打开
@property (nonatomic, strong) NSURL *jump_url;
@property (nonatomic, assign) BOOL alwaysShowControllBar;
@property (nonatomic, assign) BOOL isConsideSafeBottom;

- (void)reload;
@end

NS_ASSUME_NONNULL_END
