//
//  HCVPTool.m
//  kt_player
//
//  Created by chc on 2019/10/18.
//

#import "HCVPTool.h"
#import <CommonCrypto/CommonDigest.h>

@implementation HCVPTool
+ (NSString *)md5String:(NSString *)text
{
    const char *cStr = [text UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, (CC_LONG)strlen(cStr), result );
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]] lowercaseString];
}

+ (void)downloadWithUrl:(NSString *)url complete:(void(^)(NSData *data, NSError *error))complete
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *temUrl = [NSURL URLWithString:url];
        NSURLSessionConfiguration * configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:[[NSOperationQueue alloc] init]];
        NSURLRequest *request = [NSURLRequest requestWithURL:temUrl cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:CGFLOAT_MAX];
        [[session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(complete)
                        complete(nil,error);
                });
            }
            else {
                NSData *data = [NSData dataWithContentsOfURL:location];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if([data isKindOfClass:[NSData class]]) {
                        if(complete)
                            complete(data,error);
                    }
                    else {
                        if(complete)
                            complete(nil,error);
                    }
                });
            }
        }] resume];
        [session finishTasksAndInvalidate];
    });
}

+ (BOOL)writeData:(NSData *)data toPath:(NSString *)path
{
    BOOL result = NO;
    if (![data isKindOfClass:[NSData class]] || !path.length) {
        return result;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]) {
        [fileManager removeItemAtPath:path error:nil];
    }
    if(![fileManager fileExistsAtPath:path]) {
        result = [fileManager createFileAtPath:path contents:data attributes:nil];
    }
    return result;
}

+ (UIViewController *)myControllerWithView:(UIView *)view
{
    if (![view isKindOfClass:[UIView class]]) {
        return nil;
    }
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

+ (void)scrollView:(UIScrollView *)scrollView unAutomaticallyAdjustsScrollViewInsetsForController:(UIViewController *)controller
{
    if (@available(iOS 11.0, *)) {
        scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    else
    {
        controller.automaticallyAdjustsScrollViewInsets = NO;
    }
}

// 图片转字符串
+ (NSString *)base64StrWithImage:(UIImage *)image
{
    if (![image isKindOfClass:[UIImage class]]) {
        return nil;
    }
    NSData *data = UIImageJPEGRepresentation(image, 1.0f);
    NSString *encodedImageStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    return encodedImageStr;
}

// 字符串转图片
+ (UIImage *)imageWithBase64Str:(NSString *)imageBase64Str
{
    NSData *_decodedImageData = [[NSData alloc] initWithBase64EncodedString:imageBase64Str options:NSDataBase64DecodingIgnoreUnknownCharacters];
    UIImage *_decodedImage = [UIImage imageWithData:_decodedImageData];
    return _decodedImage;
}
@end
