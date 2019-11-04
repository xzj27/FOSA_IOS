//
//  FosaViewController.m
//  fosa1.0
//
//  Created by hs on 2019/10/16.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FosaViewController.h"
#import "ScanViewController.h"
#import "PhotoViewController.h"
#import "FoodModel.h"
#import "FoodView.h"
#import "MenuModel.h"
#import "FosaMenu.h"
#import "FoodInfoViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <WebKit/WebKit.h>
#import <sqlite3.h>

@interface FosaViewController ()<WKNavigationDelegate,UIScrollViewDelegate>{
    int i;
}
//@property (strong,nonatomic) IBOutlet WKWebView *webview;

@property (nonatomic,strong) UIView *CategoryMenu;  //菜单视图

@property(nonatomic,assign)sqlite3 *database;
//结果集定义
@property(nonatomic,assign)sqlite3_stmt *stmt;

@property (nonatomic,assign) int count;

@property (nonatomic,assign) Boolean LeftOrRight;
@end

@implementation FosaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_scan"] style:UIBarButtonItemStylePlain target:self action:@selector(Scan)];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self InitView];
    [self creatOrOpensql];
    [self SelectDataFromSqlite];
}

-(void)InitView{
    _LeftOrRight = false;    //true mean that the view is folded
    _count = 0;
    self.mainWidth = [UIScreen mainScreen].bounds.size.width;
    self.mainHeight = [UIScreen mainScreen].bounds.size.height;
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    
    //底层滚动视图
    self.rootScrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, _navHeight, _mainWidth, _mainHeight)];
    self.rootScrollview.contentSize = CGSizeMake(_mainWidth, _mainHeight*1.5);
    self.rootScrollview.backgroundColor = [UIColor whiteColor];
    self.rootScrollview.bounces = NO;
    [self.view addSubview:self.rootScrollview];
    [self CreatMenu];
}
//创建菜单视图
-(void)CreatMenu{
    _CategoryMenu = [[UIView alloc]initWithFrame:CGRectMake(0, self.navHeight,self.mainWidth/3,self.mainHeight)];
    //_CategoryMenu.backgroundColor = [UIColor greenColor];
    //[self.rootScrollview addSubview:_CategoryMenu];
    [self.view insertSubview:_CategoryMenu atIndex:10];
    
    self.CategoryScrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0, self.CategoryMenu.frame.size.width,self.CategoryMenu.frame.size.height)];
    
    self.CategoryScrollview.backgroundColor = [UIColor whiteColor];
    self.CategoryScrollview.contentSize = CGSizeMake(self.CategoryMenu.frame.size.width,self.CategoryMenu.frame.size.height*1.5);
    self.CategoryScrollview.showsVerticalScrollIndicator = false;
    self.CategoryScrollview.showsHorizontalScrollIndicator = false;
    self.CategoryScrollview.bounces = NO;
    [self.CategoryMenu addSubview:self.CategoryScrollview];
    //添加滑动手势
    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRight:)];
     [swipeGestureRight setDirection:UISwipeGestureRecognizerDirectionRight];
     [_CategoryScrollview addGestureRecognizer:swipeGestureRight];
         
     UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureLeft:)];
     [swipeGestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
     [_CategoryScrollview addGestureRecognizer:swipeGestureLeft];
    
     NSArray *color = @[[UIColor redColor],[UIColor blueColor],[UIColor greenColor],[UIColor yellowColor],[UIColor orangeColor],[UIColor purpleColor]];
    NSArray *Item = @[@"谷物/面条",@"果汁",@"肉类",@"蔬菜",@"香料",@"咖啡/茶"];
    for (i = 0; i < 6; i++) {
        FosaMenu *food = [[FosaMenu alloc]initWithFrame:CGRectMake(0,i*self.CategoryMenu.frame.size.height/6, self.CategoryMenu.frame.size.width, self.CategoryMenu.frame.size.height/6)];
        MenuModel *model = [[MenuModel alloc]initWithName:Item[i]];
        food.model = model;
        food.backgroundColor = color[i];
        food.layer.borderWidth = 0.5;
        
        //[food addSubview:menuItem];
        
        [self.CategoryScrollview addSubview:food];
    }
    UIView *add = [[UIView alloc]initWithFrame:CGRectMake(0, self.CategoryMenu.frame.size.height, self.CategoryMenu.frame.size.width, self.CategoryMenu.frame.size.height/6)];
    add.layer.borderWidth = 1;
    add.backgroundColor = [UIColor grayColor];
    UIImageView *add_icon = [[UIImageView alloc]initWithFrame:CGRectMake(add.frame.size.width/6, add.frame.size.width/8, add.frame.size.width*2/3, add.frame.size.width*2/3)];
        add_icon.image = [UIImage imageNamed:@"ic_add_category"];
    [add addSubview:add_icon];
    [self.CategoryScrollview addSubview:add];
    
}

//滑动手势事件
-(void)swipeGestureRight:(UISwipeGestureRecognizer *)swipeGestureRecognizer{
    NSLog(@"向右滑动");
    if (_LeftOrRight) {//view 折叠
        _LeftOrRight = false;
        //view 向左移动
       _CategoryMenu.center = CGPointMake(self.CategoryMenu.frame.size.width/2, (self.CategoryMenu.frame.size.height)/2+self.navHeight);
    }
}
-(void)swipeGestureLeft:(UISwipeGestureRecognizer *)swipeGestureRecognizer{
    NSLog(@"向左滑动");
    if (!_LeftOrRight) {//view 展开
        _LeftOrRight = true;
        //向右移动
         _CategoryMenu.center = CGPointMake(-self.mainWidth/12,(self.CategoryMenu.frame.size.height)/2+self.navHeight);
    }
}
//跳转到扫码界面
-(void)Scan{
    ScanViewController *fosa_scan = [[ScanViewController alloc]init];
    fosa_scan.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:fosa_scan animated:YES];
}
//创建或打开数据库
-(void)creatOrOpensql
{
    NSString *path = [self getPath];
    int sqlStatus = sqlite3_open_v2([path UTF8String], &_database,SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE,NULL);
    if (sqlStatus == SQLITE_OK) {
        NSLog(@"数据库打开成功");
    }else{
        int close = sqlite3_close_v2(_database);
        if (close == SQLITE_OK) {
            _database = nil;
        }else{
            NSLog(@"数据库关闭异常");
        }
    }
}
-(void) SelectDataFromSqlite{
    //查询数据库添加的食物
    NSString *sql = [NSString stringWithFormat:@"select foodName,deviceName,aboutFood,expireDate,remindDate,photoPath from Fosa2"];
    const char *selsql = (char *)[sql UTF8String];
    int selresult = sqlite3_prepare_v2(self.database, selsql, -1, &_stmt, NULL);
    if(selresult != SQLITE_OK){
        NSLog(@"查询失败");
    }else{
        while (sqlite3_step(_stmt) == SQLITE_ROW) {
            const char *food_name = (const char *)sqlite3_column_text(_stmt, 0);
            const char *device_name = (const char*)sqlite3_column_text(_stmt,1);
            const char *expired_date = (const char *)sqlite3_column_text(_stmt,3);
            const char *photo_path = (const char *)sqlite3_column_text(_stmt,5);
            
            NSLog(@"查询到数据%@",[NSString stringWithUTF8String:food_name]);
            NSLog(@"查询到数据%@",[NSString stringWithUTF8String:expired_date]);
            NSLog(@"查询到数据%@",[NSString stringWithUTF8String:photo_path]);
            NSLog(@"********************************");
            
            [self CreatFoodViewWithName:[NSString stringWithUTF8String:food_name] fdevice:[NSString stringWithUTF8String:device_name] expireDate:[NSString stringWithUTF8String:expired_date] foodPhoto:[NSString stringWithUTF8String:photo_path]] ;
        }
    }
}
//获取DB数据库所在的document路径
-(NSString *)getPath
{
    NSString *filename = @"Fosa.db";
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [doc stringByAppendingPathComponent:filename];
    NSLog(@"%@",filePath);
    return filePath;

}
-(void)CreatFoodViewWithName:(NSString *)foodname fdevice:(NSString *)device expireDate:(NSString *)expireDate foodPhoto:(NSString *)photo{
    FoodView *food = [[FoodView alloc]initWithFrame:CGRectMake((_count%2)*((self.mainWidth*11/12-15)/2+5)+self.mainWidth/12+5, (_count/2)*(self.mainWidth/4)+15,(self.mainWidth*11/12-15)/2, self.mainWidth/4-5)];
    food.backgroundColor = [UIColor orangeColor];
    food.layer.cornerRadius = 10;
    FoodModel *model = [[FoodModel alloc]initWithName:foodname foodIcon:photo expire_date:expireDate fdevice:device];
    food.model = model;
    [food setModel:model];
    
    food.userInteractionEnabled = YES;
    UITapGestureRecognizer *foodRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ClickNotification:)];
    foodRecognizer.accessibilityValue = device;
    [food addGestureRecognizer:foodRecognizer];
    [self.rootScrollview addSubview:food];
    _count++;
}
//点击通知项的方法
-(void)ClickNotification:(UIGestureRecognizer *)recognizer{
    NSLog(@"*******");
    NSLog(@"%@",recognizer.accessibilityValue);
    FoodInfoViewController *info = [[FoodInfoViewController alloc]init];
    info.hidesBottomBarWhenPushed = YES;
    info.deviceID = recognizer.accessibilityValue;
    [self.navigationController pushViewController:info animated:YES];
    
}
//点击种类选项
-(void)ClickCategory:(UIGestureRecognizer *)recognizer{
    NSLog(@"%@",recognizer.accessibilityValue);
}

- (void)viewWillDisappear:(BOOL)animated{
    int close = sqlite3_close_v2(_database);
    if (close == SQLITE_OK) {
            _database = nil;
    }else{
            NSLog(@"数据库关闭异常");
    }
    //移除所有view
    [self.rootScrollview removeFromSuperview];
}
/*
//#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
