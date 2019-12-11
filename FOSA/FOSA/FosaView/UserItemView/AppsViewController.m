//
//  AppsViewController.m
//  FOSA
//
//  Created by hs on 2019/12/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "AppsViewController.h"

@interface AppsViewController ()

@property (nonatomic,strong) UIImageView *appsImage;
@property (nonatomic,strong) UILabel *appVersion;

@end

@implementation AppsViewController
/** 屏幕高度 */
#define screen_height [UIScreen mainScreen].bounds.size.height
/** 屏幕宽度 */
#define screen_width [UIScreen mainScreen].bounds.size.width
//判断是否是iPad
#define ISIPAD [[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPad
//判断手机型号为X
#define is_IPHONEX [[UIScreen mainScreen] bounds].size.width == 375.0f &&([[UIScreen mainScreen] bounds].size.height == 812.0f)
//获取状态栏的高度 iPhone X - 44pt 其他20pt
#define StatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
//获取导航栏的高度 - （不包含状态栏高度） 44pt
#define NavigationBarHeight self.navigationController.navigationBar.frame.size.height
//屏幕底部 tabBar高度49pt + 安全视图高度34pt(iPhone X)
#define TabbarHeight self.tabBarController.tabBar.frame.size.height
//屏幕顶部 导航栏高度（包含状态栏高度）
#define NavigationHeight (StatusBarHeight + NavigationBarHeight)
//屏幕底部安全视图高度 - 适配iPhone X底部
#define TOOLH (is_IPHONEX ? 34 : 0)
//屏幕底部 toolbar高度 + 安全视图高度34pt
#define ToolbarHeight self.navigationController.toolbar.frame.size.height
//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    self.navigationController.navigationBarHidden = NO;
//}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self InitAppsView];
}

- (void)InitAppsView{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, NavigationHeight, screen_width, screen_width*2/5)];
    [self.view addSubview:view];
    view.backgroundColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0];
    
    self.appsImage = [[UIImageView alloc]initWithFrame:CGRectMake(screen_width*2/5, screen_width/10, screen_width/5, screen_width/5)];
    _appsImage.image = [UIImage imageNamed:@"icon_logoHL"];
    [view addSubview:_appsImage];
    
    self.appVersion = [[UILabel alloc]initWithFrame:CGRectMake(screen_width*1/4, screen_width*3/10, screen_width/2, screen_width/10)];
    self.appVersion.text=@"Current Version 1.0.0";
    self.appVersion.textAlignment = NSTextAlignmentCenter;
    [view addSubview:self.appVersion];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
