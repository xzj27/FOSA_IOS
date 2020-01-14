//
//  FosaMainViewController.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FosaMainViewController.h"
#import "ScanOneCodeViewController.h"
#import "PhotoViewController.h"
#import "FoodCollectionViewCell.h"
#import "PhotoViewController.h"
#import "MainPhotoViewController.h"
#import "MenuModel.h"
#import "FosaMenu.h"
#import "FoodInfoViewController.h"
#import "CellModel.h"
#import "FoodModel.h"
#import "FosaNotification.h"

#import <UserNotifications/UserNotifications.h>
#import "LoadCircleView.h"
#import "SqliteManager.h"

#import "WaterFlowLayout.h"
@interface FosaMainViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate,WaterFlowLayoutDelegate>{
    int i;
    NSString *ID;
    Boolean isEdit;
    CGFloat cellHeight;
    //刷新标志
    Boolean isUpdate;
    //排序方式
    NSInteger sort;
}
@property (nonatomic,strong) UIView *CategoryMenu;  //菜单视图
@property(nonatomic,assign) sqlite3 *database;
//结果集定义
@property(nonatomic,assign) sqlite3_stmt *stmt;
@property (nonatomic,assign) int count;
@property (nonatomic,assign) Boolean LeftOrRight;
@property (nonatomic,strong) NSMutableArray<CellModel *> *storageArray;

@property (nonatomic, strong) NSMutableDictionary *cellDic;

@property (nonatomic,strong) NSMutableArray<FoodModel *> *foodArray;
@property (nonatomic,strong) UIRefreshControl *refresh;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;//长按手势

@property (nonatomic,strong) LoadCircleView *circleview;
@property (nonatomic,strong) FosaNotification *notification;
@end

@implementation FosaMainViewController
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


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    //导航栏右侧扫码按钮
    self.QRscan = [[UIButton alloc]initWithFrame:CGRectMake(0,0,35,35)];
    [self.QRscan setImage:[UIImage imageNamed:@"icon_scan"] forState:UIControlStateNormal];
    self.QRscan.showsTouchWhenHighlighted = YES;
    [self.QRscan addTarget:self action:@selector(Scan) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.QRscan];
    self.navigationItem.rightBarButtonItem = rightItem;
    //导航栏左侧提醒按钮
    self.Remindbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 35, 35)];
    [self.Remindbtn setImage:[UIImage imageNamed:@"icon_remind"] forState:UIControlStateNormal];
    [self.Remindbtn addTarget:self action:@selector(SendRemindingNotification) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:self.Remindbtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    [self InitView];
}

- (void)viewWillAppear:(BOOL)animated{
    
    //self.navigationController.navigationBarHidden = YES;
    [super viewWillAppear:animated];
    self.database = [SqliteManager InitSqliteWithName:@"Fosa.db"];
    if (isUpdate == true) {
        NSLog(@"异步刷新界面");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.storageArray removeAllObjects];
            [self.cellDic removeAllObjects];
            [self.StorageItemView reloadData];
        });
    }
}
- (void)InitView{
    ID = @"FosaCell";
    isEdit = false;
    sort = 0;               //初始化默认为按提醒顺序排列
    _LeftOrRight = true;    //true mean that the view is folded
    _count = 0;
    isUpdate = false;
    self.storageArray = [[NSMutableArray alloc]init];
    self.cellDic = [[NSMutableDictionary alloc] init];
    
    self.mainWidth = [UIScreen mainScreen].bounds.size.width;
    self.mainHeight = [UIScreen mainScreen].bounds.size.height;
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    NSLog(@"======%f",self.navHeight);

    //排序按钮
    self.sortBtn = [[UIButton alloc]initWithFrame:CGRectMake(screen_width-NavigationHeight/2, NavigationHeight, NavigationHeight/2, NavigationHeight/2)];
    [_sortBtn setBackgroundImage:[UIImage imageNamed:@"icon_sort"] forState:UIControlStateNormal];
    [_sortBtn addTarget:self action:@selector(sortItem) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_sortBtn];
    
    //自定义瀑布流布局
    WaterFlowLayout *waterLayout = [[WaterFlowLayout alloc]init];
    waterLayout.delegate = self;
    
    self.StorageItemView = [[UICollectionView alloc]initWithFrame:CGRectMake(screen_width*1/12, NavigationHeight*1.5, screen_width*11/12, screen_height-TabbarHeight-NavigationHeight) collectionViewLayout:waterLayout];
    _StorageItemView.backgroundColor = [UIColor whiteColor];
    _StorageItemView.showsVerticalScrollIndicator = NO;
    //regist the user-defined collctioncell
    //[_StorageItemView registerClass:[FoodCollectionViewCell class] forCellWithReuseIdentifier:ID];
    
    //给view 添加滑动事件
     UISwipeGestureRecognizer *recognizer;
        //right--
        recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
        [[self view] addGestureRecognizer:recognizer];
        //[recognizer release];
        //left---
        recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
        [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
        [[self view] addGestureRecognizer:recognizer];
    //空白屏幕点击事件
//    UIGestureRecognizer *Crecognizer = [[UIGestureRecognizer alloc]initWithTarget:self action:@selector(moveMenu)];
//    [Crecognizer requireGestureRecognizerToFail:recognizer];
//    Crecognizer.delegate = self;
//    [[self StorageItemView] addGestureRecognizer:Crecognizer];
    if ([NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){10,0,0}])
    {
        //CGRect fresh = CGRectMake(0, 0, self.StorageItemView.frame.size.width,50);
    //创建刷新控件
    _refresh = [[UIRefreshControl alloc]init];
        //refresh.frame = fresh;
    //配置控件
    _refresh.tintColor = [UIColor grayColor];
    NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor redColor]};
    _refresh.attributedTitle = [[NSAttributedString alloc]initWithString:@"正在刷新界面" attributes:attributes];
    //添加事件
     [_refresh addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    _StorageItemView.refreshControl = _refresh;
    }
    _StorageItemView.delegate = self;
    _StorageItemView.dataSource = self;
    [self.view addSubview:_StorageItemView];
    
    //添加按钮
    self.addContentBtn = [[UIButton alloc]initWithFrame:CGRectMake(screen_width/2-30, screen_height-60-TabbarHeight, 60, 60)];
    [_addContentBtn setBackgroundImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    [self.view insertSubview:_addContentBtn atIndex:50];
    [_addContentBtn addTarget:self action:@selector(addFunction) forControlEvents:UIControlEventTouchUpInside];
    [self CreatMenu];
}
//创建菜单视图
- (void)CreatMenu{
    _CategoryMenu = [[UIView alloc]initWithFrame:CGRectMake(-self.mainWidth/4, self.navHeight,self.mainWidth/3,self.mainHeight)];

    [self.view insertSubview:_CategoryMenu atIndex:10];

    self.CategoryScrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0, self.CategoryMenu.frame.size.width,self.CategoryMenu.frame.size.height)];
    
    self.CategoryScrollview.backgroundColor = [UIColor whiteColor];
    self.CategoryScrollview.contentSize = CGSizeMake(self.CategoryMenu.frame.size.width,self.CategoryMenu.frame.size.height*1.5);
    self.CategoryScrollview.showsVerticalScrollIndicator = false;
    self.CategoryScrollview.showsHorizontalScrollIndicator = false;
    self.CategoryScrollview.bounces = NO;
    [self.CategoryMenu addSubview:self.CategoryScrollview];
    //添加滑动手势
//    UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRight:)];
//     [swipeGestureRight setDirection:UISwipeGestureRecognizerDirectionRight];
//     [_CategoryScrollview addGestureRecognizer:swipeGestureRight];
//
//     UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureLeft:)];
//     [swipeGestureLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
//     [_CategoryScrollview addGestureRecognizer:swipeGestureLeft];
    
    //颜色
     NSArray *color = @[
         [UIColor colorWithRed:233/255.0 green:62/255.0 blue:77/255.0 alpha:1],
         [UIColor colorWithRed:0/255.0 green:142/255.0 blue:215/255.0 alpha:1],
         [UIColor colorWithRed:89/255.0 green:233/255.0 blue:77/255.0 alpha:1],
         [UIColor colorWithRed:255/255.0 green:238/255.0 blue:120/255.0 alpha:1],
         [UIColor colorWithRed:255/255.0 green:179/255.0 blue:0/255.0 alpha:1],
         [UIColor colorWithRed:205/255.0 green:103/255.0 blue:255/255.0 alpha:1]];
    NSArray *Item = @[@"谷物/面条",@"果汁",@"肉类",@"蔬菜",@"香料",@"咖啡/茶"];
    for (i = 0; i < 6; i++) {
        FosaMenu *food = [[FosaMenu alloc]initWithFrame:CGRectMake(0,i*self.CategoryMenu.frame.size.height/6, self.CategoryMenu.frame.size.width, self.CategoryMenu.frame.size.height/6)];
        MenuModel *model = [[MenuModel alloc]initWithName:Item[i]];
        food.model = model;
        food.backgroundColor = color[i];
        food.layer.borderWidth = 0.5;
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

// 添加事件
- (void) addFunction{
   MainPhotoViewController *photo = [[MainPhotoViewController alloc]init];
    //PhotoViewController *photo = [[PhotoViewController alloc]init];
    photo.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:photo animated:YES];
}
//滑动手势事件
- (void)swipeGestureRight:(UISwipeGestureRecognizer *)swipeGestureRecognizer{
    NSLog(@"向右滑动");
    if (_LeftOrRight) {//view 折叠
        _LeftOrRight = false;
        //view 向左移动
       _CategoryMenu.center = CGPointMake(self.CategoryMenu.frame.size.width/2, (self.CategoryMenu.frame.size.height)/2+self.navHeight);
    }
}
- (void)swipeGestureLeft:(UISwipeGestureRecognizer *)swipeGestureRecognizer{
    NSLog(@"向左滑动");
    if (!_LeftOrRight) {//view 展开
        _LeftOrRight = true;
        //向右移动
         _CategoryMenu.center = CGPointMake(-self.mainWidth/12,(self.CategoryMenu.frame.size.height)/2+self.navHeight);
    }
}
#pragma mark - Notification
//发送通知提醒当天所有已过期的食品
- (void)SendRemindingNotification
{
    //注册通知
    [_notification initNotification];
    //标志
    Boolean isSend = false;
    //获取当前日期
    NSDate *currentDate = [[NSDate alloc]init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
    [formatter2 setDateFormat:@"yyyy/MM/dd/HH:mm"];
    
    NSString *str = [formatter stringFromDate:currentDate];
    currentDate = [formatter dateFromString:str];
    NSLog(@"%@",str);
    NSString *str2; // 用于转换
    
    //查询数据库所有食品并获得其foodname和expire date
    for (int i = 0; i < _storageArray.count; i++) {
NSLog(@"foodName=%@&&&&&&&expireDate=%@",_storageArray[i].foodName,_storageArray[i].remindDate);
        NSString *Rdate = _storageArray[i].remindDate;//格式为 yyyy/MM/dd
        NSDate *foodDate = [[NSDate alloc]init];
        NSLog(@"%@",Rdate);
        foodDate = [formatter2 dateFromString:Rdate];
        str2 = [formatter stringFromDate:foodDate];
        foodDate = [formatter dateFromString:str2];
        NSLog(@"%@-------%@",currentDate,foodDate);
        NSComparisonResult result = [currentDate compare:foodDate];
        
        if (result == NSOrderedDescending) { //foodDate 在 currentDate 之前
            isSend = true;
            NSString *body = [NSString stringWithFormat:@"FOSA 提醒你应该在%@ 食用 %@",_storageArray[i].remindDate,_storageArray[i].foodName];
            //发送通知
            [_notification sendNotification:_storageArray[i].foodName body:body path:[self getImage:_storageArray[i].foodName] deviceName:_storageArray[i].device];
        }else if (result == NSOrderedAscending){//foodDate 在 currentDate 之后
            NSLog(@"%@ 将在 %@ 过期了，请及时使用",_storageArray[i].foodName,_storageArray[i].remindDate);
        }else{
    NSLog(@"%@刚好在今天过期",_storageArray[i].foodName);
            NSString *body = [NSString stringWithFormat:@"今天要记得吃 %@",_storageArray[i].foodName];
            //发送通知
            [_notification sendNotification:_storageArray[i].foodName body:body path:[self getImage:_storageArray[i].foodName] deviceName:_storageArray[i].device];
        }
    }
    _circleview = [[LoadCircleView alloc]initWithFrame:CGRectMake(0  ,400,self.view.frame.size.width,100)];
    //添加到视图上展示
    [self.view addSubview:_circleview];
    [self performSelector:@selector(removeLoading) withObject:nil afterDelay:2.0f];
}
//取出保存在本地的图片
- (UIImage*)getImage:(NSString *)filepath{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photopath = [NSString stringWithFormat:@"%@.png",filepath];
    NSString *imagePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",photopath]];
    // 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    NSLog(@"===%@", img);
    return img;
}
- (void)removeLoading{
    [self.circleview removeFromSuperview];
}
#pragma mark - 跳转到扫码界面
- (void)Scan{
    
    ScanOneCodeViewController *fosa_scan = [[ScanOneCodeViewController alloc]init];
    fosa_scan.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:fosa_scan animated:YES];
}
#pragma mark - 排序
- (void)sortItem{
    UIAlertController *alert  = [UIAlertController alertControllerWithTitle:@"排序方式" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *photoLibary = [UIAlertAction actionWithTitle:@"按提醒日期先后排序" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"即将打开相册");
        [self sortItemByRemindDate];
    }];
    UIAlertAction *Camera = [UIAlertAction actionWithTitle:@"按过期日期先后排序" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"打开相机");
        [self sortItemByExpireDate];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }];

    [alert addAction:photoLibary];
    [alert addAction:Camera];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)sortItemByRemindDate{
    sort = 1;   //按提醒日期排序
    [self.storageArray removeAllObjects];
    [self.cellDic removeAllObjects];
    [self.StorageItemView reloadData];
}

- (void)sortItemByExpireDate{
    sort = 2;   //按提醒日期排序
    [self.storageArray removeAllObjects];
    [self.cellDic removeAllObjects];
    [self.StorageItemView reloadData];
}

#pragma mark - 数据库操作
- (void)creatOrOpensql
{
    self.database = [SqliteManager InitSqliteWithName:@"Fosa.db"];
}
- (void) SelectDataFromSqlite{
    NSString *sql;
    switch (sort) {
        case 0: //初始化按照提醒日期顺序排列
            sql = [NSString stringWithFormat:@"select foodName,deviceName,aboutFood,expireDate,remindDate,photoPath from Fosa2 order by remindDate"];
            break;
        case 1: //按照提醒日期逆序排序
            sql = [NSString stringWithFormat:@"select foodName,deviceName,aboutFood,expireDate,remindDate,photoPath from Fosa2 order by remindDate desc"];
            break;
        case 2: //按过期日期顺序排序
            sql = [NSString stringWithFormat:@"select foodName,deviceName,aboutFood,expireDate,remindDate,photoPath from Fosa2 order by expireDate"];
            break;
        case 3: //按过期日期逆序排序
        sql = [NSString stringWithFormat:@"select foodName,deviceName,aboutFood,expireDate,remindDate,photoPath from Fosa2 order by expireDate desc"];
        break;
        default:
            break;
    }
    //查询数据库添加的食物
    self.stmt = [SqliteManager SelectDataFromTable:sql database:self.database];
    if (self.stmt != NULL) {
        while (sqlite3_step(_stmt) == SQLITE_ROW) {
                const char *food_name = (const char *)sqlite3_column_text(_stmt, 0);
                const char *device_name = (const char*)sqlite3_column_text(_stmt,1);
                const char *remind_date = (const char*)sqlite3_column_text(_stmt,4);
                const char *expired_date = (const char *)sqlite3_column_text(_stmt,3);
                const char *photo_path = (const char *)sqlite3_column_text(_stmt,5);
//                NSLog(@"查询到数据%@",[NSString stringWithUTF8String:food_name]);
//                NSLog(@"查询到数据%@",[NSString stringWithUTF8String:expired_date]);
//                NSLog(@"查询到数据%@",[NSString stringWithUTF8String:photo_path]);
//                NSLog(@"********************************");
            
        [self CreatFoodViewWithName:[NSString stringWithUTF8String:food_name] fdevice:[NSString stringWithUTF8String:device_name] remindDate:[NSString stringWithUTF8String:remind_date] foodPhoto:[NSString stringWithUTF8String:photo_path]];
            }
    }else{
        NSLog(@"查询失败");
    }
}
#pragma mark - cell相关的方法
- (void)CreatFoodViewWithName:(NSString *)foodname fdevice:(NSString *)device remindDate:(NSString *)remindDate foodPhoto:(NSString *)photo{
    //创建食物模型
    CellModel *model = [[CellModel alloc]initWithName:foodname foodIcon:photo remind_date:remindDate fdevice:device];
    [self.storageArray addObject:model];
}
//点击通知项的方法
- (void)ClickNotification:(FoodCollectionViewCell *)cell{
    FoodInfoViewController *info = [[FoodInfoViewController alloc]init];
    info.hidesBottomBarWhenPushed = YES;
    info.deviceID = cell.model.device;
    info.name = cell.model.foodName;
    [self.navigationController pushViewController:info animated:YES];
}
//点击种类选项
- (void)ClickCategory:(UIGestureRecognizer *)recognizer{
    NSLog(@"%@",recognizer.accessibilityValue);
}
#pragma mark - UICollectionViewCell 长按事件
- (void)lonePressMoving:(UILongPressGestureRecognizer *)longPress
{
    NSLog(@"长按了item");
    isEdit = true;
    //CGPoint touchPoint = [longPress locationInView:self.StorageItemView];//获取长按的点
    if (longPress.state == UIGestureRecognizerStateBegan) {
            FoodCollectionViewCell *cell = (FoodCollectionViewCell *)longPress.view;
            NSLog(@"%@",cell.model.foodName);
            [cell becomeFirstResponder];
            UIMenuItem *item1 = [[UIMenuItem alloc]initWithTitle:@"删除"action:@selector(DeleteCell:)];
            UIMenuItem *item2 = [[UIMenuItem alloc]initWithTitle:@"取消"action:@selector(CancelEdit:)];
             UIMenuController *menu = [UIMenuController sharedMenuController];
            [menu setMenuItems:@[item1,item2]];
        
        if (@available(iOS 13,*)) {
            menu.accessibilityValue = cell.model.foodName;
            [menu showMenuFromView:self.StorageItemView rect:cell.frame];
        }else{
            [menu setTargetRect:cell.frame inView:self.StorageItemView];
            menu.accessibilityValue = cell.model.foodName;
            [menu setMenuVisible:YES animated:YES];
        }
    }
}
//屏幕滑动手势
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"swipe left");
        //执行程序
        [self moveMenu];
    }
    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {

        NSLog(@"swipe right");
        //执行程序
        [self moveMenu];
    }
}
- (void) moveMenu
{
    if (_LeftOrRight) {//view 折叠
       _LeftOrRight = false;
        [UIView animateWithDuration:0.2 animations:^{
            //view 向左移动动画
            self->_CategoryMenu.center = CGPointMake(self.CategoryMenu.frame.size.width/2, (self.CategoryMenu.frame.size.height)/2+self.navHeight);
        }];
    }else{
        _LeftOrRight = true;
        [UIView animateWithDuration:0.2 animations:^{
            //向右移动动画
            self->_CategoryMenu.center = CGPointMake(-self.mainWidth/12,(self.CategoryMenu.frame.size.height)/2+self.navHeight);
        }];
    }
}
#pragma mark - 刷新事件与menu事件
- (void)refresh:(UIRefreshControl *)sender
{
    [self.storageArray removeAllObjects];
    [self.cellDic removeAllObjects];
    [self.StorageItemView reloadData];
    // 停止刷新
    [sender endRefreshing];
}
- (void)DeleteCell:(UIMenuController *)menu
{
    isEdit = false;
    NSLog(@"%@",menu.accessibilityValue);
    NSLog(@"点击了删除");
    NSString *sql = [NSString stringWithFormat:@"delete from Fosa2 where foodName = '%@'",menu.accessibilityValue];
    NSLog(@"%@",menu.accessibilityValue);
    [self deleteFile:menu.accessibilityValue];//删除存储在沙盒下下的同名的食物图片
    char * errmsg;
    sqlite3_exec(_database, sql.UTF8String, NULL, NULL, &errmsg);
    if (errmsg) {
        NSLog(@"删除失败--%s",errmsg);
    }else{
        NSLog(@"删除成功");
        [self.storageArray removeAllObjects];
        [self.cellDic removeAllObjects];
        [self.StorageItemView reloadData];
        if (self.storageArray.count == 0) {
            [self.addView removeFromSuperview];
        }
    }
}
- (void)deleteFile:(NSString *)photoName {
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photo = [NSString stringWithFormat:@"%@.png",photoName];
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent: photo];
    NSFileManager* fileManager=[NSFileManager defaultManager];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!blHave) {
        NSLog(@"no  have");
    }else {
        NSLog(@" have");
        BOOL blDele= [fileManager removeItemAtPath:filePath error:nil];
        if (blDele) {
            NSLog(@"dele success");
        }else {
            NSLog(@"dele fail");
        }
    }
}
- (void)CancelEdit:(UIMenuController *)menu
{
    NSLog(@"点击了取消");
    isEdit = false;
}
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
#pragma mark - UICollectionViewDataSource

//每个section有几个item
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //[self creatOrOpensql];
    [self SelectDataFromSqlite];
    return self.storageArray.count;
}
//collectionView有几个section
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
//返回这个UICollectionViewCell是否可以被选择
- ( BOOL )collectionView:( UICollectionView *)collectionView shouldSelectItemAtIndexPath:( NSIndexPath *)indexPath{
    return YES ;
}
//每个cell的具体内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:( NSIndexPath *)indexPath {

    // 每次先从字典中根据IndexPath取出唯一标识符
    NSString *identifier = [_cellDic objectForKey:[NSString stringWithFormat:@"%@", indexPath]];
 // 如果取出的唯一标示符不存在，则初始化唯一标示符，并将其存入字典中，对应唯一标示符注册Cell
    if (identifier == nil) {
        identifier = [NSString stringWithFormat:@"%@%@", ID, [NSString stringWithFormat:@"%@", indexPath]];
        [_cellDic setValue:identifier forKey:[NSString stringWithFormat:@"%@", indexPath]];
// 注册Cell
        [_StorageItemView registerClass:[FoodCollectionViewCell class] forCellWithReuseIdentifier:identifier];
    }
    FoodCollectionViewCell *cell = [self.StorageItemView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

    //给自定义cell的model传值
    long int index = indexPath.section*2+indexPath.row;
    [cell setModel:self.storageArray[index]];
    cell.backgroundColor = [UIColor colorWithRed:155/255.0 green:251/255.5 blue:241/255.0 alpha:1.0];
    cell.layer.cornerRadius = 10;
    cell.foodImageview.layer.cornerRadius = 10;
    cell.userInteractionEnabled = YES;
    //给每一个cell添加长按手势
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lonePressMoving:)];
    _longPress.minimumPressDuration = 1; //长按时间
    [cell addGestureRecognizer:_longPress];
        return cell;
}
//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //获取点击的cell
    FoodCollectionViewCell *cell = (FoodCollectionViewCell *)[self collectionView:_StorageItemView cellForItemAtIndexPath:indexPath];
    [self ClickNotification:cell];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//点击效果
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    FoodCollectionViewCell *cell = (FoodCollectionViewCell *)[_StorageItemView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    NSLog(@"%@",cell.model.device);
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    FoodCollectionViewCell *cell = (FoodCollectionViewCell *)[_StorageItemView cellForItemAtIndexPath:indexPath];
      cell.backgroundColor = [UIColor colorWithRed:155/255.0 green:251/255.5 blue:241/255.0 alpha:1.0];
}
#pragma mark - WaterFlowLayoutDelegate
-(CGFloat)waterFlowLayout:(WaterFlowLayout *)WaterFlowLayout heightForWidth:(CGFloat)width andIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = (screen_height-TabbarHeight-NavigationHeight)/4;
    return cellHeight/[[self rateForWidthDividedHeight][indexPath.row] floatValue];
}
//瀑布流图片真实宽高比
- (NSArray *)rateForWidthDividedHeight{
    
    CGFloat photoWidth;
    CGFloat photoHeigh;
    CGSize photoSize;
    __block NSMutableArray *rates = [NSMutableArray array];
    for (int i = 0; i < self.storageArray.count; i++) {
        photoSize = [self getImageSize:self.storageArray[i].foodPhoto];
        photoWidth = photoSize.width;
        photoHeigh = photoSize.height;
        [rates addObject:@(photoWidth/photoHeigh)];
    }
    return rates;
}
//取出保存在本地的图片
-(CGSize)getImageSize:(NSString *)filepath{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photopath = [NSString stringWithFormat:@"%@.png",filepath];
    NSString *imagePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",photopath]];
    // 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
   // NSLog(@"===%f-------%f", img.size.height,img.size.width);
    return img.size;
}
#pragma mark - UIGestureRecognizer
//与didselect不冲突
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if (touch.view != self.StorageItemView) {
        return NO;
    }else{
        [self moveMenu];
        return YES;
    }
}
- (void)viewWillDisappear:(BOOL)animated{
    [SqliteManager CloseSql:_database];
    isUpdate = true;
}
@end
