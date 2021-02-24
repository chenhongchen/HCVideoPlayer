//
//  ViewController.m
//  HCVideoPlayerDemo
//
//  Created by chc on 2021/2/23.
//

#import "ViewController.h"
#import <HCVideoPlayer/HCVideoPlayer.h>
#import <HCVideoPlayer/UIView+VP.h>
#import <HCVideoPlayer/HCVideoPlayerConst.h>

@interface ViewController ()
@property (weak, nonatomic) UIView *contentView;
@property (weak, nonatomic) HCVideoPlayer *videoPlayer;
@end

@implementation ViewController

- (UIView *)contentView
{
    if (_contentView == nil) {
        UIView *contentView = [[UIView alloc] init];
        [self.view addSubview:contentView];
        _contentView = contentView;
        contentView.vp_width = kVP_ScreenWidth;
        contentView.vp_height = kVP_ScreenWidth * 9 / 16.0;
        contentView.vp_y = kVP_StatusBarHeight + 44;
    }
    return _contentView;
}

- (HCVideoPlayer *)videoPlayer
{
    if (_videoPlayer == nil) {
        HCVideoPlayer *videoPlayer = [[HCVideoPlayer alloc] init];
        [self.contentView addSubview:videoPlayer];
        _videoPlayer = videoPlayer;
    }
    return _videoPlayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.videoPlayer.frame = self.contentView.bounds;
    
    NSString *url = @"https://hls.cntv.baishancdnx.cn/asp/hls/main/0303000a/3/default/e2579451cd694bdf8a6c19b860ece19e/main.m3u8";
    [self.videoPlayer playWithUrl:[NSURL URLWithString:url] readyComplete:^(HCVideoPlayer *videoPlayer, HCVideoPlayerStatus status) {
        [videoPlayer resume];
    }];
}
@end
