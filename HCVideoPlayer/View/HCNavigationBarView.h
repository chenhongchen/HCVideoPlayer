//
//  HCNavigationBarView.h
//  FLAnimatedImage
//
//  Created by chc on 2019/10/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HCNavigationBarView;
@protocol HCNavigatioBarViewDelegate <NSObject>
@optional
- (void)didClickBackBtnForNavigationBarView:(HCNavigationBarView *)navigationBarView;
@end

@interface HCNavigationBarView : UIView
@property (nonatomic, weak) id <HCNavigatioBarViewDelegate> delegate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, assign) CGFloat barHeight;
@property (nonatomic, strong) UIColor *backBtnColor;
@property (nonatomic, assign) BOOL hiddenBackBtn;
@property (nonatomic, strong) NSArray *rightBtns;
@property (nonatomic, strong) UIColor *botLineColor;
// 不自己设置btn宽高的时候有效，给btn另加的宽度，增大点击区域，默认是20；
@property (nonatomic, assign) CGFloat autoAddRightBtnsW;
- (void)addRightBtn:(UIButton *)rightBtn;
- (CGFloat)titleCenterX;
@end

NS_ASSUME_NONNULL_END
