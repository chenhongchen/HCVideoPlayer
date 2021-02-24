//
//  NSString+VP.m
//  HCVideoPlayer
//
//  Created by chc on 2018/1/6.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "NSString+VP.h"

@implementation NSString (VP)

+ (instancetype)vp_formateStringFromSec:(CGFloat)sec
{
    return ((sec > 3600) ? [self vp_getHHMMSSFromSec:sec] : [self vp_getMMSSFromSec:sec]);
}

+ (instancetype)vp_formateStringFromSec:(CGFloat)sec forceShowHour:(BOOL)forceShowHour
{
    return (forceShowHour ? [self vp_getHHMMSSFromSec:sec] : [self vp_formateStringFromSec:sec]);
}

+ (instancetype)vp_getHHMMSSFromSec:(CGFloat)sec {
    
    NSInteger seconds = floor(sec);
    
    //format of hour
    NSString *str_hour = [self stringWithFormat:@"%02ld", seconds/3600];
    //format of minute
    NSString *str_minute = [self stringWithFormat:@"%02ld", (seconds%3600)/60];
    //format of second
    NSString *str_second = [self stringWithFormat:@"%02ld", seconds%60];
    //format of time
    NSString *format_time = [self stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    
    return format_time;
}

+ (instancetype)vp_getMMSSFromSec:(CGFloat)sec {
    
    NSInteger seconds = floor(sec);
    
    //format of minute
    NSString *str_minute = [self stringWithFormat:@"%02ld", seconds/60];
    //format of second
    NSString *str_second = [self stringWithFormat:@"%02ld", seconds%60];
    //format of time
    NSString *format_time = [self stringWithFormat:@"%@:%@",str_minute,str_second];
    
    return format_time;
}

+ (NSString*)getCurrentTimesHHmm {

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];

    // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    [formatter setDateFormat:@"HH:mm"];

    //现在时间,你可以输出来看下是什么格式
    NSDate *datenow = [NSDate date];

    //----------将nsdate按formatter格式转成nsstring
    NSString *currentTimeString = [formatter stringFromDate:datenow];
    return currentTimeString;
}
@end
