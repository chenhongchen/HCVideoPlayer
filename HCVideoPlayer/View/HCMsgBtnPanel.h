//
//  HCMsgBtnPanel.h
//  HCVideoPlayer
//
//  Created by chc on 2019/5/14.
//  Copyright © 2019 chc. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ClickedOkBtnBLC)(NSString *type);

@interface HCMsgBtnPanel : UIView
+ (instancetype)showPanelAtView:(UIView *)view type:(NSString *)type msg:(NSString *)msg title:(NSString *)title clickedOkBtn:(ClickedOkBtnBLC)clickedOkBtn;
+ (void)hiddenPanelAtView:(UIView *)view type:(NSString *)type;
@end
