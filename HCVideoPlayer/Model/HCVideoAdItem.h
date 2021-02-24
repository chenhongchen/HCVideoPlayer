//
//  HCVideoAdItem.h
//  HCVideoPlayer
//
//  Created by chc on 2019/5/24.
//  Copyright © 2019 chc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HCVideoAdItem : NSObject
@property (nonatomic, copy) NSString *_id;
@property (nonatomic, copy) NSString *weights;
/** photo表示图片广告、video表示视频广告 */
@property (nonatomic, copy) NSString *adstype;
@property (nonatomic, copy) NSString *title;
/** 广告时长 */
@property (nonatomic, strong) NSNumber *seconds;
/** 视频、或图片地址 */
@property (nonatomic, copy) NSString *photo;
/** 跳转地址 */
@property (nonatomic, copy) NSString *url;
/** 如果是浏览器打开，0是通过safari、1是通过webview */
@property (nonatomic, copy) NSString *opentype;

@property (nonatomic, copy) NSString *appid;
@property (nonatomic, copy) NSString *campaignToken;
@property (nonatomic, copy) NSString *providerToken;

// 自定义
/** 已缓存图片标识 */
@property (nonatomic, assign) BOOL hasCacheImage;
@property (nonatomic, strong) NSURL *videoUrl;
@end
