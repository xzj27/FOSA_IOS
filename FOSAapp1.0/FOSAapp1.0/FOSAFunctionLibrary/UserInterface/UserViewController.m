//
//  UserViewController.m
//  FOSAapp1.0
//
//  Created by hs on 2019/12/30.
//  Copyright © 2019 hs. All rights reserved.
//

#import "UserViewController.h"
#import "AboutAppsViewController.h"

@interface UserViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray *ItemLogoArray,*ItemArray;
}
@property(nonatomic,strong) NSUserDefaults *userDefaults;
@end

@implementation UserViewController

#pragma mark - 懒加载属性
- (UIView *)header{
    if (_header == nil) {
        //_header = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screen_width, screen_height/4)];
        _header = [[UIView alloc]init];
    }
    return _header;
}
- (UIImageView *)headerBackgroundImgView{
    if (_headerBackgroundImgView == nil) {
        _headerBackgroundImgView = [[UIImageView alloc]init];
    }
    return _headerBackgroundImgView;
}
- (UIImageView *)userIcon{
    if (_userIcon == nil) {
        //_userIcon = [[UIImageView alloc]initWithFrame:CGRectMake(20, self.header.frame.size.height/4, self.header.frame.size.height/2, self.header.frame.size.height/2)];
        _userIcon = [[UIImageView alloc]init];
    }
    return _userIcon;
}
- (UILabel *)userName{
    if (_userName == nil) {
        //_userName = [[UILabel alloc]initWithFrame:CGRectMake(self.header.frame.size.height/2+30, self.header.frame.size.height/3, self.header.frame.size.width/3, self.header.frame.size.height/3)];
        _userName = [[UILabel alloc]init];
    }
    return _userName;
}
- (UITableView *)userItemTable{
    if (_userItemTable == nil) {
        _userItemTable = [[UITableView alloc]initWithFrame:CGRectMake(0, screen_height*15/48, screen_width, screen_height/2) style:UITableViewStylePlain];
        //_userItemTable = [[UITableView alloc]init];
    }
    return _userItemTable;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(200, 200, 100, 100)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(JUMP) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:btn];
    
    [self CreatHeader];
    [self SetCurrentUser];
    [self CreatUserItemTable];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self InitData];
}

- (void)InitData{
    ItemArray = @[@"Tutorial",@"Language/Location",@"Setting",@"Notification",@"Help Center",@"About FOSA",@"About Apps"];
    ItemLogoArray = @[@"icon_tutorial",@"icon_locationHL",@"icon_settingHL",@"icon_notificationHL",@"icon_helpcenterHL",@"icon_logo",@"icon_appHL"];
}

- (void)CreatHeader{
    self.userDefaults = [NSUserDefaults standardUserDefaults];// 初始化
    int headerWidth = screen_width;
    int headerHeight = screen_height/3;
    
    self.header.frame = CGRectMake(0, 0, headerWidth, headerHeight);
    [self.view addSubview:self.header];
    self.header.backgroundColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0];
    self.headerBackgroundImgView.frame = self.header.frame;
    self.headerBackgroundImgView.image = [UIImage imageNamed:@"img_UserBackground"];
    self.headerBackgroundImgView.contentMode = UIViewContentModeScaleAspectFill;
    self.headerBackgroundImgView.clipsToBounds = YES;
    [self.header addSubview:self.headerBackgroundImgView];
    
    self.userIcon.frame = CGRectMake(20, headerHeight/4, headerWidth/4, headerWidth/4);
    self.userIcon.image = [UIImage imageNamed:@"icon_User"];
    [self.header addSubview:self.userIcon];
    
    self.userName.frame = CGRectMake(headerWidth/4+30, headerHeight/4, headerWidth/2, headerWidth/6);
    self.userName.userInteractionEnabled = YES;
    //self.userName.layer.borderWidth = 0.5;
    self.userName.layer.cornerRadius = 5;
    //self.userName.textAlignment = NSTextAlignmentCenter;
    self.userName.font = [UIFont systemFontOfSize:20*(screen_width/414.0)];
    self.userName.textColor = [UIColor whiteColor];
    UITapGestureRecognizer *login = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(JUMP)];
    [self.userName addGestureRecognizer:login];
    [self.header addSubview:self.userName];
}

- (void)CreatUserItemTable{
    [self.view addSubview:self.userItemTable];
    
    self.userItemTable.delegate = self;
    self.userItemTable.dataSource = self;
    self.userItemTable.bounces = NO;
    self.userItemTable.layer.cornerRadius = 15;
    self.userItemTable.showsVerticalScrollIndicator = NO;
    self.userItemTable.backgroundColor = [UIColor whiteColor];
}

//取出用户名和密码
- (void)SetCurrentUser{
    NSLog(@"确认当前登录用户");
    NSString *currentUser= [self.userDefaults valueForKey:@"currentUser"];
    if (currentUser != NULL) {
        self.userName.text = currentUser;
    }else{
        self.userName.text = @"Login/Sign Up";
    }
}
#pragma mark - UItableViewDelegate

//行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return self.userItemTable.frame.size.height/(ItemArray.count);
}
//每组的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"%lu",ItemArray.count);
    return ItemArray.count;
}
//组数
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    //初始化cell，并指定其类型
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        //创建cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
     NSInteger row = indexPath.row;
    //取消点击cell时显示的背景色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:20*(([UIScreen mainScreen].bounds.size.width/414.0))];
    cell.imageView.image = [UIImage imageNamed:ItemLogoArray[row]];
    cell.textLabel.text = ItemArray[row];
    //返回cell
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index = indexPath.row;
    AboutAppsViewController *about = [[AboutAppsViewController alloc]init];
    switch (index) {
        case 6:
            about.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:about animated:YES];
            break;
            
        default:
            break;
    }
}
- (void)JUMP{
    LoginViewController *login = [[LoginViewController alloc]init];
    login.hidesBottomBarWhenPushed = YES;
    RegisterViewController *regist = [[RegisterViewController alloc]init];
    regist.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:login animated:YES];
}

/**隐藏底部横条，点击屏幕可显示*/
- (BOOL)prefersHomeIndicatorAutoHidden{
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = NO;
}

@end
