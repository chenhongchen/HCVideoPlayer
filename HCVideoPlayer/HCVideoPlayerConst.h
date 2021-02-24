//
//  HCVideoPlayerConst.h
//  HCVideoPlayer
//
//  Created by chc on 2018/1/6.
//  Copyright © 2018年 chc. All rights reserved.
//

#import "CLUPnP.h"
#import "UIImage+VP.h"
#import "NSString+VP.h"
#import "UIView+VP.h"
#import "HCWeakTimer.h"
#import "HCTVDeviceItem.h"
#import "HCShareItem.h"
#import "HCNetWorkSpeed.h"
#import "HCVPTool.h"


#ifdef DEBUG // 调试状态, 打开LOG功能
#define VPLog(...) NSLog(__VA_ARGS__)
#else // 发布状态, 关闭LOG功能
#define VPLog(...)
#endif

typedef enum {
    HCTimingTypeUnuse,
    HCTimingTypePlayTheEps,
    HCTimingTypePlay30,
    HCTimingTypePlay60
}HCTimingType;

typedef enum {
    HCVideoPlayerZoomStatusZoomIn,
    HCVideoPlayerZoomStatusZoomOut
}HCVideoPlayerZoomStatus;

typedef enum {
    HCVideoPlayerStatusIdle,
    HCVideoPlayerStatusReadying,
    HCVideoPlayerStatusReadyed,
    HCVideoPlayerStatusPlay,
    HCVideoPlayerStatusPause,
    HCVideoPlayerStatusPlayback,
    HCVideoPlayerStatusStop,
    HCVideoPlayerStatusError
}HCVideoPlayerStatus;

typedef enum {
    HCVideoPlayerZoomTypeRotation,
    HCVideoPlayerZoomTypeScale
}HCVideoPlayerZoomType;

typedef void(^HCVideoPlayerReadyComplete)(id videoPlayer, HCVideoPlayerStatus status);

UIKIT_EXTERN NSString *const NotificationVideoPlayerWillZoomOut;
UIKIT_EXTERN NSString *const NotificationVideoPlayerDidZoomOut;
UIKIT_EXTERN NSString *const NotificationVideoPlayerWillZoomIn;
UIKIT_EXTERN NSString *const NotificationVideoPlayerDidZoomIn;

UIKIT_EXTERN NSString *const NotificationVideoPlayerDidSetTiming;

UIKIT_EXTERN NSString *const ShareListKeyLinkShare;
UIKIT_EXTERN NSString *const ShareListKeyImageShare;

UIKIT_EXTERN NSString *const VPFullScreenShow;
UIKIT_EXTERN NSString *const VPShortIsCloseVoice;
UIKIT_EXTERN NSString *const VPUDKeyNotAutoSkippingTitlesAndEnds;
UIKIT_EXTERN NSString *const VPUDKeyIsSmallWindwoModleClose;

UIKIT_EXTERN NSString *const VPNotificationNetworkReachabilityStatusChanged;
UIKIT_EXTERN NSString *const VPNotificationSvAllowAutoPlayStatusChanged;



#define kVP_AniDuration 0.333333
#define kVP_rotaionAniDuration 0.333333

#define kVP_IS_IPHONEX_XS (fabs((double)MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) - (double)812)<DBL_EPSILON)
#define kVP_IS_IPhoneXR_XSMax (fabs((double)MAX([[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width) - (double)896) < DBL_EPSILON)

#define kVP_IS_FullScreen (kVP_IS_IPHONEX_XS || kVP_IS_IPhoneXR_XSMax)

#define kVP_StatusBarHeight CGRectGetHeight([UIApplication sharedApplication].statusBarFrame)
#define kVP_iPhoneXSafeBottomHeight (kVP_IS_FullScreen ? 34 : 0)
#define kVP_iPhoneXSafeTopHeight (kVP_IS_FullScreen ? kVP_StatusBarHeight : 0)
#define kVP_NavigationBarHeight (kVP_StatusBarHeight + 44)

// 适配
// 竖屏屏幕宽高
//#define kVP_ScreenWidth MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
//#define kVP_ScreenHeight MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
// 设备屏幕宽高
//#define kVP_ScreenDW [UIScreen mainScreen].bounds.size.width
//#define kVP_ScreenDH [UIScreen mainScreen].bounds.size.height
#define kVP_ScreenWidth [UIScreen mainScreen].bounds.size.width
#define kVP_ScreenHeight [UIScreen mainScreen].bounds.size.height

#define kVP_Color(r, g, b, a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define kVP_ColorWithHexValueA(hexValue, a) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0x00FF00) >>  8))/255.0 blue:((float)((hexValue & 0x0000FF) >>  0))/255.0 alpha:(a)]
#define kVP_TextBlackColor kVP_Color(51, 51, 51, 1)
#define kVP_TextGrayColor kVP_Color(102, 102, 102, 1)
#define kVP_BgColor kVP_Color(248, 248, 248, 1);
#define kVP_LineColor kVP_Color(223, 223, 223, 1);
#define kVP_HRectangleSeparatorColor kVP_ColorWithHexValueA(0xF6F6F6,1)

// 主题色
#define kVP_ThemeColor kVP_ColorWithHexValueA(0x1F93EA,1)

#define kVP_TitleBlackColor kVP_ColorWithHexValueA(0x444444,1)

// 字体大小
#define kVP_Font(value) [UIFont systemFontOfSize:value]
#define kVP_BFont(value) [UIFont boldSystemFontOfSize:value]

#define kVP_isIphone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kVP_isIPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kVP_isIphone4  (kVP_isIphone && kVP_ScreenHeight == 480.0)

#define kVP_IOS13 ([UIDevice currentDevice].systemVersion.doubleValue >= 13.0)
#define kVP_IOS11 ([UIDevice currentDevice].systemVersion.doubleValue >= 11.0)
#define kVP_IOS9 ([UIDevice currentDevice].systemVersion.doubleValue >= 9.0)
#define kVP_IOS8 ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0)

#define KVP_DocDirFilePath(fileName) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:fileName]

#define kVP_StatusBarHidden(hidden) ([UIApplication sharedApplication].statusBarHidden = hidden);

