//
//  FosaProductViewController.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FosaProductViewController.h"
#import "AddViewController.h"
#import "ScanOneCodeViewController.h"
#import "PhotoViewController.h"

#import "FosaScrollview.h"
#import "productView.h"
#import "MyDeviceViewController.h"
#import "OtherViewController.h"



@interface FosaProductViewController ()
@property (nonatomic,strong) FosaScrollview *fosaScrollview;
@property (nonatomic,strong) productView *productContent;

@property (nonatomic, strong) NSMutableArray *controllersArr;/// 控制器数组
@property (nonatomic, strong) NSMutableArray *titleArray; /// 标题数组


@end

@implementation FosaProductViewController
/**随机颜色*/
#define RandomColor ([UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0])
/** 屏幕高度 */
#define screen_height [UIScreen mainScreen].bounds.size.height
/** 屏幕宽度 */
#define screen_width [UIScreen mainScreen].bounds.size.width

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];

    CGFloat productContentY = CGRectGetMaxY(self.fosaScrollview.frame);

    self.productContent.frame = CGRectMake(0, productContentY, screen_width, self.view.frame.size.height - productContentY);
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_add"] style:UIBarButtonItemStylePlain target:self action:@selector(addEvent)];
    [self InitContentView];
}
- (void)InitContentView
{
    //获取状态栏的rect
    CGRect statusRect = [[UIApplication sharedApplication] statusBarFrame];
    //获取导航栏的rect
    CGRect navRect = self.navigationController.navigationBar.frame;
    //那么导航栏+状态栏的高度
    self.status_nav_height = statusRect.size.height+navRect.size.height;
    NSArray *titles = @[@"FOSA",@"My Device"];
    self.fosaScrollview = [[FosaScrollview alloc] init];
    
    [self.fosaScrollview configParameterFrame:CGRectMake(0,self.status_nav_height, [UIScreen mainScreen].bounds.size.width, 50) titles:titles index:0 block:^(NSInteger index) {
        [self.productContent updateTab:index];
    }];
    
    self.fosaScrollview.bounces = NO;
    [self.view addSubview:self.fosaScrollview];

    self.productContent = [[productView alloc] init];
    [self.view addSubview:self.productContent];

    NSMutableArray *contentM = [NSMutableArray array];
    MyDeviceViewController *mydevice = [[MyDeviceViewController alloc]init];
    mydevice.view.backgroundColor = [UIColor whiteColor];
    [contentM addObject:mydevice];

    OtherViewController *other = [[OtherViewController alloc]init];
    other.view.backgroundColor = [UIColor whiteColor];
    [contentM addObject:other];

    [self.productContent configParam:contentM index:0 block:^(NSInteger index) {
        [self.fosaScrollview tabOffset:index];
    }];
}
- (void)addEvent{
    PhotoViewController *photo = [[PhotoViewController alloc]init];
    photo.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:photo animated:YES];
}
- (void)didReceiveMemoryWarning {
 [super didReceiveMemoryWarning];
 // Dispose of any resources that can be recreated.

}

@end
