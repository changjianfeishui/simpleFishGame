//
//  FishView.h
//  fishGame
//
//  Created by XB on 2017/7/10.
//  Copyright © 2017年 Xiu8. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BulletView;

typedef NS_ENUM(NSInteger, XBFishSwimmingDirection) {
    XBFishSwimmingDirectionLeft,        //鱼从左侧出现
    XBFishSwimmingDirectionRight        //鱼从右侧出现
};

typedef NS_ENUM(NSInteger, XBFishType) {
    XBFishTypeOne,
    XBFishTypeTwo,
    XBFishTypeThree,
    XBFishTypeFour,
    XBFishTypeFive
};

@interface FishView : UIImageView
/**
 随机生成一种鱼
 */
+ (FishView *)fishViewWithFishType:(XBFishType)fishType;


/**
  鱼的血量
 */
@property (nonatomic,assign) NSInteger blood;




/**
 从左到右或从右到左一次完整动画的持续时间,决定鱼的速度
 */
@property (nonatomic,assign) NSTimeInterval  duration;

/**
 鱼从左侧还是右侧出现
 */
@property (nonatomic,assign) XBFishSwimmingDirection direction;

@property (nonatomic,assign) CGFloat appearY; /**<     鱼出现的y值(x值已由direction确定)*/



/**
  鱼开始游泳
 */
- (void)beginSwimming;

//命中后的回调
@property (nonatomic,copy)  void (^fishHitSuccess)(BulletView *bullet); /**<      */

//鱼被消灭的回调
@property (nonatomic,copy)  void (^fishDead)(BulletView *bullet); /**<      */


@end
