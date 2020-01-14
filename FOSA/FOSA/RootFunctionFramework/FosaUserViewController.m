//
//  FosaUserViewController.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FosaUserViewController.h"
#import "LoginViewController.h"
#import "AppsViewController.h"
#import "UserItem.h"


@interface FosaUserViewController ()<PassValueDelegate>
@end
@implementation FosaUserViewController
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
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0];
    [self InitDataAndView];
    
}
-(void)InitDataAndView{
    self.mainWidth = [UIScreen mainScreen].bounds.size.width;
    self.mainHeigh = [UIScreen mainScreen].bounds.size.height;
    self.navHeigh  = self.navigationController.navigationBar.frame.size.height;
    self.isFosaOpen= false;
    self.isAppsOpen= false;

    //底层视图
    self.rootview = [[UIView alloc]initWithFrame:CGRectMake(0, 0,self.mainWidth,self.mainHeigh-TabbarHeight)];
    [self.view addSubview:_rootview];
    //[[[UIApplication sharedApplication] keyWindow]addSubview:_rootScrollview];
    //顶部视图
    self.headerView = [[UIView alloc]initWithFrame:CGRectMake(0,0,self.mainWidth,self.mainHeigh/5)];
    _headerView.backgroundColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0];
    [self.rootview addSubview:_headerView];
    
    self.userIcon = [[UIImageView alloc]initWithFrame:CGRectMake(20,_headerView.frame.size.height/4, _headerView.frame.size.height/2, _headerView.frame.size.height/2)];
    [_userIcon setImage:[UIImage imageNamed:@"img_user"]];
    self.userIcon.layer.cornerRadius = self.userIcon.frame.size.height/2;
    self.userIcon.layer.masksToBounds = YES;
    [self.headerView addSubview: _userIcon];
    
    self.username = [[UILabel alloc]initWithFrame:CGRectMake(30+self.userIcon.frame.size.height,_headerView.frame.size.height/4,self.mainWidth/3,self.headerView.frame.size.height/3)];
    self.username.text = @"登录/注册";
    self.username.userInteractionEnabled = YES;
    self.username.layer.borderWidth = 1;
    self.username.layer.cornerRadius = 5;
    self.username.textAlignment = NSTextAlignmentCenter;
    self.username.font = [UIFont systemFontOfSize:15*(screen_width/414.0)];
    self.username.textColor = [UIColor whiteColor];
    [self.headerView addSubview:self.username];
    //添加点击响应
    UITapGestureRecognizer *jumpTologinRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpToLogin:)];
    [self.username addGestureRecognizer:jumpTologinRecognizer];
    
    self.itemView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, self.mainHeigh/5, self.mainWidth, self.mainHeigh*4/5)];
    self.itemView.backgroundColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0];
    _itemView.showsVerticalScrollIndicator = NO;
    _itemView.showsHorizontalScrollIndicator = NO;
    [self.rootview addSubview:_itemView];
    
    //tutorial
    CGFloat itemViewHeight = self.itemView.frame.size.height;
    self.Tutorial = [[UserItem alloc]initWithFrame:CGRectMake(0, 0, self.mainWidth,itemViewHeight/8-1)];
    _Tutorial.itemLabel.text = @"Tutorial";
    _Tutorial.backgroundColor = [UIColor whiteColor];
    _Tutorial.itemImgView.image = [UIImage imageNamed:@"icon_tutorial"];
    [self.itemView addSubview:self.Tutorial];
    
    //Location
    self.Location = [[UserItem alloc]initWithFrame:CGRectMake(0, itemViewHeight/8, _mainWidth, itemViewHeight/8-1)];
    _Location.itemLabel.text = @"Language/Location";
    _Location.backgroundColor = [UIColor whiteColor];
    _Location.itemImgView.image = [UIImage imageNamed:@"icon_locationHL"];
    [self.itemView addSubview:_Location];
    
    //setting
    self.Setting = [[UserItem alloc]initWithFrame:CGRectMake(0, itemViewHeight/4, _mainWidth, itemViewHeight/8-1)];
    _Setting.itemLabel.text = @"Setting";
    _Setting.backgroundColor = [UIColor whiteColor];
    _Setting.itemImgView.image = [UIImage imageNamed:@"icon_settingHL"];
    [self.itemView addSubview:_Setting];
    
    //Notification
    self.Notification = [[UserItem alloc]initWithFrame:CGRectMake(0, itemViewHeight*3/8, _mainWidth, itemViewHeight/8-1)];
       _Notification.itemLabel.text = @"Notification";
       _Notification.backgroundColor = [UIColor whiteColor];
       _Notification.itemImgView.image = [UIImage imageNamed:@"icon_notificationHL"];
       [self.itemView addSubview:_Notification];
    
    //HelpCenter
    self.HelpCenter = [[UserItem alloc]initWithFrame:CGRectMake(0, itemViewHeight/2, _mainWidth, itemViewHeight/8-1)];
    _HelpCenter.itemLabel.text = @"Help Center";
    _HelpCenter.backgroundColor = [UIColor whiteColor];
    _HelpCenter.itemImgView.image = [UIImage imageNamed:@"icon_helpcenterHL"];
    [self.itemView addSubview:_HelpCenter];
    
    //about FOSA
    self.FosaContent = [[UserItem alloc]initWithFrame:CGRectMake(0, itemViewHeight*5/8, _mainWidth, itemViewHeight/8-1)];
    _FosaContent.itemLabel.text = @"About FOSA";
    _FosaContent.backgroundColor = [UIColor whiteColor];
    _FosaContent.itemImgView.image = [UIImage imageNamed:@"icon_logoHL"];
    [self.itemView addSubview:_FosaContent];
    
    //about app
    self.AppsContent = [[UserItem alloc]initWithFrame:CGRectMake(0, itemViewHeight*3/4, _mainWidth, itemViewHeight/8-1)];
    _AppsContent.itemLabel.text = @"About Apps";
    _AppsContent.backgroundColor = [UIColor whiteColor];
    _AppsContent.itemImgView.image = [UIImage imageNamed:@"icon_appHL"];
    [self.itemView addSubview:_AppsContent];
    UITapGestureRecognizer *appsRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(JumpToApps)];
    [self.AppsContent addGestureRecognizer:appsRecognizer];
    self.AppsContent.userInteractionEnabled = YES;
    
    _itemView.contentSize = CGSizeMake(screen_width, 1.5*_itemView.frame.size.height);
}
- (void)JumpToApps{
    AppsViewController *app = [[AppsViewController alloc]init];
    app.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:app animated:YES];
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

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.backgroundColor = [UIColor clearColor];
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
