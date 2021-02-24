//
//  HCSelEpisodePanel.h
//  HCVideoPlayer
//
//  Created by chc on 2018/7/22.
//  Copyright © 2018年 chc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCSelEpisodePanel;
@protocol HCSelEpisodePanelDelegate <NSObject>
- (void)selEpisodePanel:(HCSelEpisodePanel *)selEpisodePanel didClickItem:(NSString *)item atIndex:(NSInteger)index;
- (void)didHiddenSelEpisodePanel:(HCSelEpisodePanel *)selEpisodePanel;
@end

@interface HCSelEpisodePanel : UIView
@property (nonatomic, weak) id <HCSelEpisodePanelDelegate> delegate;
- (void)showPanelAtView:(UIView *)view;
- (void)hiddenPanel;
@property (nonatomic, strong) NSArray <NSString *> *items;
@property (nonatomic, assign) BOOL isBigType;
@property (nonatomic, assign) NSInteger selIndex;
@end
