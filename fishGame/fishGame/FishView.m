//
//  FishView.m
//  fishGame
//
//  Created by XB on 2017/7/10.
//  Copyright © 2017年 Xiu8. All rights reserved.
//

#import "FishView.h"
//鱼的种类数
static int fishKind = 6;
//每种鱼的动画图片数
static NSInteger fishAnimationCount = 10;

//鱼位移动画持续时间
static NSTimeInterval kFishSwimmingAnimationDuration = 10;

@interface FishView()
@property (nonatomic,assign) NSInteger  kind; /**<      鱼的种类*/


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
+ (FishView *)fishView
{
    //随机一种鱼
    NSInteger fishClass = arc4random_uniform(fishKind);
    //获取动画图片
    NSMutableArray *fishAni = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < fishAnimationCount; i++) {
        NSString *picName = [NSString stringWithFormat:@"fish_%d_animation_%d",(int)fishClass,i];
        UIImage *pic = [UIImage imageNamed:picName];
        [fishAni addObject:pic];
    }
    
    //获取鱼类图片尺寸
    CGSize fishSize = [self p_fishSize:fishClass];
    //设置动画
    FishView *fishPicV = [[FishView alloc]initWithFrame:CGRectMake(0, 0, fishSize.width, fishSize.height)];
    fishPicV.kind = fishClass;
    [fishPicV setAnimationImages:fishAni];
    [fishPicV setAnimationRepeatCount:0];
    [fishPicV setAnimationDuration:3];
    
    return fishPicV;
}

- (void)beginSwimming
{
    CGPoint point = [self p_randomPosition];
    self.frame = CGRectMake(point.x, point.y, self.frame.size.width, self.frame.size.height);
    [self startAnimating];
    CGRect frame = self.frame;
    __weak typeof(self) weakSelf = self;
    if (frame.origin.x < 0) {
        frame.origin.x = self.superview.frame.size.width;
        self.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        
        [UIView animateWithDuration:kFishSwimmingAnimationDuration animations:^{
            self.frame = frame;
        } completion:^(BOOL finished) {
            [weakSelf removeFromSuperview];

        }];
    }else{
        frame.origin.x = -self.frame.size.width;
        [UIView animateWithDuration:kFishSwimmingAnimationDuration animations:^{
            self.frame = frame;
        } completion:^(BOOL finished) {
 
            [weakSelf removeFromSuperview];
        }];
    }

}



#pragma mark Private
- (void)p_regiNoti
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(p_logFrame:) name:@"bulletFrameChanged" object:nil];
}

- (void)p_logFrame:(NSNotification *)noti
{
    UIImageView *imgv = noti.object;
    CGPoint point = imgv.center;
    
    CGRect presentFrame = self.layer.presentationLayer.frame;
    
    //有效命中范围内才能打死鱼
    CGRect hitFrame = UIEdgeInsetsInsetRect(presentFrame, UIEdgeInsetsMake(0, 0, presentFrame.size.height * 0.5, 0));
    
    if (CGRectContainsPoint(hitFrame, point)) {
//        NSLog(@"成功命中");
        if (self.fishHitSuccess) {
            self.fishHitSuccess((BulletView *)imgv);
        }
        
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

        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        });
    }
}

//随机初始化坐标, 及左右出场
- (CGPoint)p_randomPosition
{
    NSAssert(self.superview, @"FishView还没有被添加到父视图上");
    CGFloat canvasWidth = self.superview.frame.size.width;
    CGFloat canvasHeight = self.superview.frame.size.height;
    CGFloat x,y;
    NSInteger direction = arc4random_uniform(2);
    if (direction == 0) {
        x = -self.bounds.size.width;
    }else{
        x = canvasWidth;
    }
    
    y = arc4random_uniform(canvasHeight - self.bounds.size.height - 100);
    return CGPointMake(x, y);
}

+ (CGSize)p_fishSize:(NSInteger)fishClass
{
    CGFloat height;
    CGFloat width;
    switch (fishClass) {
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



@end
