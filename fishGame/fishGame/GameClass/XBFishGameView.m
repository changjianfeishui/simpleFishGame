//
//  XBFishGameView.m
//  com.wobo.live
//
//  Created by XB on 2017/7/12.
//  Copyright © 2017年 XB. All rights reserved.
//

#import "XBFishGameView.h"
#import "FishView.h"
#import "BulletView.h"

//鱼的种类数
static int fishTypeCount = 6;

@interface XBFishGameView()<UICollisionBehaviorDelegate>
@property (nonatomic,strong) UIDynamicAnimator  *animator; /**< */
@property (weak, nonatomic) IBOutlet UIImageView *batteryView;
@property (nonatomic,strong) CADisplayLink  *link; /**< */
@property (nonatomic,assign) int  power; /**<      */

@property (nonatomic,assign) NSTimeInterval  lastTime; /**<      <#note#>*/

@property (weak, nonatomic) IBOutlet UIButton *lockBtn;

@property (nonatomic,assign) BOOL lockMode; /**<    是否为锁定模式*/

@property (nonatomic,strong) CADisplayLink  *autoShootTimer; /**< */


@property (nonatomic,strong) FishView  *lockedFish; /**< */



@end
@implementation XBFishGameView

#pragma mark LifeCycle
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.power = 0;
    self.lastTime = 0;
    self.batteryView.layer.anchorPoint = CGPointMake(0.5, 1);
}

#pragma mark Public
- (void)startGame
{
    if (self.link) {
        return;
    }
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(p_createFish)];
    self.link.frameInterval = 60;
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

}

- (void)stopGame
{
    self.link.paused = YES;
    [self.link invalidate];
    self.link = nil;
}

-  (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    NSDate *localDate = [NSDate date]; //获取当前时间
    self.lastTime = [localDate timeIntervalSince1970];
    if (self.lockMode) {
        //清除上一条锁定记录
        self.lockedFish = nil;
        [self p_endAutoShooting];
        for (FishView *subView in self.subviews) {
            if ([subView isKindOfClass:[FishView class]]) {
                if ([subView.layer.presentationLayer hitTest:location]) {
                    //更新目标
                    self.lockedFish = subView;
                    break;
                }
            }
        }
        
        if (!self.lockedFish) {
            //锁定模式下点击空白区域,  退出锁定模式
            [self p_exitLockMode];
            return;
        }else{
            self.lockedFish.targetable = YES;
            [self.lockedFish showLock];
            //设置除锁定目标外的🐟为不可命中
            for (FishView *subView in self.subviews) {
                if ([subView isKindOfClass:[FishView class]]) {
                    if (subView != self.lockedFish) {
                        subView.targetable = NO;
                        [subView hideLock];
                    }
                }
            }
            self.autoShootTimer.paused = NO;
        }
        
    }else{
        [self p_shootingAtPoint:location];
    }


}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (self.lockMode) {
        return;
    }
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    
    NSDate *localDate = [NSDate date]; //获取当前时间
    if (self.lastTime == 0) {
        self.lastTime = [localDate timeIntervalSince1970];
        return;
    }else{
        NSTimeInterval currentTime = [localDate timeIntervalSince1970];
        
        NSTimeInterval interval = currentTime - self.lastTime;
        
        if (interval >= 0.2) {
            self.lastTime = currentTime;
            [self p_shootingAtPoint:location];
        }
    }
}


#pragma mark EventHandler
- (IBAction)tapToShot:(UITapGestureRecognizer *)sender {
    //rotation
    CGPoint location = [sender locationInView:self];
    [self p_shootingAtPoint:location];
 }


- (IBAction)lockFish:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {  //
        self.lockMode = YES;
    }else{
        //退出锁定模式
        [self p_exitLockMode];
    }
}




- (IBAction)voidTap:(UITapGestureRecognizer *)sender {
}


- (IBAction)powerPlus:(UIButton *)sender {
    NSString *imgName = [NSString stringWithFormat:@"shooting-barrel-lvl%d~iphone",(++self.power)%4];
    self.batteryView.image = [UIImage imageNamed:imgName];
}

- (IBAction)powerMinus:(UIButton *)sender {
    self.power--;
    if (self.power < 0) {
        self.power = 3;
    }
    NSString *imgName = [NSString stringWithFormat:@"shooting-barrel-lvl%d~iphone",(self.power)%4];
    self.batteryView.image = [UIImage imageNamed:imgName];
}



#pragma mark UICollisionBehaviorDelegate
- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(UIView *)item withBoundaryIdentifier:(nullable id <NSCopying>)identifier atPoint:(CGPoint)p
{
    [self.animator removeBehavior:behavior];
    [item removeFromSuperview];
    
    [self p_showGollisionAnimationImgvAtPoint:p];
    
    [self.animator removeBehavior:behavior];
    
}

#pragma mark Private

- (void)p_shootingAtPoint:(CGPoint)location
{
    CGPoint origin = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height);
    CGFloat angle = atan(((origin.x - location.x)/(origin.y - location.y)));
    CGAffineTransform transform = CGAffineTransformMakeRotation(-angle);
    self.batteryView.transform = transform;
    
    //bullet
    BulletView *bullet = [self p_getBullet];
    bullet.power = (self.power)%4 + 1;
    [self addSubview:bullet];
    [self bringSubviewToFront:self.batteryView];
    
    //collision
    //设置子弹碰撞边界
    UICollisionBehavior *boundryCollision = [[UICollisionBehavior alloc]initWithItems:@[bullet]];
    
    CGFloat height = self.frame.size.height;
    CGFloat width = self.frame.size.width;
    
    [boundryCollision addBoundaryWithIdentifier:@"top" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(width, 0)];
    [boundryCollision addBoundaryWithIdentifier:@"left" fromPoint:CGPointMake(0, 0) toPoint:CGPointMake(0, height)];
    [boundryCollision addBoundaryWithIdentifier:@"right" fromPoint:CGPointMake(width, 0) toPoint:CGPointMake(width, height)];
    
    boundryCollision.collisionMode = UICollisionBehaviorModeBoundaries;
    boundryCollision.collisionDelegate = self;
    [self.animator addBehavior:boundryCollision];
    
    [boundryCollision setAction:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"bulletFrameChanged" object:bullet];
    }];
    
    bullet.collision = boundryCollision;
    
    //shotting
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc]initWithItems:@[bullet] mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.angle = M_PI_2-                                                                                                                      angle;
    pushBehavior.magnitude = -0.15;
    [self.animator addBehavior:pushBehavior];

}


- (void)p_createFish
{
    //随机一种鱼
    NSInteger fishType = arc4random_uniform(fishTypeCount);
    
    FishView *fish = [FishView fishViewWithFishType:fishType];
    fish.blood = (fishType + 1) * 2; //鱼越大, 生命值越高
    //direction
    NSInteger direction = arc4random_uniform(2);
    fish.direction = (direction == 0)?XBFishSwimmingDirectionLeft:XBFishSwimmingDirectionRight;
    CGFloat y = arc4random_uniform(self.bounds.size.height - 100);
    fish.appearY = y;
    
    //duration
    fish.duration = fishType + 10;
    
    
    //是否已经有鱼被锁定
    fish.targetable = !self.lockedFish;
    
    __weak typeof(self) weakSelf = self;
    [self insertSubview:fish atIndex:1];
    [fish beginSwimming];
    
    fish.fishDismiss = ^(BOOL isLocked){
        if (isLocked) {
            [weakSelf p_exitLockMode];
        }
    };

    fish.fishHitSuccess = ^(BulletView *bullet){
        [weakSelf p_showGollisionAnimationImgvAtPoint:bullet.center];
        [bullet removeFromSuperview];
        [weakSelf.animator removeBehavior:bullet.collision];

    };
}



- (void)p_exitLockMode
{
    self.lockedFish = nil;
    self.lockMode = NO;
    self.lockBtn.selected = NO;
    [self p_endAutoShooting];
    //重新设置所有鱼为可命中
    for (FishView *subView in self.subviews) {
        if ([subView isKindOfClass:[FishView class]]) {
            subView.targetable = YES;
            [subView hideLock];
        }
    }
}





- (BulletView *)p_getBullet
{
    BulletView *bullet = [[BulletView alloc]initWithFrame:CGRectMake(0, 0, 13, 15)];
    bullet.center = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height);
    bullet.image = [UIImage imageNamed:@"fish_hook_2"];
    
    return bullet;
    
}

//炮弹爆炸动画
- (void)p_showGollisionAnimationImgvAtPoint:(CGPoint)p
{
    NSMutableArray *fishAni = [NSMutableArray arrayWithCapacity:10];
    for (int i = 0; i < 10; i++) {
        NSString *picName = [NSString stringWithFormat:@"sheji-animation3_%d~iphone",i];
        UIImage *pic = [UIImage imageNamed:picName];
        [fishAni addObject:pic];
    }
    UIImageView *imgv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 150, 126)];
    imgv.animationImages = fishAni;
    [imgv setAnimationRepeatCount:0];
    [imgv setAnimationDuration:1];
    imgv.center = p;
    [imgv startAnimating];
    [self addSubview:imgv];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imgv removeFromSuperview];
    });
}

- (void)p_beginAutoShooting
{
    NSLog(@"自动射击中");
    CGPoint point = self.lockedFish.layer.presentationLayer.frame.origin;
    if (self.lockedFish.direction == XBFishSwimmingDirectionLeft) {
        point = CGPointMake(point.x + self.lockedFish.frame.size.width, point.y);
    }else
    {
        point = CGPointMake(point.x + self.lockedFish.frame.size.width * 0.1, point.y);
    }
    [self p_shootingAtPoint:point];
}

- (void)p_endAutoShooting
{
    if (!self.autoShootTimer.isPaused) {
        self.autoShootTimer.paused = YES;
    }
}

#pragma mark Accessor
- (UIDynamicAnimator *)animator
{
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc]initWithReferenceView:self];
    }
    return _animator;
}

- (CADisplayLink *)autoShootTimer
{
    if (!_autoShootTimer) {
        _autoShootTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(p_beginAutoShooting)];
        _autoShootTimer.frameInterval = 12; //12
        [_autoShootTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
        _autoShootTimer.paused = YES;
    }
    return _autoShootTimer;
}

@end
