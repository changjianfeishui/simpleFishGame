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

@end
@implementation XBFishGameView

#pragma mark LifeCycle
- (void)awakeFromNib
{
    [super awakeFromNib];
    self.batteryView.layer.anchorPoint = CGPointMake(0.5, 1);
}

#pragma mark Public
- (void)startGame
{
    if (self.link) {
        return;
    }
    self.link = [CADisplayLink displayLinkWithTarget:self selector:@selector(p_createFish)];
    self.link.frameInterval = 20;
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

}

- (void)stopGame
{
    self.link.paused = YES;
    [self.link invalidate];
    self.link = nil;
}

#pragma mark EventHandler
- (IBAction)tapToShot:(UITapGestureRecognizer *)sender {
    //rotation
    CGPoint location = [sender locationInView:self];
    CGPoint origin = CGPointMake(self.frame.size.width * 0.5, self.frame.size.height);
    CGFloat angle = atan(((origin.x - location.x)/(origin.y - location.y)));
    CGAffineTransform transform = CGAffineTransformMakeRotation(-angle);
    self.batteryView.transform = transform;
    
    //bullet
    BulletView *bullet = [self p_getBullet];
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
    pushBehavior.magnitude = -0.1;
    [self.animator addBehavior:pushBehavior];
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
- (void)p_createFish
{
    //随机一种鱼
    NSInteger fishType = arc4random_uniform(fishTypeCount);
    
    FishView *fish = [FishView fishViewWithFishType:fishType];
    
    //direction
    NSInteger direction = arc4random_uniform(2);
    fish.direction = (direction == 0)?XBFishSwimmingDirectionLeft:XBFishSwimmingDirectionRight;
    CGFloat y = arc4random_uniform(self.bounds.size.height - 100);
    fish.appearY = y;
    
    //duration
    fish.duration = 10 - fishType;
    
    __weak typeof(self) weakSelf = self;
    [self insertSubview:fish atIndex:1];
    [fish beginSwimming];
    
    fish.fishHitSuccess = ^(BulletView *bullet){
        [weakSelf.animator removeBehavior:bullet.collision];
        [bullet removeFromSuperview];
        [weakSelf p_showGollisionAnimationImgvAtPoint:bullet.center];
    };
    
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
#pragma mark Accessor
- (UIDynamicAnimator *)animator
{
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc]initWithReferenceView:self];
    }
    return _animator;
}
@end
