//
//  HCVPTool.h
//  kt_player
//
//  Created by chc on 2019/10/18.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HCVPTool : NSObject
+ (NSString *)md5String:(NSString *)text;
+ (void)downloadWithUrl:(NSString *)url complete:(void(^)(NSData *data, NSError *error))complete;
+ (BOOL)writeData:(NSData *)data toPath:(NSString *)path;
+ (UIViewController *)myControllerWithView:(UIView *)view;
+ (void)scrollView:(UIScrollView *)scrollView unAutomaticallyAdjustsScrollViewInsetsForController:(UIViewController *)controller;
+ (NSString *)base64StrWithImage:(UIImage *)image;
+ (UIImage *)imageWithBase64Str:(NSString *)imageBase64Str;
@end

NS_ASSUME_NONNULL_END
