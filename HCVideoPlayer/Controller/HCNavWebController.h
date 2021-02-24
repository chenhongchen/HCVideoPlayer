//
//  HCNavWebController.h
//  FLAnimatedImage
//
//  Created by chc on 2019/10/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HCNavWebController;
@protocol HCNavWebControllerDelegate <NSObject>
- (void)didClickBackBtnForNavWebController:(HCNavWebController *)navWebController;
@end

@interface HCNavWebController : UIViewController
@property (nonatomic, strong) NSURL *url;
@property (assign, nonatomic) UIInterfaceOrientation presentationOrientation;
@property (nonatomic, weak) id <HCNavWebControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
