//
//  ViewController.m
//  fishGame
//
//  Created by XB on 2017/6/20.
//  Copyright © 2017年 Xiu8. All rights reserved.
//

#import "ViewController.h"
#import "FishView.h"
#import "BulletView.h"

@interface ViewController ()<UICollisionBehaviorDelegate>
@property (weak, nonatomic) IBOutlet UIView *fishesContainView;
@property (weak, nonatomic) IBOutlet UIImageView *batteryView;
@property (nonatomic,strong) UIDynamicAnimator  *animator; /**< */



@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(createFish)];
    link.frameInterval = 20;
    [link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [self createFish];

    self.batteryView.layer.anchorPoint = CGPointMake(0.5, 1);
}



- (void)createFish
{
    FishView *fish = [FishView fishView];
//    __weak typeof(fish) weakFish = fish;
    __weak typeof(self) weakSelf = self;

    [self.fishesContainView insertSubview:fish atIndex:1];
    [fish beginSwimming];

    fish.fishHitSuccess = ^(BulletView *bullet){
        [self.animator removeBehavior:bullet.collision];
        [bullet removeFromSuperview];
        [weakSelf p_showGollisionAnimationImgvAtPoint:bullet.center];
    };
    
}


#pragma mark Event
- (IBAction)tapToShot:(UITapGestureRecognizer *)sender {
    //rotation
    CGPoint location = [sender locationInView:self.fishesContainView];
    CGPoint origin = CGPointMake(self.fishesContainView.frame.size.width * 0.5, self.fishesContainView.frame.size.height);
    CGFloat angle = atan(((origin.x - location.x)/(origin.y - location.y)));
    CGAffineTransform transform = CGAffineTransformMakeRotation(-angle);
    self.batteryView.transform = transform;
    
    //bullet
    BulletView *bullet = [self getBullet];
    [self.fishesContainView addSubview:bullet];
    [self.fishesContainView bringSubviewToFront:self.batteryView];
    
    //collision
    //设置子弹碰撞边界
    UICollisionBehavior *boundryCollision = [[UICollisionBehavior alloc]initWithItems:@[bullet]];

    CGFloat height = self.fishesContainView.frame.size.height;
    CGFloat width = self.fishesContainView.frame.size.width;
    
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
- (BulletView *)getBullet
{
//    NSString *str = NSStringFromCGRect(self.batteryView.frame);
//    NSLog(@"当前炮的frame===%@",str);

    
    BulletView *bullet = [[BulletView alloc]initWithFrame:CGRectMake(0, 0, 13, 15)];
    bullet.center = CGPointMake(self.fishesContainView.frame.size.width * 0.5, self.fishesContainView.frame.size.height);
    bullet.image = [UIImage imageNamed:@"fish_hook_2"];
    
    return bullet;
    
}

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
    [self.fishesContainView addSubview:imgv];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [imgv removeFromSuperview];
    });
    
}


#pragma mark Accessor
- (UIDynamicAnimator *)animator
{
    if (!_animator) {
        _animator = [[UIDynamicAnimator alloc]initWithReferenceView:self.fishesContainView];
    }
    return _animator;
}




@end
