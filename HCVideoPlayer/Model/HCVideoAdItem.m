//
//  HCVideoAdItem.m
//  HCVideoPlayer
//
//  Created by chc on 2019/5/24.
//  Copyright © 2019 chc. All rights reserved.
//
#define KVP_DocDirFilePath(fileName) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:fileName]

#import "HCVideoAdItem.h"
#import "HCVPTool.h"
#import "SDWebImageManager.h"

@implementation HCVideoAdItem
#pragma mark - 外部方法
- (void)setPhoto:(NSString *)photo
{
    _photo = photo;
    [self downloadPhoto];
    [self downloadVideo];
}

- (void)setAdstype:(NSString *)adstype
{
    _adstype = adstype;
    [self downloadPhoto];
    [self downloadVideo];
}

- (NSURL *)videoUrl
{
    if (![_adstype isEqualToString:@"video"]) {
        return nil;
    }
    
    NSString *filePath = [self videoCachePathName:[HCVPTool md5String:_photo]];
    if (filePath.length && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return [NSURL fileURLWithPath:filePath];
    }
    return [NSURL URLWithString:_photo];
}

#pragma mark - 内部方法
#pragma mark 图片广告
- (void)downloadPhoto
{
    if (![_adstype isEqualToString:@"photo"]) {
        _hasCacheImage = NO;
        return;
    }
    
    if (!_photo.length) {
        _hasCacheImage = NO;
        return;
    }
    
    __weak typeof(self) weakSelf = self;
    [SDWebImageManager.sharedManager loadImageWithURL:[NSURL URLWithString:_photo] options:SDWebImageRetryFailed progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
        weakSelf.hasCacheImage = !error;
    }];
}

#pragma mark 视频广告
- (void)downloadVideo
{
    if (![_adstype isEqualToString:@"video"]) {
        return;
    }
    
    if (!_photo.length) {
        return;
    }
    
    NSString *filePath = [self videoCachePathName:[HCVPTool md5String:_photo]];
    if (filePath.length && [[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return ;
    }
    
    if (!filePath.length) {
        return;
    }
    
    [HCVPTool downloadWithUrl:_photo complete:^(NSData *data, NSError *error) {
        [HCVPTool writeData:data toPath:filePath];
    }];
}

- (NSString *)videoCachePathName:(NSString *)name
{
    if (!name.length) {
        return nil;
    }
    NSString *videoAdDir = [HCVideoAdItem createVideoAdDir];
    if (!videoAdDir.length) {
        return nil;
    }
    
    NSString *suf = [_photo componentsSeparatedByString:@"."].lastObject;
    NSString *fileName = [NSString stringWithFormat:@"%@.%@", name, suf.length ? suf : @"mp4"];
    return [videoAdDir stringByAppendingPathComponent:fileName];
}

+ (NSString *)createVideoAdDir
{
    NSString *videoAdDir = KVP_DocDirFilePath(@"videoAd");
    
    BOOL isDir = NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:videoAdDir isDirectory:&isDir];
    
    NSError *error = nil;
    if (!(isDir && existed)) {
        [fileManager createDirectoryAtPath:videoAdDir withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    return error ? nil : videoAdDir;
}

@end
