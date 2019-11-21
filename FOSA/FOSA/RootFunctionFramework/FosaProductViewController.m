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
@end

@implementation FosaProductViewController
#define RandomColor ([UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0])
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    CGFloat productContentY = CGRectGetMaxY(self.fosaScrollview.frame);
    
    self.productContent.frame = CGRectMake(0, productContentY, SCREEN_WIDTH, self.view.frame.size.height - productContentY);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_add"] style:UIBarButtonItemStylePlain target:self action:@selector(addEvent)];
    [self InitContentView];
}
- (void)InitContentView{
    self.rootView = [[UIView alloc]initWithFrame:CGRectMake(0, self.navHeight, self.mainWidth, self.mainHeight)];
    _rootView.backgroundColor = [UIColor whiteColor];
    
    
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    NSLog(@"------%f",self.navHeight);
    UIView *navV = [[UIView alloc] initWithFrame:CGRectMake(0, self.navHeight, SCREEN_WIDTH, self.navHeight)];
    navV.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:navV];
    
    NSArray *titles = @[@"Fosa Device",@"My Device"];
    self.fosaScrollview = [[FosaScrollview alloc] init];
    [self.fosaScrollview configParameterFrame:CGRectMake(0, CGRectGetMaxY(navV.frame), [UIScreen mainScreen].bounds.size.width, 50) titles:titles index:0 block:^(NSInteger index) {
        [self.productContent updateTab:index];
    }];
    self.fosaScrollview.bounces = NO;
    [self.view addSubview:self.fosaScrollview];
    
    self.productContent = [[productView alloc] init];
    [self.view addSubview:self.productContent];
    
    NSMutableArray *contentM = [NSMutableArray array];
    MyDeviceViewController *mydevice = [[MyDeviceViewController alloc]init];
    mydevice.view.backgroundColor = RandomColor;
    [contentM addObject:mydevice];
    
    OtherViewController *other = [[OtherViewController alloc]init];
    other.view.backgroundColor = RandomColor;
    [contentM addObject:other];
    
    [self.productContent configParam:contentM index:0 block:^(NSInteger index) {
        [self.fosaScrollview tabOffset:index];
    }];
}
- (void)addEvent{
    AddViewController *add = [[AddViewController alloc]init];
    add.hidesBottomBarWhenPushed = YES;
    
    ScanOneCodeViewController *scan = [[ScanOneCodeViewController alloc]init];
    scan.hidesBottomBarWhenPushed = YES;
    
    PhotoViewController *photo = [[PhotoViewController alloc]init];
    photo.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:photo animated:YES];
}


@end
