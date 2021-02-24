//
//  HCWebViewProgressBar.m
//  FLAnimatedImage
//
//  Created by chc on 2019/10/19.
//

#import "HCWebViewProgressBar.h"
#import "HCVideoPlayerConst.h"

@interface HCWebViewProgressBar ()
@property (nonatomic, weak) WKWebView *webView;
@property (nonatomic, weak) UIView *progressBar;
@end

@implementation HCWebViewProgressBar
#pragma mark - 懒加载
- (UIView *)progressBar
{
    if (_progressBar == nil) {
        UIView *progressBar = [[UIView alloc] init];
        [self addSubview:progressBar];
        _progressBar = progressBar;
        progressBar.backgroundColor = kVP_Color(21, 126, 251,1);
    }
    return _progressBar;
}

#pragma mark - 初始化
- (void)dealloc
{
}

#pragma mark - 外部方法
- (void)addObserverForWebView:(WKWebView *)webView
{
    if (![webView isKindOfClass:[WKWebView class]]) {
        return;
    }
    
    _webView = webView;
    [webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserverForWebView
{
    if (![_webView isKindOfClass:[WKWebView class]]) {
        return;
    }
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

- (void)setProgress:(CGFloat)progress
{
    _progress = progress;
    
    CGFloat selfWidth = self.bounds.size.width;
    CGRect rect = self.bounds;
    rect.size.width = selfWidth * _progress;
    [UIView animateWithDuration:0.33333 animations:^{
        self.progressBar.frame = rect;
    }];
    if (_progress == 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.333333 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.333333 animations:^{
                self.progressBar.alpha = 0.0;
            } completion:^(BOOL finished) {
                CGRect rect = self.bounds;
                rect.size.width = 0.0;
                self.progressBar.frame = rect;
                self.progress = 0.0;
                self.progressBar.alpha = 1.0;
            }];
        });
    }
}

- (void)setProgressColor:(UIColor *)progressColor
{
    _progressColor = progressColor;
    self.progressBar.backgroundColor = _progressColor;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progress = self.webView.estimatedProgress;
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
