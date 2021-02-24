//
//  HCWebViewProgressBar.h
//  FLAnimatedImage
//
//  Created by chc on 2019/10/19.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HCWebViewProgressBar : UIView
@property (nonatomic, assign, readonly) CGFloat progress;
@property (nonatomic, strong) UIColor *progressColor;

- (void)addObserverForWebView:(WKWebView *)webView;
- (void)removeObserverForWebView;
@end

NS_ASSUME_NONNULL_END
