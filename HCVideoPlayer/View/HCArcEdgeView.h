//
//  HCArcEdgeView.h
//  HCVideoPlayer
//
//  Created by chc on 2018/11/12.
//  Copyright © 2018年 chc. All rights reserved.
//

typedef enum {
    HCArcEdgeViewTypeTop,
    HCArcEdgeViewTypeLeft,
    HCArcEdgeViewTypeBottom,
    HCArcEdgeViewTypeRight
}HCArcEdgeViewType;

#import <UIKit/UIKit.h>

@interface HCArcEdgeView : UIView
@property (nonatomic, assign) HCArcEdgeViewType type;
@property (nonatomic, assign) CGFloat height;
@end
