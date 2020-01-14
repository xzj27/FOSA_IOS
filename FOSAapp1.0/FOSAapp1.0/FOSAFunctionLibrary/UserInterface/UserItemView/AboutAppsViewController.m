//
//  AboutAppsViewController.m
//  FOSAapp1.0
//
//  Created by hs on 2020/1/13.
//  Copyright © 2020 hs. All rights reserved.
//

#import "AboutAppsViewController.h"

@interface AboutAppsViewController ()

@end

@implementation AboutAppsViewController

#pragma mark - 懒加载
- (UIImageView *)logo{
    if (_logo == nil) {
        _logo = [[UIImageView alloc]init];
    }
    return _logo;
}
- (UILabel *)versionLable{
    if (_versionLable == nil) {
        _versionLable = [[UILabel alloc]init];
    }
    return _versionLable;
}
- (UILabel *)versionTitleLable{
    if (_versionTitleLable == nil) {
        _versionTitleLable = [[UILabel alloc]init];
    }
    return _versionTitleLable;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self CreatView];
}

- (void)CreatView{
    self.view.backgroundColor = [UIColor whiteColor];
    self.logo.frame = CGRectMake(screen_width*2/5, screen_height/6, screen_width/5, screen_width/5);
    self.logo.image = [UIImage imageNamed:@"icon_logoHL"];
    [self.view addSubview:self.logo];
    
    self.versionTitleLable.frame = CGRectMake(screen_width/3, screen_height/6+screen_width/5, screen_width/3, 40);
    self.versionTitleLable.text = @"Version";
    self.versionTitleLable.font = [UIFont systemFontOfSize:25*(screen_width/414)];
    self.versionTitleLable.backgroundColor = [UIColor whiteColor];
    self.versionTitleLable.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.versionTitleLable];
    
    self.versionLable.frame = CGRectMake(screen_width/3, screen_height/6+screen_width/5+40, screen_width/3, 40);
    self.versionLable.text  = @"Version 1.0.0";
    self.versionLable.font  = [UIFont systemFontOfSize:20*(screen_width/414)];
    self.versionLable.backgroundColor = [UIColor whiteColor];
    self.versionLable.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.versionLable];
}

@end
