//
//  ViewController.m
//  fishGame
//
//  Created by XB on 2017/6/20.
//  Copyright © 2017年 Xiu8. All rights reserved.
//

#import "ViewController.h"
#import "XBFishGameView.h"

@interface ViewController ()<UICollisionBehaviorDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createFishGame];


}



- (void)createFishGame
{
    XBFishGameView *game = [[[NSBundle mainBundle]loadNibNamed:@"XBFishGameView" owner:nil options:nil]firstObject];
    game.frame = CGRectMake(0, self.view.bounds.size.height - 300, self.view.bounds.size.width, 300);
    [self.view addSubview:game];
    [game startGame];
}







@end
