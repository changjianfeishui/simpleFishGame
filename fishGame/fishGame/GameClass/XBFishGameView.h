//
//  XBFishGameView.h
//  com.wobo.live
//
//  Created by XB on 2017/7/12.
//  Copyright © 2017年 XB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XBFishGameView : UIView

/**
 开始游戏 - 刷新鱼池
 */
- (void)startGame;


/**
  停止游戏 - 停止刷新鱼池(已存在的鱼不会移除)
 */
- (void)stopGame;
@end
