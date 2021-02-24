//
//  HCPTPTool.h
//  FLAnimatedImage
//
//  Created by chc on 2019/10/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HCPTPTool : NSObject
+ (void)initPTP;
+ (NSURL *)PTPStreamURLForURL:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
