//
//  UserViewController.m
//  fosa1.0
//
//  Created by hs on 2019/10/16.
//  Copyright © 2019 hs. All rights reserved.
//

#import "UserViewController.h"
#import "LoginViewController.h"

@interface UserViewController ()<PassValueDelegate>
@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self InitDataAndView];
}

-(void)InitDataAndView{
    self.mainWidth = [UIScreen mainScreen].bounds.size.width;
    self.mainHeigh = [UIScreen mainScreen].bounds.size.height;
    self.navHeigh  = self.navigationController.navigationBar.frame.size.height;
    self.isFosaOpen= false;
    self.isAppsOpen= false;
    
    //底层视图
    self.rootScrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.navHeigh,self.mainWidth,self.mainHeigh)];
    _rootScrollview.contentSize = CGSizeMake(self.view.frame.size.width,self.mainHeigh*1.5);
    [self.view addSubview:_rootScrollview];
    
    //顶部视图
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.mainWidth,self.mainHeigh/4)];
    _headerView.backgroundColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0];
    [self.rootScrollview addSubview:_headerView];
    
    self.userIcon = [[UIImageView alloc]initWithFrame:CGRectMake(20,_headerView.frame.size.height/4, _headerView.frame.size.height/2, _headerView.frame.size.height/2)];
    [_userIcon setImage:[UIImage imageNamed:@"启动图2"]];
    self.userIcon.layer.cornerRadius = self.userIcon.frame.size.height/2;
    self.userIcon.layer.masksToBounds = YES;
    [self.headerView addSubview: _userIcon];
    
    self.username = [[UILabel alloc]initWithFrame:CGRectMake(30+self.userIcon.frame.size.height,_headerView.frame.size.height/4,self.mainWidth/3,self.headerView.frame.size.height/3)];
    self.username.text = @"登录/注册";
    self.username.userInteractionEnabled = YES;
    self.username.layer.borderWidth = 1;
    self.username.layer.cornerRadius = 5;
    self.username.textAlignment = NSTextAlignmentCenter;
    self.username.font = [UIFont systemFontOfSize:15];
    self.username.textColor = [UIColor whiteColor];
    [self.headerView addSubview:self.username];
    //添加点击响应
    UITapGestureRecognizer *jumpTologinRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpToLogin:)];
    [self.username addGestureRecognizer:jumpTologinRecognizer];
    
    // about fosa
    self.FosaContent = [[UIView alloc]initWithFrame:CGRectMake(0,self.headerView.frame.size.height+20, self.mainWidth,40)];
    _FosaContent.backgroundColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0];
    self.aboutFosa = [[UITextField alloc]initWithFrame:CGRectMake(0,self.headerView.frame.size.height+60, self.mainWidth, 100)];
    _aboutFosa.text = @"Fosa是一种食品真空保鲜盒";
    _aboutFosa.layer.borderWidth = 1;
    _aboutFosa.userInteractionEnabled = NO;
    _aboutFosa.backgroundColor = [UIColor whiteColor];
    [self.rootScrollview addSubview:_FosaContent];
    
    self.FosaContentTitle = [[UILabel alloc]initWithFrame:CGRectMake(0,self.FosaContent.frame.size.height/4, self.mainWidth/3,self.FosaContent.frame.size.height/2)];
    self.FosaContentTitle.text = @"About Fosa";
    self.FosaContentTitle.textColor = [UIColor blackColor];
    self.FosaContentTitle.textAlignment = NSTextAlignmentCenter;
    [self.FosaContent addSubview:_FosaContentTitle];
    
    self.showContent = [[UIImageView alloc]initWithFrame:CGRectMake(self.FosaContent.frame.size.width-30 ,self.FosaContent.frame.size.height/5, 30,30)];
    _showContent.image = [UIImage imageNamed:@"icon_close"];
    [self.FosaContent addSubview:_showContent];
    
    
    UITapGestureRecognizer *tapgestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapAction1:)];
    [self.FosaContent addGestureRecognizer:tapgestureRecognizer];
    
    self.AppsContent = [[UIView alloc]initWithFrame:CGRectMake(0,self.headerView.frame.size.height+80, self.mainWidth, 40)];
    _AppsContent.backgroundColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0];
    [self.rootScrollview addSubview:_AppsContent];
    
    //内容标题
    self.AppsContentTitle = [[UILabel alloc]initWithFrame:CGRectMake(0,self.AppsContent.frame.size.height/4, self.mainWidth/3,self.AppsContent.frame.size.height/2)];
    self.AppsContentTitle.text = @"About Apps";
    self.AppsContentTitle.textColor = [UIColor blackColor];
    self.AppsContentTitle.textAlignment = NSTextAlignmentCenter;
    [self.AppsContent addSubview:self.AppsContentTitle];
    
    self.showApps = [[UIImageView alloc]initWithFrame:CGRectMake(self.AppsContent.frame.size.width-30 ,self.AppsContent.frame.size.height/5, 30,30)];
    
    _showApps.image = [UIImage imageNamed:@"icon_close"];
    [self.AppsContent addSubview:self.showApps];
    //关于App的描述
    self.aboutApps = [[UITextField alloc]initWithFrame:CGRectMake(0,self.headerView.frame.size.height+120, self.mainWidth,100)];
    _aboutApps.text = @"这款应用是FOSA产品的配套应用，功能很齐全!";
    _aboutApps.userInteractionEnabled = NO;
    _aboutApps.layer.borderWidth = 1;
    _aboutApps.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    
    //给view添加点击响应
    self.AppsContent.userInteractionEnabled = YES;
    //添加点击事件
    UITapGestureRecognizer *tapgestureRecognizer1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapAction:)];
    [self.AppsContent addGestureRecognizer:tapgestureRecognizer1];
    
}

-(void)TapAction1:(id)sender{
  
        if(!self.isFosaOpen){
            [self.rootScrollview addSubview:self.aboutFosa];
            self.showContent.image = [UIImage imageNamed:@"icon_open"];
            self.isFosaOpen = true;
        }else{
            [self.aboutFosa removeFromSuperview];
            self.showContent.image = [UIImage imageNamed:@"icon_close"];
            self.isFosaOpen = false;
        }
}
-(void)TapAction:(id)sender{
    if(!self.isAppsOpen){
        [self.rootScrollview addSubview:self.aboutApps];
        self.showApps.image = [UIImage imageNamed:@"icon_open"];
        self.isAppsOpen = true;
    }else{
        [self.aboutApps removeFromSuperview];
        self.showApps.image = [UIImage imageNamed:@"icon_close"]; 
        self.isAppsOpen = false;
    }
}
-(void)jumpToLogin:(id)sender{
    NSLog(@"跳转");
    LoginViewController *login = [[LoginViewController alloc]init];
    login.hidesBottomBarWhenPushed = YES;
    login.delegate = self;
    login.content = self.username.text;
    [self presentViewController:login animated:YES completion:nil];
}
-(void)passValue:(NSString *)content{
    self.username.text = content;
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
