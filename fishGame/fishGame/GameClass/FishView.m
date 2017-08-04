//
//  FishView.m
//  fishGame
//
//  Created by XB on 2017/7/10.
//  Copyright © 2017年 Xiu8. All rights reserved.
//

#import "FishView.h"
#import "BulletView.h"

//每种鱼的动画图片数
static NSInteger fishAnimationCount = 10;



@interface FishView()
@property (nonatomic,assign) NSInteger  kind; /**<      鱼的种类*/

@property (nonatomic,strong) UIImageView  *lock; /**< 🔐*/

@end


@implementation FishView
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_regiNoti];
    }
    return self;
}

#pragma mark Public
+ (FishView *)fishViewWithFishType:(XBFishType)fishType
{
    //获取动画图片
    NSMutableArray *fishAni = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < fishAnimationCount; i++) {
        NSString *picName = [NSString stringWithFormat:@"fish_%d_animation_%d",(int)fishType,i];
        UIImage *pic = [UIImage imageNamed:picName];
        [fishAni addObject:pic];
    }
    
    //获取鱼类图片尺寸
    CGSize fishSize = [self p_fishSize:fishType];
    //设置动画
    FishView *fishPicV = [[FishView alloc]initWithFrame:CGRectMake(0, 0, fishSize.width, fishSize.height)];
    fishPicV.kind = fishType;
    [fishPicV setAnimationImages:fishAni];
    [fishPicV setAnimationRepeatCount:0];
    [fishPicV setAnimationDuration:3];
    
    return fishPicV;
}

- (void)beginSwimming
{
    NSAssert(self.superview, @"必须先把鱼放入池中");
    CGFloat x = 0;
    
    if (self.direction == XBFishSwimmingDirectionLeft) {
        x = -self.bounds.size.width;
    }else{
        x = self.superview.bounds.size.width;
    }
    
    self.frame = CGRectMake(x, self.appearY, self.frame.size.width, self.frame.size.height);
    [self startAnimating];
    CGRect frame = self.frame;
    __weak typeof(self) weakSelf = self;
    if (self.direction == XBFishSwimmingDirectionLeft) {
        frame.origin.x = self.superview.bounds.size.width - self.frame.size.width * 0.1;
        self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        
        [UIView animateWithDuration:self.duration animations:^{
            self.frame = frame;
        } completion:^(BOOL finished) {
            if (weakSelf.fishDismiss) {
                weakSelf.fishDismiss(!(weakSelf.lock == nil));
            }
            [weakSelf removeFromSuperview];

        }];
    }else{
        frame.origin.x = -self.bounds.size.width + self.frame.size.width * 0.1;
        [UIView animateWithDuration:self.duration animations:^{
            self.frame = frame;
        } completion:^(BOOL finished) {
            if (weakSelf.fishDismiss) {
                weakSelf.fishDismiss(!(weakSelf.lock == nil));
            }
            [weakSelf removeFromSuperview];
        }];
    }

}
- (void)showLock
{
     self.lock = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"phhd_miaozhun1"]];
    [self addSubview:self.lock];
    self.lock.center = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
}

- (void)hideLock
{
    [self.lock removeFromSuperview];
    self.lock = nil;
}
#pragma mark Private
- (void)p_regiNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_logFrame:) name:@"bulletFrameChanged" object:nil];
}

- (void)p_logFrame:(NSNotification *)noti
{
    if (!self.targetable) {
        return;
    }
    
    BulletView *imgv = noti.object;
    CGPoint point = imgv.center;
    
    CGRect presentFrame = self.layer.presentationLayer.frame;
    
    //有效命中范围内才能打死鱼
    CGRect hitFrame = UIEdgeInsetsInsetRect(presentFrame, UIEdgeInsetsMake(0, 0, presentFrame.size.height * 0.5, 0));
    
    if (CGRectContainsPoint(hitFrame, point)) {
        if (self.fishHitSuccess) {
            self.fishHitSuccess((BulletView *)imgv);
        }
        self.blood -= imgv.power;
        if (self.blood > 0) {

            return;
        }
//        if (self.fishDead) {
//            self.fishDead((BulletView *)imgv);
//        }
        
        [self.layer removeAllAnimations];

        
        UIImageView *imgv = [[UIImageView alloc]initWithFrame:presentFrame];
        imgv.transform = self.transform;
        //获取动画图片
        NSMutableArray *fishAni = [NSMutableArray arrayWithCapacity:10];
        for (int i = 0; i < fishAnimationCount; i++) {
            NSString *picName = [NSString stringWithFormat:@"fish_%d_animation_%d",(int)self.kind,i];
            UIImage *pic = [UIImage imageNamed:picName];
            [fishAni addObject:pic];
        }
        [imgv setAnimationImages:fishAni];
        [imgv setAnimationRepeatCount:0];
        [imgv setAnimationDuration:0.5];
        [imgv startAnimating];
        [self.superview addSubview:imgv];
        
        [UIView animateWithDuration:0.5 animations:^{
            imgv.alpha = 0.5;
        } completion:^(BOOL finished) {
            [imgv removeFromSuperview];
        }];

        [self removeFromSuperview];

    }
}



+ (CGSize)p_fishSize:(NSInteger)fishType
{
    CGFloat height;
    CGFloat width;
    switch (fishType) {
        case 0:
            width = 31;
            height = 40;
            break;
        case 1:
            width = 53;
            height = 51;
            break;
        case 2:
            width = 49;
            height = 44;
            break;
        case 3:
            width = 66;
            height = 53;
            break;
        case 4:
            width = 55;
            height = 57;
            break;
        case 5:
            width = 145;
            height = 93;
            break;
        default:
            width = 0;
            height = 0;
            break;
    }
    return CGSizeMake(width, height);
}

#pragma mark Accesstor


@end
