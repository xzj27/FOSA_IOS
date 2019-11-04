//
//  RootTabBarViewController.m
//  fosa1.0
//
//  Created by hs on 2019/10/16.
//  Copyright © 2019 hs. All rights reserved.
//

#import "RootTabBarViewController.h"
#import "FosaViewController.h"
#import "UserViewController.h"
#import "BltPoundViewController.h"
#import "ProductViewController.h"
#import "ScanFunction/ScanViewController.h"

@interface RootTabBarViewController ()

@end

@implementation RootTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.   
    [self addChildWithVCName:@"FosaViewController" title:@"fosa" image:@"tabbar_logo" selectImage:@"tabbar_logoHL"];
    [self addChildWithVCName:@"ProductViewController" title:@"product" image:@"tabbar_product" selectImage:@"tabbar_productHL"];
    [self addChildWithVCName:@"BltPoundViewController" title:@"Blt" image:@"tabbar_pound" selectImage:@"tabbar_poundHL"];
    [self addChildWithVCName:@"UserViewController" title:@"me" image:@"tabbar_me" selectImage:@"tabbar_meHL"];
    
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
    [fosa.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithRed:0/255.0 green:255/255.0 blue:51/255.0 alpha:1.0]} forState:UIControlStateHighlighted];
    //3.创建导航控制器
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:fosa];
        //设置背景颜色
    nvc.navigationBar.barTintColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0];
    nvc.navigationBar.tintColor = [UIColor blackColor];
    [nvc.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor]}];
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
