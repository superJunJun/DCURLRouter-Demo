//
//  ISGBaseTabBarController.m
//  iShanggang
//
//  Created by lijun on 2017/4/20.
//  Copyright © 2017年 aishanggang. All rights reserved.
//

#import "ISGBaseTabBarController.h"
//#import "ASGFileResourceManager.h"
//#import "LoginViewController.h"
//#import "ZhiMaNavViewController.h"

#define sFirstTimeLaunchedMarkKey               @"firstTimeLaunchedMark"

@interface ISGBaseTabBarController ()
{
    BOOL _isAppProfileVisible;
}
@end

@implementation ISGBaseTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self customTabBarLoad];
//    self.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)customTabBarLoad
{
    UITabBar *tabBar = self.tabBar;
    tabBar.barStyle = UIBarStyleBlack;
    tabBar.translucent = NO;
    UIColor *tintColor = [UIColor whiteColor];
    tabBar.tintColor = tintColor;
    if([tabBar respondsToSelector:@selector(barTintColor)])
    {
        tabBar.barTintColor = tintColor;
    }
    //tabBar上的灰色线
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 0.5)];
    lineView.backgroundColor = [UIColor grayColor];
    [tabBar addSubview:lineView];
    
    UITabBarItem *item0 = [tabBar.items objectAtIndex:0];
    UITabBarItem *item1 = [tabBar.items objectAtIndex:1];
    UITabBarItem *item2 = [tabBar.items objectAtIndex:2];
    UITabBarItem *item3 = [tabBar.items objectAtIndex:3];
    
    // 对item设置相应地图片
    item0.selectedImage = [[UIImage imageNamed:@"hp_home_s"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
    item0.image = [[UIImage imageNamed:@"hp_home_n"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    item1.selectedImage = [[UIImage imageNamed:@"main_mall_c"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
    item1.image = [[UIImage imageNamed:@"main_mall"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    item2.selectedImage = [[UIImage imageNamed:@"main_recuit_c"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
    item2.image = [[UIImage imageNamed:@"main_recuit"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    item3.selectedImage = [[UIImage imageNamed:@"mine_me_s"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];;
    item3.image = [[UIImage imageNamed:@"mine_me_n"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
//    [item0 setTitleTextAttributes:@{NSForegroundColorAttributeName :cCommonRedColor} forState:UIControlStateSelected];
//    [item1 setTitleTextAttributes:@{NSForegroundColorAttributeName :cCommonRedColor} forState:UIControlStateSelected];
//    [item2 setTitleTextAttributes:@{NSForegroundColorAttributeName :cCommonRedColor} forState:UIControlStateSelected];
//    [item3 setTitleTextAttributes:@{NSForegroundColorAttributeName :cCommonRedColor} forState:UIControlStateSelected];
}

- (void)launchTimeInfoCheck
{
    NSString *markKey = sFirstTimeLaunchedMarkKey;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL isFirstTimeToLaunch = ![userDefaults boolForKey:markKey];
    if(isFirstTimeToLaunch)
    {
        [userDefaults setBool:YES forKey:markKey];
        [userDefaults synchronize];
    }
    _isAppProfileVisible = isFirstTimeToLaunch;
}

//#pragma mark - UITabBarControllerDelegate
//- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController {
//
//    NSArray *vcArr =  viewController.childViewControllers;
//    if (vcArr.count > 0) {
//        UIViewController *vc = vcArr[0];
//        if ([vc isKindOfClass:[ZhiMaNavViewController class]]) {
//            UINavigationController *nav = tabBarController.selectedViewController;
//
//            if ([[ISGUserInfo sharedUserInfo] isUserAccountEnable]) {
//
//                return YES;
//            } else {
//
//                LoginViewController *vc = [LoginViewController new];
//                [nav pushViewController:vc animated:YES];
//            }
//            return NO;
//        }
//    }
//
//    return YES;
//}


@end
