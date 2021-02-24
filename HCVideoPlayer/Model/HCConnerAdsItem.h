//
//  HCConnerAdsItem.h
//  HCVideoPlayer
//
//  Created by chc on 2020/1/3.
//

#import <Foundation/Foundation.h>
#import "HCVideoAdItem.h"

@interface HCConnerAdsItem : NSObject
@property (nonatomic, strong) NSArray <HCVideoAdItem *> *ads;
@property (nonatomic, copy) NSString *corner_dir;
@end
