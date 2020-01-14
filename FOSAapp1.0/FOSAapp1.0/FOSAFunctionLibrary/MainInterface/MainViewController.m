//
//  MainViewController.m
//  FOSAapp1.0
//
//  Created by hs on 2019/12/30.
//  Copyright © 2019 hs. All rights reserved.
//

#import "MainViewController.h"
#import "MainPhotoViewController.h"
#import "FoodViewController.h"
#import "MenuTableViewCellXIB.h"
#import "FosaNotification.h"
#import "LoadCircleView.h"
#import <UserNotifications/UserNotifications.h>
#import "FMDB.h"

@interface MainViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,FOSAFlowLayoutDelegate,UICollectionViewDelegateFlowLayout>{
    NSString *ID;
    NSString *docPath;
    //刷新标识
    Boolean isUpdate;
    
}
@property (nonatomic,strong) NSMutableArray<UIImage *> *imageArray;
@property (nonatomic,strong) UILongPressGestureRecognizer *longPress;//长按手势
@property (nonatomic,strong) FMDatabase *db;

@property (nonatomic,strong) FosaNotification *notification;
@property (nonatomic,strong) LoadCircleView *circleview;

@property (nonatomic,strong) NSMutableArray *categoryArray;

@end

@implementation MainViewController

/**懒加载属性*/
- (UITableView *)CategoryMenuTable{
    if (_CategoryMenuTable == nil) {
        _CategoryMenuTable = [[UITableView alloc]initWithFrame:CGRectMake(-screen_width/4, screen_height/6, screen_width/3, screen_height*2/3) style:UITableViewStylePlain];
    }
    return _CategoryMenuTable;
}
- (UIImageView *)mainImageView{
    if (_mainImageView == nil) {
        _mainImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, screen_width, screen_height/3)];
        _mainImageView.contentMode = UIViewContentModeScaleAspectFill;
        _mainImageView.clipsToBounds = YES;
    }
    return _mainImageView;
}
- (FOSAFlowLayout *)FOSALayout{
    if (_FOSALayout == nil) {
        _FOSALayout = [[FOSAFlowLayout alloc]init];
        _FOSALayout.delegate = self;
    }
    return _FOSALayout;
}

- (UIButton *)addContentBtn{
    if (_addContentBtn == nil) {
        _addContentBtn = [[UIButton alloc]init];
    }
    return _addContentBtn;
}
- (NSMutableArray<FoodModel *> *)collectionDataSource{
    if (_collectionDataSource == nil) {
        _collectionDataSource = [[NSMutableArray alloc]init];
        //[self OpenSqlDatabase:@"FOSA"];
    }
    return _collectionDataSource;
}
- (NSMutableArray<NSString *> *)menuDataSource{
    if (_menuDataSource == nil) {
        _menuDataSource = [[NSMutableArray alloc]init];
    }
    return _menuDataSource;
}

- (NSMutableArray<NSString *> *)cellDic{
    if (_cellDic == nil) {
        _cellDic = [[NSMutableArray alloc]init];
    }
    return _cellDic;
}
- (NSMutableDictionary *)cellDictionary{
    if (_cellDictionary == nil) {
        _cellDictionary = [[NSMutableDictionary alloc]init];
    }
    return _cellDictionary;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = FOSAWhite;
    
    [self CreatMainView];
    [self CreateCategoryMenu];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (isUpdate) {
        NSLog(@"异步刷新界面");
        dispatch_async(dispatch_get_main_queue(), ^{
            [self CollectionReload];
        });
    }
}
- (void)CollectionReload{
    [self.collectionDataSource removeAllObjects];
    [self.cellDictionary removeAllObjects];
    [self OpenSqlDatabase:@"FOSA"];
    [self SelectDataFromFoodTable];
    [self.foodItemCollection reloadData];
}
#pragma mark - 导航栏按钮事件
- (void)BeginScanQRCode{
    QRCodeScanViewController *QRScan = [[QRCodeScanViewController alloc]init];
    QRScan.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:QRScan animated:YES];
}
- (void)SendRemindNotification{
    [self.notification initNotification];
    UIImage *image = [[UIImage alloc]init];
    //标志
    Boolean isSend = false;
    //获取当前日期
    NSDate *currentDate = [[NSDate alloc]init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    
    NSDateFormatter *formatter2 = [[NSDateFormatter alloc]init];
    [formatter2 setDateFormat:@"MM/dd/yyyy HH:mm"];
    
    NSString *str = [formatter stringFromDate:currentDate];
    currentDate = [formatter dateFromString:str];
    NSLog(@"%@",str);
    NSDate *foodDate = [[NSDate alloc]init];
    for(int i = 0;i < self.collectionDataSource.count; i++){
  NSLog(@"%@的提醒日期为%@",self.collectionDataSource[i].foodName,self.collectionDataSource[i].remindDate);
        NSString *RDate = self.collectionDataSource[i].remindDate;
        foodDate = [formatter2 dateFromString:RDate];
        //NSLog(@"foodDate:%@",foodDate);
        RDate = [formatter stringFromDate:foodDate];
        foodDate = [formatter dateFromString:RDate];
        //NSLog(@"RDate:%@",RDate);
        //比较提醒日期与今天的日期
        NSComparisonResult result = [currentDate compare:foodDate];
        if (result == NSOrderedDescending) { //foodDate 在 currentDate 之前
                isSend = true;
                NSString *body = [NSString stringWithFormat:@"FOSA 提醒你应该在%@ 食用 %@",self.collectionDataSource[i].remindDate,self.collectionDataSource[i].foodName];
                //发送通知
            //获取通知的图片
            image = [self getImage:self.collectionDataSource[i].foodPhoto];
            //另存通知图片
            [self Savephoto:image name:self.collectionDataSource[i].foodPhoto];
            [_notification sendNotification:self.collectionDataSource[i] body:body image:image];
            }else if (result == NSOrderedAscending){//foodDate 在 currentDate 之后
                NSLog(@"%@ 将在 %@ 过期了，请及时使用",self.collectionDataSource[i].foodName,self.collectionDataSource[i].remindDate);
            }else{
        NSLog(@"%@刚好在今天过期",self.collectionDataSource[i].foodName);
                NSString *body = [NSString stringWithFormat:@"今天要记得吃 %@",self.collectionDataSource[i].foodName];
                //获取通知的图片
                image = [self getImage:self.collectionDataSource[i].foodPhoto];
                //另存通知图片
                [self Savephoto:image name:self.collectionDataSource[i].foodPhoto];
                //发送通知
                [_notification sendNotification:self.collectionDataSource[i] body:body image:image];
            }
        }
    _circleview = [[LoadCircleView alloc]initWithFrame:CGRectMake(0  ,400,self.view.frame.size.width,100)];
       //添加到视图上展示
       [self.view addSubview:_circleview];
       [self performSelector:@selector(removeLoading) withObject:nil afterDelay:2.0f];
}
- (void)removeLoading{
    [self.circleview removeFromSuperview];
}

- (void)CreatMainView{
    isUpdate = false;
    //导航栏右侧扫码按钮
    UIButton *QRscan = [[UIButton alloc]initWithFrame:CGRectMake(0,0,40,40)];
    [QRscan setBackgroundImage:[UIImage imageNamed:@"icon_scanW"] forState:UIControlStateNormal];
    QRscan.showsTouchWhenHighlighted = YES;
    [QRscan addTarget:self action:@selector(BeginScanQRCode) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:QRscan];
    self.navigationItem.rightBarButtonItem = rightItem;
    //导航栏左侧提醒按钮
    UIButton *Remindbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    //Remindbtn setBackgroundImage:<#(nullable UIImage *)#> forState:<#(UIControlState)#>
    [Remindbtn setBackgroundImage:[UIImage imageNamed:@"icon_sendNotificationW"] forState:UIControlStateNormal];
    [Remindbtn addTarget:self action:@selector(SendRemindNotification) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:Remindbtn];
    self.navigationItem.leftBarButtonItem = leftItem;
    //初始化通知对象
    _notification = [[FosaNotification alloc]init];
    //头部图片
    self.mainImageView.image = [UIImage imageNamed:@"img_MainInterfaceBackground"];
    [self.view addSubview:self.mainImageView];
    //foodItem

    self.foodItemCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(screen_width*1/12, screen_height/3, screen_width*11/12, screen_height*2/3-TabbarHeight) collectionViewLayout:self.FOSALayout];

   // 1 先判断系统版本
    if ([NSProcessInfo.processInfo isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){10,0,0}])
    {
        // 2 初始化
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        // 3.1 配置刷新控件
        refreshControl.tintColor = [UIColor brownColor];
        NSDictionary *attributes = @{NSForegroundColorAttributeName : [UIColor redColor]};
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull To Refresh" attributes:attributes];
        // 3.2 添加响应事件
        [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
        // 4 把创建的refreshControl赋值给scrollView的refreshControl属性
        self.foodItemCollection.refreshControl = refreshControl;
    }
    self.foodItemCollection.delegate   = self;
    self.foodItemCollection.dataSource = self;
    self.foodItemCollection.showsVerticalScrollIndicator = NO;
    self.foodItemCollection.backgroundColor = [UIColor whiteColor];
    self.foodItemCollection.bounces = NO;
    [self.view addSubview:self.foodItemCollection];
    //添加按钮
    self.addContentBtn = [[UIButton alloc]initWithFrame:CGRectMake(screen_width*5/6, screen_height/6, screen_width/6, screen_width/6)];
    [_addContentBtn setBackgroundImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    [self.view insertSubview:_addContentBtn atIndex:10];
    [_addContentBtn addTarget:self action:@selector(addFunction) forControlEvents:UIControlEventTouchUpInside];

    //添加模糊层
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    self.visualView = [[UIVisualEffectView alloc] initWithEffect:blur];
    self.visualView.frame = CGRectMake(0, 0, screen_width, screen_height);
    self.visualView.hidden = YES;
    self.visualView.alpha = 0.8;
    UITapGestureRecognizer *clickToClose = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(closeVisualView)];
    [self.visualView addGestureRecognizer:clickToClose];
    [self.view addSubview:self.visualView];

    [self CollectionReload];
}
#pragma mark - CreateCategoryMenu
- (void)CreateCategoryMenu{
    //数据源
    self.menuDataSource = [self getCategoryArray];
    //初始化模糊层
//    //创建渐变色
//    CAGradientLayer * gradientLayer = [CAGradientLayer layer];
//    gradientLayer.frame = self.CategoryMenuTable.bounds;
//    gradientLayer.colors = @[(__bridge id)FOSAgreen.CGColor,(__bridge id)FOSAgreengrad.CGColor];
//    gradientLayer.startPoint = CGPointMake(0, 0);
//    gradientLayer.endPoint = CGPointMake(1.0, 1.0);
//    gradientLayer.locations = @[@0,@1];
//    UIView *view = [[UIView alloc]initWithFrame:self.CategoryMenuTable.bounds];
//    [view.layer addSublayer:gradientLayer];
//    [self.CategoryMenuTable setBackgroundView:view];
    self.CategoryMenuTable.layer.cornerRadius = 15;
    self.CategoryMenuTable.delegate = self;
    self.CategoryMenuTable.dataSource = self;
    self.CategoryMenuTable.showsVerticalScrollIndicator = NO;
    self.CategoryMenuTable.bounces = NO;
    
    //关联NIB与tableview
    UINib *nib = [UINib nibWithNibName:@"MenuTableViewCellXIB" bundle:nil];
    [self.CategoryMenuTable registerNib:nib forCellReuseIdentifier:@"categoryCell"];
    [self.view addSubview:self.CategoryMenuTable];
    //给view 添加滑动事件
    UISwipeGestureRecognizer *recognizer;
    //right--
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];
    [[self view] addGestureRecognizer:recognizer];
    //left---
    recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    [[self view] addGestureRecognizer:recognizer];
}
//屏幕滑动手势, 用于控制菜单左右滑动
-(void)handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer
{
    if(recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"swipe left");
        //执行程序
        [UIView animateWithDuration:0.2 animations:^{
            self.CategoryMenuTable.center = CGPointMake(-screen_width/12, self.CategoryMenuTable.center.y);
        }];
        self.visualView.hidden = YES;
        self.navigationController.navigationBar.hidden = NO;
        self.tabBarController.tabBar.hidden = NO;
    }
    if(recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"swipe right");
        //执行程序
        [UIView animateWithDuration:0.2 animations:^{
            self.CategoryMenuTable.center = CGPointMake(screen_width/6, self.CategoryMenuTable.center.y);
        }];
        self.visualView.hidden = NO;
        self.navigationController.navigationBar.hidden = YES;
        self.tabBarController.tabBar.hidden = YES;
    }
}
//模糊层点击事件
- (void)closeVisualView{
    if (![self.visualView isHidden]) {
        [UIView animateWithDuration:0.2 animations:^{
            self.CategoryMenuTable.center = CGPointMake(-screen_width/12, self.CategoryMenuTable.center.y);
        }];
        self.visualView.hidden = YES;
        self.navigationController.navigationBar.hidden = NO;
        self.tabBarController.tabBar.hidden = NO;
    }
}
//添加食物事件
- (void)InitPhotoArray{
    UIImage *image = [UIImage imageNamed:@"icon_logoHL"];
    UIImage *image1 = [UIImage imageNamed:@"icon_logoHL"];
    UIImage *image2 = [UIImage imageNamed:@"icon_logoHL"];
    _imageArray = [[NSMutableArray alloc]init];
    [_imageArray addObject:image];
    [_imageArray addObject:image1];
    [_imageArray addObject:image2];
}

- (void) addFunction{
    [self InitPhotoArray];
    FoodViewController *food = [[FoodViewController alloc]init];
    food.food_image = _imageArray;
    food.isAdding = true;
    food.device = @"FS900000000000001";
    food.hidesBottomBarWhenPushed = YES;
    
    MainPhotoViewController *photo = [[MainPhotoViewController alloc]init];
    photo.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:food animated:YES];
}
#pragma mark - UITableViewDelegate
//行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.CategoryMenuTable.frame.size.height/5;
}
//每组多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.menuDataSource.count;
}
//多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MenuTableViewCellXIB *cell = [self.CategoryMenuTable dequeueReusableCellWithIdentifier:@"categoryCell"];
    if (cell == nil) {
        //创建cell
        cell = [[MenuTableViewCellXIB alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"categoryCell"];
    }
    long int index = indexPath.row;
    [cell configCell:_menuDataSource[index]];
    cell.backgroundColor = FOSAgreen;
    cell.backgroundView.alpha = 1.0 - 0.1*(int)index;
    //取消点击cell时显示的背景色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    MenuTableViewCellXIB *cell = [self.CategoryMenuTable cellForRowAtIndexPath:indexPath];
    cell.alpha = 0.8;
   
    [self cellAction:cell];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.CategoryMenuTable cellForRowAtIndexPath:indexPath];
    cell.alpha = 1.0;
}
/**种类cell的点击事件*/
- (void)cellAction:(MenuTableViewCellXIB *)cell{
   //执行程序
    [UIView animateWithDuration:0.2 animations:^{
        self.CategoryMenuTable.center = CGPointMake(-screen_width/12, self.CategoryMenuTable.center.y);
    }];
    self.visualView.hidden = YES;
    self.navigationController.navigationBar.hidden = NO;
    self.tabBarController.tabBar.hidden = NO;
    cell.alpha = 1.0;

    NSString *category = cell.categoryTitle.text;
    NSLog(@"点击了：%@",category);
    NSLog(@"%lu",(unsigned long)self.collectionDataSource.count);
    NSMutableArray<FoodModel *>  *temp = [[NSMutableArray alloc]init];
    for (int i = 0; i < self.collectionDataSource.count; i++) {
        if ([self.collectionDataSource[i].category isEqualToString:category]) {
            [temp addObject:self.collectionDataSource[i]];
        }
    }
    [self.collectionDataSource removeAllObjects];
    self.collectionDataSource = temp;
    [self.foodItemCollection reloadData];
}
#pragma mark - UICollectionViewDataSource
//每个section有几个item
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"UICollectionViewCell的个数:%lu",[self.collectionDataSource count]);
    return [self.collectionDataSource count];
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
    //FoodItemCollectionViewCell
    long int index = indexPath.section*2+indexPath.row;
      // 每次先从字典中根据IndexPath取出唯一标识符
        NSString *identifier = [_cellDictionary objectForKey:[NSString stringWithFormat:@"%@", indexPath]];
     // 如果取出的唯一标示符不存在，则初始化唯一标示符，并将其存入字典中，对应唯一标示符注册Cell
        if (identifier == nil) {
            identifier = [NSString stringWithFormat:@"%@%@", ID, [NSString stringWithFormat:@"%@", indexPath]];
            [_cellDictionary setValue:identifier forKey:[NSString stringWithFormat:@"%@", indexPath]];
    // 注册Cell
            [self.foodItemCollection registerClass:[FoodItemCollectionViewCell class] forCellWithReuseIdentifier:identifier];
        }
//    NSString *identifier = self.cellDic[index];
//    NSLog(@"cellDic的长度:%lu",self.cellDic.count);
//    // 如果取出的唯一标示符不存在，则初始化唯一标示符，并将其存入字典中，对应唯一标示符注册Cell
//    if (identifier == nil) {
//        identifier = [NSString stringWithFormat:@"%@%@", ID, [NSString stringWithFormat:@"%@", indexPath]];
//        [self.cellDic addObject:identifier];
//    // 注册Cell
//        [_foodItemCollection registerClass:[FoodItemCollectionViewCell class] forCellWithReuseIdentifier:identifier];
//    }
    FoodItemCollectionViewCell *cell = [self.foodItemCollection dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];

    //给自定义cell的model传值
    
    NSLog(@"--------------%lu~~~~~~~~~~~~~~~~~~%lu",index,indexPath.row);
    [cell setModel:self.collectionDataSource[index]];
    cell.backgroundColor = [UIColor colorWithRed:155/255.0 green:251/255.5 blue:241/255.0 alpha:1.0];
    cell.layer.cornerRadius = 10;
    cell.foodImageview.layer.cornerRadius = 10;
    cell.userInteractionEnabled = YES;
    //给每一个cell添加长按手势
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(lonePressMoving:)];
    longPress.minimumPressDuration = 0.75; //长按时间
    [cell addGestureRecognizer:longPress];
    return cell;
}
//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    FoodItemCollectionViewCell *cell = (FoodItemCollectionViewCell *)[self.foodItemCollection cellForItemAtIndexPath:indexPath];
    [self ClickNotification:cell];
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//点击效果
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    FoodItemCollectionViewCell *cell = (FoodItemCollectionViewCell *)[self.foodItemCollection cellForItemAtIndexPath:indexPath];
    cell.alpha = 0.5;
    NSLog(@"%@",cell.model.device);
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    FoodItemCollectionViewCell *cell = (FoodItemCollectionViewCell *)[self.foodItemCollection cellForItemAtIndexPath:indexPath];
    cell.alpha = 1.0;
    NSLog(@"%@",cell.model.device);
}

//点击通知项的方法
- (void)ClickNotification:(FoodItemCollectionViewCell *)cell{
    FoodViewController *foodInfo = [[FoodViewController alloc]init];
    foodInfo.isAdding = false;
    foodInfo.device = cell.model.device;
    foodInfo.foodNameInput.text   = cell.model.foodName;
    foodInfo.aboutFoodInput.text  = cell.model.aboutFood;
    foodInfo.remindDateLable.text = cell.model.remindDate;
    foodInfo.expireDateLable.text = cell.model.expireDate;
    foodInfo.categoryLable.text   = cell.model.category;
    foodInfo.food_image = [self getCellImageArray:cell.model.foodName];
    foodInfo.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:foodInfo animated:YES];
}

#pragma mark - UICollectionViewCell 长按事件
- (void)lonePressMoving:(UILongPressGestureRecognizer *)longPress
{
    NSLog(@"长按了item");
    if (longPress.state == UIGestureRecognizerStateBegan) {
            FoodItemCollectionViewCell *cell = (FoodItemCollectionViewCell *)longPress.view;
            NSLog(@"%@",cell.model.foodName);
            [cell becomeFirstResponder];
            UIMenuItem *item1 = [[UIMenuItem alloc]initWithTitle:@"删除"action:@selector(DeleteCell:)];
            UIMenuItem *item2 = [[UIMenuItem alloc]initWithTitle:@"取消"action:@selector(CancelEdit:)];
             UIMenuController *menu = [UIMenuController sharedMenuController];
            [menu setMenuItems:@[item1,item2]];
        if (@available(iOS 13,*)) {
            menu.accessibilityElements = @[cell.model.foodName,cell.model.device];
            [menu showMenuFromView:self.foodItemCollection rect:cell.frame];
        }else{
            [menu setTargetRect:cell.frame inView:self.foodItemCollection];
            menu.accessibilityElements = @[cell.model.foodName,cell.model.device];
            [menu setMenuVisible:YES animated:YES];
        }
    }
}
- (void)refresh:(UIRefreshControl *)sender
{
    [self CollectionReload];
    [self.foodItemCollection reloadData];
    // 停止刷新
    [sender endRefreshing];
}
- (void)DeleteCell:(UIMenuController *)menu
{
    NSString *foodName = menu.accessibilityElements[0];
    NSString *device   = menu.accessibilityElements[1];
    NSLog(@"%@-------%@",foodName,device);
    //删除数据库数据
    NSString *DeleSql = [NSString stringWithFormat:@"delete from FoodStorageInfo where foodName = '%@' and device = '%@';",foodName,device];
    if ([self.db open]) {
         BOOL result = [self.db executeUpdate:DeleSql];
        if (result) {
            NSLog(@"delete data successfully");
            for (int i = 1; i <= 3; i++) {
                NSString *photoName = [NSString stringWithFormat:@"%@%d",foodName,i];
                [self deleteFile:photoName];
            }
            [self CollectionReload];
            [self.foodItemCollection reloadData];
        }else{
            NSLog(@"Fail");
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
    //isEdit = false;
}
- (BOOL)canBecomeFirstResponder
{
    return YES;
}
#pragma mark - WaterFlowLayoutDelegate
-(CGFloat)waterFlowLayout:(FOSAFlowLayout *)WaterFlowLayout heightForWidth:(CGFloat)width andIndexPath:(NSIndexPath *)indexPath{
    CGFloat cellHeight = (screen_height-TabbarHeight-NavigationHeight)/4;
    return cellHeight/[[self rateForWidthDividedHeight][indexPath.row] floatValue];
}
//瀑布流图片真实宽高比
- (NSArray *)rateForWidthDividedHeight{
    
    CGFloat photoWidth;
    CGFloat photoHeigh;
    CGSize photoSize;
    __block NSMutableArray *rates = [NSMutableArray array];
    NSLog(@"%lu",(unsigned long)_collectionDataSource.count);
    for (int i = 0; i < self.collectionDataSource.count; i++) {
        photoSize = [self getImageSize:self.collectionDataSource[i].foodPhoto];
        photoWidth = photoSize.width;
        photoHeigh = photoSize.height;
        [rates addObject:@(photoWidth/photoHeigh)];
    }
    return rates;
}
//取出保存在本地的图片
- (CGSize)getImageSize:(NSString *)filepath{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photopath = [NSString stringWithFormat:@"%@%d.png",filepath,1];
    NSString *imagePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",photopath]];
    // 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    NSLog(@"图片:%@------------尺寸>>>>%f-------%f",img,img.size.height,img.size.width);
    return img.size;
}
//获取食物图片数组
- (NSMutableArray<UIImage *> *)getCellImageArray:(NSString *)imgName{
    NSMutableArray<UIImage *> *foodImgArray = [[NSMutableArray alloc]init];
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    for (int i = 1; i <= 3; i++) {
        NSString *photopath = [NSString stringWithFormat:@"%@%d.png",imgName,i];
        NSString *imagePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",photopath]];
        // 保存文件的名称
        UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
        [foodImgArray addObject:img];
    }
    return foodImgArray;
}
//取出保存在本地的图片
- (UIImage*)getImage:(NSString *)filepath{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photopath = [NSString stringWithFormat:@"%@%d.png",filepath,1];
    NSString *imagePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",photopath]];
    // 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>%@", img);
    return img;
}
//保存图片到沙盒
-(void)Savephoto:(UIImage *)image name:(NSString *)foodname{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photoName = [NSString stringWithFormat:@"%@.png",foodname];
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent: photoName];// 保存文件的路径
    NSLog(@"这个是照片的保存地址:%@",filePath);
    BOOL result =[UIImagePNGRepresentation(image) writeToFile:filePath  atomically:YES];// 保存成功会返回YES
    if(result == YES) {
        NSLog(@"通知界面图片保存成功");
    }
}
#pragma mark -- FMDB数据库操作
- (void)OpenSqlDatabase:(NSString *)dataBaseName{
    //获取数据库地址
    docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
    //NSLog(@"%@",docPath);
    //设置数据库名
    NSString *fileName = [docPath stringByAppendingPathComponent:dataBaseName];
    //创建数据库
    self.db = [FMDatabase databaseWithPath:fileName];
    if([self.db open]){
        NSLog(@"打开数据库成功");
    }else{
        NSLog(@"打开数据库失败");
    }
    //[self.db close];
}
- (void)SelectDataFromFoodTable{

    NSString *sql = @"select * from FoodStorageInfo";
    FMResultSet *set = [self.db executeQuery:sql];
    while ([set next]) {
        //NSLog(@"===============================================================");
        NSString *foodName = [set stringForColumn:@"foodName"];
        NSString *device   = [set stringForColumn:@"device"];
        NSString *aboutFood = [set stringForColumn:@"aboutFood"];
        NSString *remindDate = [set stringForColumn:@"remindDate"];
        NSString *expireDate = [set stringForColumn:@"expireDate"];
        NSString *foodImg = [set stringForColumn:@"foodImg"];
        NSString *category = [set stringForColumn:@"category"];
        FoodModel *model = [FoodModel modelWithName:foodName DeviceID:device Description:aboutFood RemindDate:remindDate ExpireDate:expireDate foodIcon:foodImg category:category];
        [self.collectionDataSource addObject:model];
        NSLog(@"foodName    = %@",foodName);
        NSLog(@"device      = %@",device);
        NSLog(@"aboutFood   = %@",aboutFood);
        NSLog(@"remindDate  = %@",remindDate);
        NSLog(@"expireDate  = %@",expireDate);
        NSLog(@"foodImg     = %@",foodImg);
        NSLog(@"category    = %@",category);
    }
    [self.foodItemCollection reloadData];
}
- (NSMutableArray<NSString *> *)getCategoryArray{
    [self OpenSqlDatabase:@"FOSA"];
    NSMutableArray<NSString *> *category = [[NSMutableArray alloc]init];
    NSString *selSql = @"select * from category";
    FMResultSet *set = [self.db executeQuery:selSql];
    while ([set next]) {
        NSString *kind = [set stringForColumn:@"categoryName"];
        NSLog(@"%@",kind);
        [category addObject:kind];
    }
    NSLog(@"所有种类:%@",category);
    [category addObject:@"Add"];
    return category;
}
/**隐藏底部横条，点击屏幕可显示*/
- (BOOL)prefersHomeIndicatorAutoHidden{
    return YES;
}
- (void)viewWillDisappear:(BOOL)animated{
    isUpdate = true;
    [self.db close];
}
@end
