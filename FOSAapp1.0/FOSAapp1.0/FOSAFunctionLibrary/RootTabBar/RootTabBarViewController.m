//
//  RootTabBarViewController.m
//  FOSAapp1.0
//
//  Created by hs on 2019/12/30.
//  Copyright © 2019 hs. All rights reserved.
//

#import "RootTabBarViewController.h"
#import "MainViewController.h"
#import "SealerAndPoundViewController.h"
#import "ProductViewController.h"
#import "UserViewController.h"

@interface RootTabBarViewController ()

@end

@implementation RootTabBarViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"RootView Begin");
    // Do any additional setup after loading the view.
    [self addChildWithVCName:@"MainViewController" title:@"FOSA" image:@"icon_main" selectImage:@"icon_mainHL"];
    [self addChildWithVCName:@"SealerAndPoundViewController" title:@"Device" image:@"icon_sealer" selectImage:@"icon_sealerHL"];
    [self addChildWithVCName:@"ProductViewController" title:@"Product" image:@"icon_device" selectImage:@"icon_deviceHL"];
    [self addChildWithVCName:@"UserViewController" title:@"Me" image:@"icon_me" selectImage:@"icon_meHL"];
}
-(void)addChildWithVCName:(NSString *)vcName title:(NSString *)title image:(NSString *)image selectImage:(NSString *)selectImage{
    //1.创建控制器
    Class class = NSClassFromString(vcName);//根据传入的控制器名称获得对应的控制器
    UIViewController *fosa = [[class alloc]init];
    
    //2.设置控制器属性
    fosa.navigationItem.title = title;
    fosa.tabBarItem.title = title;
    
    fosa.tabBarItem.image = [UIImage imageNamed:image];
    
    fosa.tabBarItem.selectedImage = [UIImage imageNamed:selectImage];
    
    //修改字体颜色
    [fosa.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:FOSAgreen} forState:UIControlStateHighlighted];
    
    //3.创建导航控制器
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:fosa];
    
    //设置背景透明图片,使得导航栏透明的同时item不透明
    [nvc.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    //去掉 bar 下面有一条黑色的线
    [nvc.navigationBar setShadowImage:[UIImage new]];
    //[[UINavigationBar appearance]setTintColor:[UIColorwhiteColor]];
    nvc.navigationBar.tintColor = [UIColor grayColor];
   
    [nvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    //4.添加到标签栏控制器
    [self addChildViewController:nvc];
}
//禁止应用屏幕自动旋转
- (BOOL)shouldAutorotate{
    return NO;
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
