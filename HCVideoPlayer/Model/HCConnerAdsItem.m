//
//  HCConnerAdsItem.m
//  HCVideoPlayer
//
//  Created by chc on 2020/1/3.
//

#import "HCConnerAdsItem.h"
#import "MJExtension.h"

@implementation HCConnerAdsItem
+ (void)load
{
    [self mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"ads" : @"HCVideoAdItem"
                 };
    }];
}
@end
