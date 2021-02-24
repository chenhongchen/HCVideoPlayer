//
//  HCVideoAdsItem.h
//  HCVideoPlayer
//
//  Created by chc on 2019/5/24.
//  Copyright © 2019 chc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HCVideoAdItem.h"

@interface HCVideoAdsItem : NSObject
@property (nonatomic, strong) NSArray <HCVideoAdItem *> *ads;
@property (nonatomic, strong) NSNumber *leftsec;
@property (nonatomic, assign) BOOL canJump;
@end

//"ad" : {
//    "play_preplay" : {
//        "leftsec" : 0,
//        "ads" : [
//                 {
//                     "appid" : "",
//                     "providerToken" : "",
//                     "seconds" : 17,
//                     "photo_size" : {
//                         "width" : "",
//                         "height" : ""
//                     },
//                     "url" : "https://bit.ly/2Upxn3D",
//                     "_id" : 131914270749002,
//                     "type" : "play_preplay",
//                     "title" : "红龙之怒_iOS_贴片",
//                     "show" : 2,
//                     "campaignToken" : "",
//                     "seo" : "",
//                     "ads_company" : "",
//                     "opentype" : 0,
//                     "adstype" : "video",
//                     "comm_nums" : 0,
//                     "weights" : 1,
//                     "photo" : "https://asset.ktvimg.com/2019/ad/20190514/23a4dfda516db57c5ef99def49ab7fef.mp4"
//                 }
//                 ]
//    }
//}
