//
//  MyDeviceViewController.m
//  FOSA
//
//  Created by hs on 2019/11/15.
//  Copyright © 2019 hs. All rights reserved.
//

#import "MyDeviceViewController.h"

@interface MyDeviceViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray *arrayData;
}

@end

@implementation MyDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)InitDeviceView{
    self.mainWidth = [UIScreen mainScreen].bounds.size.width;
    self.mainHeight = [UIScreen mainScreen].bounds.size.height;
    self.navheight = self.navigationController.navigationBar.frame.size.height;
    //device menu
    self.deviceTable = [[UITableView alloc]initWithFrame:CGRectMake(0,_navheight+5, _mainWidth/5, _mainHeight-_navheight-5) style:UITableViewStylePlain];
    self.deviceTable.delegate = self;
    self.deviceTable.dataSource = self;
    self.deviceTable.showsVerticalScrollIndicator = NO;
    [self.deviceTable setSeparatorColor:[UIColor grayColor]];
    [self.view addSubview:self.deviceTable];

    //content
    self.contentView = [[UIView alloc]initWithFrame:CGRectMake(self.mainWidth/5,5, self.mainWidth*4/5, self.mainHeight-_navheight-5)];
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
