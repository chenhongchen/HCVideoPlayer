//
//  HCVideoAdsItem.m
//  HCVideoPlayer
//
//  Created by chc on 2019/5/24.
//  Copyright © 2019 chc. All rights reserved.
//

#import "HCVideoAdsItem.h"
#import "MJExtension.h"

@implementation HCVideoAdsItem
+ (void)load
{
    [self mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"ads" : @"HCVideoAdItem"
                 };
    }];
}

- (BOOL)canJump
{
    if (_leftsec.integerValue > 0) {
        return YES;
    }
    return NO;
}
@end
