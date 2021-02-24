//
//  HCTVDeviceItem.h
//  HCVideoPlayer
//
//  Created by chc on 2018/1/8.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLUPnP.h"

@interface HCTVDeviceItem : NSObject
@property (nonatomic, strong) CLUPnPDevice *dlnaDev;
@property (nonatomic, strong) id samsungDev;
@property (nonatomic, assign) NSTimeInterval seekTime;
@property (nonatomic, copy) NSString *videoUrl;
@property (nonatomic, copy) NSString *title;
@end
