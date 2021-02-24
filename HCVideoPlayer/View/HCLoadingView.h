//
//  HCLoading.h
//  HCVideoPlayer
//
//  Created by chc on 2019/5/9.
//  Copyright © 2019 chc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HCLoadingView : UIView
@property (nonatomic, assign, readonly) BOOL isLoading;
- (void)startAnimating;
- (void)stopAnimating;
@end
