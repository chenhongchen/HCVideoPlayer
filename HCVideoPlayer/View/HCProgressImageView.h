//
//  HCProgressImageView.h
//  FLAnimatedImage
//
//  Created by chc on 2020/3/2.
//

#import <UIKit/UIKit.h>

@interface HCProgressImageView : UIView
@property (nonatomic, copy) NSString *playUrl;
@property (nonatomic, assign) NSTimeInterval curSec;
@property (nonatomic, assign) NSTimeInterval totalSec;
- (void)showWithCurSec:(NSTimeInterval)curSec;
- (void)hiddenSelf;
@end
