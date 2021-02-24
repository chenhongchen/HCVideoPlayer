//
//  HCCornerAdView.h
//
//  Created by chc on 2020/1/3.
//  Copyright © 2020. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HCVideoAdItem.h"

@class HCCornerAdView;
@protocol HCCornerAdViewDelegate <NSObject>
@optional
- (void)didClickCloseBtnForCornerAdView:(HCCornerAdView *)cornerAdView;
- (void)cornerAdView:(HCCornerAdView *)cornerAdView didClickAdItem:(HCVideoAdItem *)adItem;
@end

@interface HCCornerAdView : UIView
@property (nonatomic, strong) NSArray <HCVideoAdItem *> *cornerItems;
@property (nonatomic, weak) id <HCCornerAdViewDelegate> delegate;
@end
