//
//  FosaPoundViewController.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FosaPoundViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "ScanOneCodeViewController.h"
//图片宽高的最大值
#define KCompressibilityFactor 1280.00
@interface FosaPoundViewController ()<UNUserNotificationCenterDelegate>
@property (nonatomic,strong) UIButton *send;
@end

@implementation FosaPoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.mainHeight = [UIScreen mainScreen].bounds.size.width;
    self.mainWidth = [UIScreen mainScreen].bounds.size.height;
    self.navheight = self.navigationController.navigationBar.frame.size.height;
    
    
    
    //分割线
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.mainHeight, self.mainWidth, 2)];
    
    line.backgroundColor = [UIColor grayColor];
    
    [self.view addSubview:line];
}


@end
