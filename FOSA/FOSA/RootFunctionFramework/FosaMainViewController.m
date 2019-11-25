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
#import "MenuModel.h"
#import "FosaMenu.h"
#import "FoodInfoViewController.h"
#import "CellModel.h"
#import "FoodModel.h"
#import "FosaNotification.h"

#import <UserNotifications/UserNotifications.h>
#import "LoadCircleView.h"
#import "SqliteManager.h"

@interface FosaMainViewController ()<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,UIGestureRecognizerDelegate>{
    int i;
    NSString *ID;
    Boolean isEdit;
    CGFloat cellHeight;
}

@property (nonatomic,strong) UIView *CategoryMenu;  //菜单视图
@property(nonatomic,assign) sqlite3 *database;
//结果集定义
@property(nonatomic,assign) sqlite3_stmt *stmt;



@property (nonatomic,assign) int count;
@property (nonatomic,assign) Boolean LeftOrRight;
@property (nonatomic,strong) NSMutableArray<CellModel *> *storageArray;
@property (nonatomic,strong) NSMutableArray<FoodModel *> *foodArray;
@property (nonatomic,strong) UIRefreshControl *refresh;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPress;//长按手势

@property (nonatomic,strong) LoadCircleView *circleview;
@property (nonatomic,strong) FosaNotification *notification;
@end

@implementation FosaMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //self.view.backgroundColor = [UIColor whiteColor];
    
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
    [self InitAddView];
    
//    //分割字符串的测试
//    NSString *string = @"abcd&efgh&ijkl&mnop&qrst";
//    NSArray *array = [NSArray array];
//    array = [string componentsSeparatedByString:@"&"];
//    NSLog(@"<<<<<<<<<<<<%@",array[0]);
//
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self creatOrOpensql];
    //[self SelectDataFromSqlite];
    if (self.StorageItemView != nil) {
        NSLog(@"异步刷新界面");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.storageArray removeAllObjects];
            [self.StorageItemView reloadData];
        });
    }
}
- (void)InitView{
    ID = @"FosaCell";
    isEdit = false;
    _LeftOrRight = true;    //true mean that the view is folded
    cellHeight = 101.666667;
    _count = 0;
    self.storageArray = [[NSMutableArray alloc]init];
    self.mainWidth = [UIScreen mainScreen].bounds.size.width;
    self.mainHeight = [UIScreen mainScreen].bounds.size.height;
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    NSLog(@"======%f",self.navHeight);
    //初始化layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    //setting the rolling direction of the collectionViw
    [layout setScrollDirection:(UICollectionViewScrollDirectionVertical)];
    layout.itemSize = CGSizeMake((self.mainWidth*11/12-15)/2,self.mainWidth/3-5);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 0, 5);
    
    self.StorageItemView = [[UICollectionView alloc]initWithFrame:CGRectMake(self.mainWidth*1/12, _navHeight, _mainWidth*11/12, _mainHeight) collectionViewLayout:layout];
    _StorageItemView.backgroundColor = [UIColor whiteColor];
    _StorageItemView.showsVerticalScrollIndicator = NO;
    //regist the user-defined collctioncell
    [_StorageItemView registerClass:[FoodCollectionViewCell class] forCellWithReuseIdentifier:ID];

    //给view 添加滑动事件
//     UISwipeGestureRecognizer *recognizer;
//        //right--
//        recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
//        [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
//        [[self view] addGestureRecognizer:recognizer];
//        //[recognizer release];
//        //left---
//        recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
//        [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
//        [[self view] addGestureRecognizer:recognizer];
//        //[recognizer release];
    UIGestureRecognizer *Crecognizer = [[UIGestureRecognizer alloc]initWithTarget:self action:@selector(moveMenu)];
    Crecognizer.delegate = self;
    [[self StorageItemView] addGestureRecognizer:Crecognizer];

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
    _notification = [[FosaNotification alloc]init];
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

- (void)InitAddView{
    //在UICollectionView最后添加一个addview
    CGFloat cellWidth = (self.StorageItemView.frame.size.width-15)/2;
    CGFloat cellheight = cellHeight;
    NSLog(@"***********%f",cellheight);
    CGFloat x = 5+(self.storageArray.count%2)*(cellWidth+5);
    CGFloat y = 0;
    if (_storageArray.count == 0) {
        y = 5;
    }else if(self.storageArray.count % 2 == 0){
        y = (cellheight+5)*(self.storageArray.count/2)+5;
    }else if(self.storageArray.count % 2 == 1){
        y = (cellheight+5)*(self.storageArray.count/2)+5;
    }
    self.addView = [[UIButton alloc]initWithFrame:CGRectMake(x, y, cellWidth, cellheight)];
    self.addView.layer.cornerRadius = 5;
    _addView.backgroundColor = [UIColor colorWithRed:105/255.0 green:251/255.5 blue:241/255.0 alpha:1.0];
    [self.addView setImage:[UIImage imageNamed:@"icon_additem"] forState:UIControlStateNormal];
    [self.StorageItemView addSubview:self.addView];
    //添加点击事件
    [self.addView addTarget:self action:@selector(addFunction) forControlEvents:UIControlEventTouchUpInside];
}
// 添加事件
- (void) addFunction{
   PhotoViewController *photo = [[PhotoViewController alloc]init];
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
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *str = [formatter stringFromDate:currentDate];
    currentDate = [formatter dateFromString:str];
    NSLog(@"%@",str);
    
    //查询数据库所有食品并获得其foodname和expire date
    for (int i = 0; i < _storageArray.count; i++) {
NSLog(@"foodName=%@&&&&&&&expireDate=%@",_storageArray[i].foodName,_storageArray[i].remindDate);
        NSString *Edate = _storageArray[i].remindDate;
        NSDate *foodDate = [[NSDate alloc]init];
        NSLog(@"%@",Edate);
        foodDate = [formatter dateFromString:Edate];
        NSLog(@"%@-------%@",currentDate,foodDate);
        NSComparisonResult result = [currentDate compare:foodDate];
        
        if (result == NSOrderedDescending) {
            isSend = true;
            NSString *body = [NSString stringWithFormat:@"Fosa 提醒你应该在%@ 食用 %@",_storageArray[i].remindDate,_storageArray[i].foodName];
            //发送通知
            [_notification sendNotification:_storageArray[i].foodName body:body path:_storageArray[i].foodPhoto deviceName:_storageArray[i].device];
            
        }else if (result == NSOrderedAscending){
            NSLog(@"%@ 将在 %@ 过期了，请及时使用",_storageArray[i].foodName,_storageArray[i].remindDate);
        }else{
    NSLog(@"%@刚好在今天过期",_storageArray[i].foodName);
            NSString *body = [NSString stringWithFormat:@"今天要记得吃 %@",_storageArray[i].foodName];
            //发送通知
            [_notification sendNotification:_storageArray[i].foodName body:body path:_storageArray[i].foodPhoto deviceName:_storageArray[i].device];
        }
    }
    _circleview = [[LoadCircleView alloc]initWithFrame:CGRectMake(0  ,400,self.view.frame.size.width,100)];
    //添加到视图上展示
     [self.view addSubview:_circleview];
    [self performSelector:@selector(removeLoading) withObject:nil afterDelay:3.0f];
    
}
- (void)removeLoading{
    [self.circleview removeFromSuperview];
}
//跳转到扫码界面
- (void)Scan{
    
    ScanOneCodeViewController *fosa_scan = [[ScanOneCodeViewController alloc]init];
    fosa_scan.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:fosa_scan animated:YES];
}

#pragma mark - 数据库操作
- (void)creatOrOpensql
{
    self.database = [SqliteManager InitSqliteWithName:@"Fosa.db"];
}
- (void) SelectDataFromSqlite{
    //查询数据库添加的食物
    NSString *sql = [NSString stringWithFormat:@"select foodName,deviceName,aboutFood,expireDate,remindDate,photoPath from Fosa2"];
    self.stmt = [SqliteManager SelectDataFromTable:sql database:self.database];
    if (self.stmt != NULL) {
        while (sqlite3_step(_stmt) == SQLITE_ROW) {
                    const char *food_name = (const char *)sqlite3_column_text(_stmt, 0);
                    const char *device_name = (const char*)sqlite3_column_text(_stmt,1);
                    const char *remind_date = (const char*)sqlite3_column_text(_stmt,4);
                    const char *expired_date = (const char *)sqlite3_column_text(_stmt,3);
                    const char *photo_path = (const char *)sqlite3_column_text(_stmt,5);
        
                    NSLog(@"查询到数据%@",[NSString stringWithUTF8String:food_name]);
                    NSLog(@"查询到数据%@",[NSString stringWithUTF8String:expired_date]);
                    NSLog(@"查询到数据%@",[NSString stringWithUTF8String:photo_path]);
                    NSLog(@"********************************");
                    [self CreatFoodViewWithName:[NSString stringWithUTF8String:food_name] fdevice:[NSString stringWithUTF8String:device_name] remindDate:[NSString stringWithUTF8String:remind_date] foodPhoto:[NSString stringWithUTF8String:photo_path]] ;
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
    if (!isEdit) {
        FoodInfoViewController *info = [[FoodInfoViewController alloc]init];
        info.hidesBottomBarWhenPushed = YES;
        info.deviceID = cell.model.device;
        [self.navigationController pushViewController:info animated:YES];
    }else{
        NSLog(@"正处于编辑状态无法跳转");
    }
}
//点击种类选项
- (void)ClickCategory:(UIGestureRecognizer *)recognizer{
    NSLog(@"%@",recognizer.accessibilityValue);
}
#pragma mark - UICollectionView 事件
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
//-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
//{
//    if(recognizer.direction==UISwipeGestureRecognizerDirectionLeft) {
//        NSLog(@"swipe left");
//        //执行程序
//        [self moveMenu];
//    }
//    if(recognizer.direction==UISwipeGestureRecognizerDirectionRight) {
//
//        NSLog(@"swipe right");
//        //执行程序
//        [self moveMenu];
//    }
//}
- (void) moveMenu
{
//    if (_LeftOrRight) {//view 折叠
//        _LeftOrRight = false;
//        //view 向左移动
//       _CategoryMenu.center = CGPointMake(self.CategoryMenu.frame.size.width/2, (self.CategoryMenu.frame.size.height)/2+self.navHeight);
//   }
if (!_LeftOrRight) {//view 展开
        _LeftOrRight = true;
        //向右移动
         _CategoryMenu.center = CGPointMake(-self.mainWidth/12,(self.CategoryMenu.frame.size.height)/2+self.navHeight);
    }
}
#pragma mark - 刷新事件与menu事件
- (void)refresh:(UIRefreshControl *)sender
{
    [self.storageArray removeAllObjects];
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
    [self deleteFile:menu.accessibilityValue];//删除存储在沙盒下下的同名的食物图片
    char * errmsg;
    sqlite3_exec(_database, sql.UTF8String, NULL, NULL, &errmsg);
    if (errmsg) {
        NSLog(@"删除失败--%s",errmsg);
    }else{
        NSLog(@"删除成功");
        [self.storageArray removeAllObjects];
        [self.StorageItemView reloadData];
        if (self.storageArray.count == 0) {
            [self.addView removeFromSuperview];
            [self InitAddView];
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
    [self creatOrOpensql];
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
    FoodCollectionViewCell *cell = [self.StorageItemView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    cellHeight = cell.frame.size.height;//获取cell的高度
    //给自定义cell的model传值
    long int index = indexPath.section*2+indexPath.row;
    cell.model = self.storageArray[index];
    
    [cell setModel:cell.model];
        //cell.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
    cell.backgroundColor = [UIColor colorWithRed:155/255.0 green:251/255.5 blue:241/255.0 alpha:1.0];
        cell.layer.cornerRadius = 10;
        cell.userInteractionEnabled = YES;
        //给每一个cell添加长按手势
        _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lonePressMoving:)];
        _longPress.minimumPressDuration = 2.0;
        [cell addGestureRecognizer:_longPress];
    
    if (index+1 == self.storageArray.count) {
        [self.addView removeFromSuperview];
        [self InitAddView];
    }
        return cell;
    //}
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


- (void)viewDidDisappear:(BOOL)animated{
    int close = sqlite3_close_v2(_database);
    if (close == SQLITE_OK) {
            _database = nil;
    }else{
            NSLog(@"数据库关闭异常");
    }
}

@end
