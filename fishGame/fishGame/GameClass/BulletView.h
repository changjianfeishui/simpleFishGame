//
//  BulletView.h
//  fishGame
//
//  Created by XB on 2017/7/11.
//  Copyright © 2017年 Xiu8. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BulletView : UIImageView
@property (nonatomic,weak) UICollisionBehavior  *collision; /**< <#note#>*/
@property (nonatomic,assign) NSInteger power; /**<      子弹攻击力*/


@end
