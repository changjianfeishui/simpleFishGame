//
//  FishView.h
//  fishGame
//
//  Created by XB on 2017/7/10.
//  Copyright © 2017年 Xiu8. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BulletView;
@interface FishView : UIImageView
/**
 随机生成一种鱼,并配置动画
 */
+ (FishView *)fishView;

/**
 生成随机坐标
 */
//- (CGPoint)randomPosition;


/**
  鱼开始游泳
 */
- (void)beginSwimming;

@property (nonatomic,copy)  void (^fishHitSuccess)(BulletView *bullet); /**<      */


@end
