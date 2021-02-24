//
//  HCSmallWindow.h
//
//  Created by chc on 2019/12/27.
//  Copyright © 2019. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCSmallWindow : UIWindow
+ (instancetype)showWithRootView:(UIView *)rootView onClick:(BOOL (^)(UIView *rootView))onClick onClose:(void (^)(UIView *rootView))onClose;
+ (void)removeSmallWindow;
+ (HCSmallWindow *)curSmallWindow;
@end
