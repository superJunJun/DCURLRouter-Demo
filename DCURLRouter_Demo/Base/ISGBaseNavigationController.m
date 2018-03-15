//
//  ISGBaseNavigationController.m
//  iShanggang
//
//  Created by lijun on 2017/4/20.
//  Copyright © 2017年 aishanggang. All rights reserved.
//

#import "ISGBaseNavigationController.h"

@interface ISGBaseNavigationController () <UITabBarControllerDelegate,UITabBarDelegate>

@end

@implementation ISGBaseNavigationController

+ (void)initialize
{
    // 1.设置导航栏主题
    [self setupNavBarTheme];
    // 2.设置导航栏按钮主题
    [self setupBarButtonItemTheme];
}

/**
 *  设置 导航栏 主题
 */
+ (void)setupNavBarTheme
{
    // 取出appearance对象
    UINavigationBar *navBar = [UINavigationBar appearance];
    navBar.translucent = NO;
    // 设置导航栏的被禁颜色属性
    [navBar setTintColor:[UIColor whiteColor]];
//    navBar.barTintColor = cCommonRedColor;
    
    // 设置文字的属性
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] =[UIColor whiteColor];
//    textAttrs[NSFontAttributeName] = [BOAssistor defaultTextStringFontWithSize:17.0];
    [navBar setTitleTextAttributes:textAttrs];
    
    // 设置返回按钮
    UIImage *backImage = [UIImage imageNamed:@"p_backArrow"];
//    backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    [UINavigationBar appearance].backIndicatorImage = backImage;
    [UINavigationBar appearance].backIndicatorTransitionMaskImage = backImage;
    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    [[UINavigationBar appearance] setBackgroundImage:[[UIImage alloc] init] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
//    [[UIBarButtonItem appearance] setBackButtonTitlePositionAdjustment:UIOffsetMake(0, -60)
//                                                         forBarMetrics:UIBarMetricsDefault];
}

//  设置 （left right）按钮 主题
+ (void)setupBarButtonItemTheme
{
    UIBarButtonItem * item = [UIBarButtonItem appearance];
    
    // 设置普通状态
    NSMutableDictionary *textAttrs = [NSMutableDictionary dictionary];
    textAttrs[NSForegroundColorAttributeName] = [UIColor whiteColor];
//    textAttrs[NSFontAttributeName] = [BOAssistor defaultTextStringFontWithSize:15.0];
    [item setTitleTextAttributes:textAttrs forState:UIControlStateNormal];
    
    // 设置不可用状态
    NSMutableDictionary *disableTextAttrs = [NSMutableDictionary dictionary];
    disableTextAttrs[NSForegroundColorAttributeName] =[UIColor whiteColor];
//    disableTextAttrs[NSFontAttributeName] = [BOAssistor defaultTextStringFontWithSize:15.0];
    [item setTitleTextAttributes:disableTextAttrs forState:UIControlStateDisabled];
}

#pragma mark - Push

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    viewController.hidesBottomBarWhenPushed = YES;
    [super pushViewController:viewController animated:animated];
} 


@end
