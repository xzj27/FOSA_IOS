//
//  FoodInfoViewController.m
//  fosa1.0
//
//  Created by hs on 2019/11/1.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FoodInfoViewController.h"
#import "ScanViewController.h"
#import "PhotoViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <sqlite3.h>

//图片宽高的最大值
#define KCompressibilityFactor 1280.00

@interface FoodInfoViewController ()<UITextFieldDelegate,UNUserNotificationCenterDelegate,UITextViewDelegate>{
    //日期选择
    UIDatePicker *datePicker;
    //日期选择器的容器
    UIView *dateView;
    UIButton *sure,*cancel;
    //选择的日期
    NSString *expire_Date,*remind_Date;
    //区分是属于提醒日期还是过期日期
    Boolean isRemind;
    //标示是否可编辑
    Boolean _CanEdit;
   
   }
@property(nonatomic,assign) NSString *storagePath;;
@property(nonatomic,assign) sqlite3 *database;
//结果集定义
@property(nonatomic,assign) sqlite3_stmt *stmt;


//记录所选择的日期
@property (nonatomic,assign) NSDate *exdate,*redate;
@end

@implementation FoodInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self InitialDatePicker];
    [self CreatAndInitView];
    [self creatOrOpensql];
    [self SelectDataFromSqlite];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //添加键盘弹出与收回的事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

}

-(void)InitialDatePicker{
    dateView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height*2/3-50,self.view.frame.size.width,self.view.frame.size.height/3+50)];
    dateView.backgroundColor = [UIColor whiteColor];
    
    sure = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, 50)];
    cancel = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, 50)];
    [sure setTitle:@"确定" forState:UIControlStateNormal];
    [sure setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [dateView addSubview:sure];
    [dateView addSubview:cancel];
    
    //添加响应
    [sure addTarget:self action:@selector(selected) forControlEvents:UIControlEventTouchUpInside];
    [cancel addTarget:self action:@selector(noSelect) forControlEvents:UIControlEventTouchUpInside];
    //初始化日期选择器
    datePicker = [[UIDatePicker alloc]initWithFrame: CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height/3)];
    datePicker.backgroundColor = [UIColor whiteColor];
    
    NSLocale *locale = [[NSLocale alloc]initWithLocaleIdentifier:@"zw"];
    datePicker.locale = locale;
    
    //默认显示当前日期
    [datePicker setCalendar:[NSCalendar currentCalendar]];
    //设置时区
    [datePicker setTimeZone:[NSTimeZone defaultTimeZone]];
    //设置Datepicker的允许的最大最小日期max&&min
    //现实年月日
    [datePicker setDatePickerMode:UIDatePickerModeDate];
    [dateView addSubview:datePicker];
}
//创建并初始化界面
-(void)CreatAndInitView{
    _CanEdit = false;
   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_edit"] style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem.target = self;     self.navigationItem.rightBarButtonItem.action = @selector(BeginEditing);
    
    self.mainWidth = [UIScreen mainScreen].bounds.size.width;
    self.mainheight = [UIScreen mainScreen].bounds.size.height;
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    
    self.rootScrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0, _navHeight, _mainWidth, _mainheight)];

    _rootScrollview.contentSize = CGSizeMake(self.view.frame.size.width,_mainheight*2);
    [self.view addSubview:_rootScrollview];
    

    //添加头部
    CGFloat headerWidth = _mainWidth-20;
    CGFloat headerheight = _mainheight/3;
    
    
    CGRect headerFrame = CGRectMake(10,5,headerWidth, headerheight);
    self.headerView = [[UIView alloc]initWithFrame:headerFrame];
    _headerView.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _headerView.layer.cornerRadius = 5;
    [self.rootScrollview addSubview:_headerView];
    
    //添加头部控件,已经在扫码界面初始化
    self.imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(15, headerheight/4-5,headerheight*3/4-5,headerheight*3/4-5)];
    self.imageView1.transform = CGAffineTransformMakeRotation(M_PI/2);
    self.deviceName = [[UITextView alloc]initWithFrame:CGRectMake(0, 0,headerWidth/2, headerheight/4-5)];
    self.deviceName.backgroundColor = [UIColor clearColor];
    [self.headerView addSubview:_imageView1];   //添加图片视图
    [self.headerView addSubview:_deviceName];
    
    self.share = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-35,5,30,30)];
    [_share setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    
    self.takePhoto = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-35,40, 30, 30)];
    [_takePhoto setImage:[UIImage imageNamed:@"icon_takePicture"] forState:UIControlStateNormal];
    [_takePhoto addTarget:self action:@selector(SelectOrChangephoto) forControlEvents:UIControlEventTouchUpInside];
    
    self.like = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-35, headerheight-30,30,30)];
    [_like setImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateNormal];
    
    
    [self.headerView addSubview:_share];
    [self.headerView addSubview:_like];
    [self.headerView addSubview:_takePhoto];
    
    //给对应按钮添加响应
    [_share addTarget:self action:@selector(beginShare) forControlEvents:UIControlEventTouchUpInside];
    
    
    //添加名称输入框视图
    self.foodNameView = [[UIView alloc]initWithFrame:CGRectMake(10, headerheight+20,headerWidth, 50)];
    _foodNameView.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _foodNameView.layer.cornerRadius = 5;
    _foodName.layer.borderColor = [[UIColor grayColor] CGColor];
    _foodName.font = [UIFont fontWithName:@"Arial" size:15.0f];
    [self.rootScrollview addSubview:_foodNameView];
    self.foodName = [[UITextField alloc]initWithFrame:CGRectMake(10, 5, headerWidth, 40)];
    _foodName.placeholder = @"输入食品名称";
    _foodName.delegate = self;
    _foodName.returnKeyType = UIReturnKeyDone;
    [self.foodNameView addSubview:_foodName];
    
    //食品描述框
    self.aboutFood = [[UITextField alloc]initWithFrame:CGRectMake(10, headerheight+80, headerWidth, 50)];
    _aboutFood.layer.borderWidth = 1.f;
    _aboutFood.layer.borderColor = [[UIColor grayColor] CGColor];
    _aboutFood.placeholder = @"您可以在这里输入一些说明!";
    _aboutFood.font = [UIFont fontWithName:@"Arial" size:15.0f];
    //_aboutFood.textAlignment = UITextAlignmentLeft;
    _aboutFood.delegate = self;
    _aboutFood.returnKeyType = UIReturnKeyDone;
    [self.rootScrollview addSubview:_aboutFood];

    //过期日期视图
    self.expireView = [[UIView alloc]initWithFrame:CGRectMake(10, headerheight+140,headerWidth, 50)];
    _expireView.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _expireView.layer.cornerRadius = 5;
    [self.rootScrollview addSubview:_expireView];
    
    self.expireDate = [[UITextView alloc]initWithFrame:CGRectMake(10, 5, headerWidth/2, 40)];
    _expireDate.textColor = [UIColor blackColor];
    _expireDate.text = @"Expire Date";
    _expireDate.backgroundColor = [UIColor clearColor];
    [self.expireView addSubview:_expireDate];
    self.expireBtn = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-45, 5, 40, 40)];
    [_expireBtn setImage:[UIImage imageNamed:@"icon_date"] forState:UIControlStateNormal];
    [self.expireView addSubview:_expireBtn];
    [_expireBtn addTarget:self action:@selector(ExpireDateSelect) forControlEvents:UIControlEventTouchUpInside];
    
    //提醒日期视图
    self.remindView = [[UIView alloc]initWithFrame:CGRectMake(10, headerheight+200,headerWidth, 50)];
    _remindView.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _remindView.layer.cornerRadius = 5;
    [self.rootScrollview addSubview:_remindView];
    
    self.remindDate = [[UITextView alloc]initWithFrame:CGRectMake(10, 5, headerWidth/2, 40)];
    _remindDate.textColor = [UIColor blackColor];
    _remindDate.text = @"Remind Date";
    _remindDate.backgroundColor = [UIColor clearColor];
    [self.remindView addSubview:_remindDate];
    
    self.remindBtn = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-45, 5, 40, 40)];
    [_remindBtn setImage:[UIImage imageNamed:@"icon_date"] forState:UIControlStateNormal];
    [self.remindView addSubview:_remindBtn];
    [_remindBtn addTarget:self action:@selector(RemindDateSelect) forControlEvents:UIControlEventTouchUpInside];
    
    //存储位置视图
    self.locationView = [[UIView alloc]initWithFrame:CGRectMake(10, headerheight+260,headerWidth, 50)];
    _locationView.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _locationView.layer.cornerRadius = 5;
    [self.rootScrollview addSubview:_locationView];
    self.location = [[UITextView alloc]initWithFrame:CGRectMake(10, 5, headerWidth/2, 40)];
    _location.text = @"Storage Location";
    _location.textColor =[UIColor blackColor];
    _location.backgroundColor = [UIColor clearColor];
    [self.locationView addSubview:_location];
    self.locationBtn = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-45, 5, 40, 40)];
    [_locationBtn setImage:[UIImage imageNamed:@"icon_location"] forState:UIControlStateNormal];
    [self.locationView addSubview:_locationBtn];
    
    //重量视图
    self.weightView = [[UIView alloc]initWithFrame:CGRectMake(10, headerheight+320, headerWidth/2-10, 50)];
    _weightView.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _weightView.layer.cornerRadius = 5;
    [self.rootScrollview addSubview:_weightView];
    
    self.weightBtn = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth/2-50, 5, 40, 40)];
    [_weightBtn setImage:[UIImage imageNamed:@"icon_weight"] forState:UIControlStateNormal];
    [self.weightView addSubview:_weightBtn];
    
    //卡路里视图
    self.calorieView = [[UIView alloc]initWithFrame:CGRectMake(headerWidth/2+20, headerheight+320, headerWidth/2-10,50)];
    _calorieView.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _calorieView.layer.cornerRadius = 5;
    [self.rootScrollview addSubview:_calorieView];
    
    self.calBtn = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth/2-50, 5, 40, 40)];
    //_calBtn.backgroundColor = [UIColor blackColor];
    [self.calBtn setImage:[UIImage imageNamed:@"icon_calorie"] forState:UIControlStateNormal];
    [self.calorieView addSubview:_calBtn];
    
    [self prohibitEdit];
}
-(void)prohibitEdit{
    self.foodName.userInteractionEnabled = NO;
    self.aboutFood.userInteractionEnabled = NO;
    self.expireBtn.userInteractionEnabled = NO;
    self.remindBtn.userInteractionEnabled = NO;
    self.location.userInteractionEnabled = NO;
    self.locationBtn.userInteractionEnabled = NO;
    self.expireDate.userInteractionEnabled = NO;
    self.remindDate.userInteractionEnabled = NO;
    self.weight.userInteractionEnabled = NO;
    self.calorie.userInteractionEnabled = NO;
}
-(void)AllowEdit{
    self.foodName.userInteractionEnabled = YES;
    self.aboutFood.userInteractionEnabled = YES;
    self.expireBtn.userInteractionEnabled = YES;
    self.remindBtn.userInteractionEnabled = YES;
    self.locationBtn.userInteractionEnabled = YES;
    self.weightBtn.userInteractionEnabled = YES;
    //self.calorie.userInteractionEnabled = YES;
}

-(void)ExpireDateSelect{
    NSLog(@"select expire date");
    isRemind = false;
    [self.view addSubview:dateView];
}
-(void)RemindDateSelect{
    isRemind = true;
    NSLog(@"select reminding date");
    [self.view addSubview:dateView];
}
-(void)selected{
    NSDate *selectdate = datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:selectdate];
    if(isRemind){
        self.remindDate.text = [NSString stringWithFormat:@"提醒日期为:%@",strDate];
        _redate = selectdate;
        remind_Date = strDate;
    }else{
        self.expireDate.text = [NSString stringWithFormat:@"有效日期到:%@",strDate];
        _exdate = selectdate;
        expire_Date = strDate;
    }
    [dateView removeFromSuperview];
}
-(void)noSelect{
    [dateView removeFromSuperview];
}
//分享
-(void)beginShare{
    NSLog(@"点击了分享");
    UIImage *sharephoto = [self getJPEGImagerImg:self.food_image];
    UIImage *sharephoto1 = [self getJPEGImagerImg:[UIImage imageNamed:@"启动图2"]];
    NSArray *activityItems = @[sharephoto,sharephoto1];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityVC animated:TRUE completion:nil];
}
//压缩图片
- (UIImage *)getJPEGImagerImg:(UIImage *)image{
 CGFloat oldImg_WID = image.size.width;
 CGFloat oldImg_HEI = image.size.height;
 //CGFloat aspectRatio = oldImg_WID/oldImg_HEI;//宽高比
 if(oldImg_WID > KCompressibilityFactor || oldImg_HEI > KCompressibilityFactor){
 //超过设置的最大宽度 先判断那个边最长
 if(oldImg_WID > oldImg_HEI){
  //宽度大于高度
  oldImg_HEI = (KCompressibilityFactor * oldImg_HEI)/oldImg_WID;
  oldImg_WID = KCompressibilityFactor;
 }else{
  oldImg_WID = (KCompressibilityFactor * oldImg_WID)/oldImg_HEI;
  oldImg_HEI = KCompressibilityFactor;
 }
 }
 UIImage *newImg = [self imageWithImage:image scaledToSize:CGSizeMake(oldImg_WID, oldImg_HEI)];
 NSData *dJpeg = nil;
 if (UIImagePNGRepresentation(newImg)==nil) {
 dJpeg = UIImageJPEGRepresentation(newImg, 0.5);
 }else{
 dJpeg = UIImagePNGRepresentation(newImg);
 }
 return [UIImage imageWithData:dJpeg];
}
#pragma mark - 根据宽高压缩图片
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
 UIGraphicsBeginImageContext(newSize);
 [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
 UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 return newImage;
}

//弹出系统提示
-(void)SystemAlert:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notification" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:true completion:nil];
}
-(void)SelectOrChangephoto{
    UIAlertController *alert  = [UIAlertController alertControllerWithTitle:@"设置图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *photoLibary = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"即将打开相册");
    }];
    UIAlertAction *Camera = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"打开相机");
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }];
    
    [alert addAction:photoLibary];
    [alert addAction:Camera];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}
-(void)openPhotoLibrary{
    
}

//数据库操作
//创建或打开数据库
-(void)creatOrOpensql
{
    NSString *path = [self getPath];
   // char *erro = 0;
    int sqlStatus = sqlite3_open_v2([path UTF8String], &_database,SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE,NULL);
    if (sqlStatus == SQLITE_OK) {
        NSLog(@"数据库打开成功");
    }
}
//判断表是否已经存在
-(BOOL)isTabelExist:(NSString *)name{
    char *err;
    NSString *sql = [NSString stringWithFormat:@"SELECT COUNT(*) FROM sqlite_master where type='table' and name='%@';",name];
    const char *sql_stmt = [sql UTF8String];
    if(sqlite3_exec(_database, sql_stmt, NULL, NULL, &err) == 1){
        return YES;
    }else{
        return NO;
    }
}
//更新数据
-(void) UpdateInfo{
    NSString *sql = [NSString stringWithFormat:@"UPDATE Fosa2 SET foodName = '%@',aboutFood = '%@',expireDate = '%@',remindDate = '%@'  WHERE deviceName = '%@'",self.foodName.text,self.aboutFood.text,self.expireDate.text,self.remindDate.text,self.deviceID];
    const char *updateSql = [sql UTF8String];
    int updateResult = sqlite3_exec(_database,updateSql,NULL,NULL,NULL);
    if (updateResult != SQLITE_OK) {
        [self SystemAlert:@"保存内容失败"];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void) SelectDataFromSqlite{
    //查询数据库里对应食物的详细信息
    NSString *sql = [NSString stringWithFormat:@"select foodName,deviceName,aboutFood,expireDate,remindDate,photoPath from Fosa2 where deviceName = '%@'",self.deviceID];
    const char *selsql = [sql UTF8String];
    int selresult = sqlite3_prepare_v2(self.database, selsql, -1,&_stmt, NULL);
    if(selresult != SQLITE_OK){
        NSLog(@"查询失败");
    }else{
        while (sqlite3_step(_stmt) == SQLITE_ROW) {
            const char *food_name   = (const char*)sqlite3_column_text(_stmt, 0);
            NSLog(@"查询到数据:%@",[NSString stringWithUTF8String:food_name]);
            self.foodName.text = [NSString stringWithUTF8String:food_name];
            const char *device_name = (const char*)sqlite3_column_text(_stmt,1);
            NSLog(@"查询到数据:%@",[NSString stringWithUTF8String:device_name]);
            self.deviceName.text = self.deviceID;
            const char *about_food  = (const char*)sqlite3_column_text(_stmt,2);
            NSLog(@"查询到数据:%@",[NSString stringWithUTF8String:about_food]);
            self.aboutFood.text = [NSString stringWithUTF8String:about_food];
            const char *expire_date = (const char*)sqlite3_column_text(_stmt,3);
            NSLog(@"查询到数据:%@",[NSString stringWithUTF8String:expire_date]);
            self.expireDate.text = [NSString stringWithUTF8String:expire_date];
            const char *remind_date = (const char*)sqlite3_column_text(_stmt,4);
            NSLog(@"查询到数据:%@",[NSString stringWithUTF8String:remind_date]);
            self.remindDate.text = [NSString stringWithUTF8String:remind_date];
            const char *photopath = (const char*)sqlite3_column_text(_stmt,5);
            self.imageView1.image = [self getImage:[NSString stringWithUTF8String:photopath]];
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
//完成输入，将数据写入数据库
-(void)BeginEditing{
    
    if (_CanEdit) {
        _CanEdit = false;
        [self UpdateInfo];
//        [self creatOrOpensql];
//        [self InsertDataIntoSqlite];
//        [self.navigationController popToRootViewControllerAnimated:YES];
//
//        [self initNotification];
//        //格式化时间
//        NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
//        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//        NSDate *Edate = [formatter dateFromString:[NSString stringWithFormat:@"%@ 14:00:00",expire_Date]];
//        NSDate *Rdate = [formatter dateFromString:[NSString stringWithFormat:@"%@ 13:30:00",remind_Date]];
//        [self sendNotification:Edate idertifier:@"EXPIRE" body:@"Your food have expired"];
//        [self sendNotification:Rdate idertifier:@"REMIND" body:[NSString stringWithFormat:@"Your food will expire on %@",expire_Date]];
    }else{
        [self AllowEdit];
        _CanEdit = true;
    }
}
//保存照片到沙盒
//-(NSString *)Savephoto:(UIImage *)image{
//    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *photoName = [NSString stringWithFormat:@"%@.png",self.foodName.text];
//    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent: photoName];// 保存文件的路径
//    NSLog(@"这个是照片的保存地址:%@",filePath);
//    BOOL result =[UIImagePNGRepresentation(image) writeToFile:filePath  atomically:YES];// 保存成功会返回YES
//    if(result == YES) {
//        NSLog(@"保存成功");
//    }
//    return filePath;
//}
//取出保存在本地的图片
-(UIImage*)getImage:(NSString *)filepath{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photopath = [NSString stringWithFormat:@"%@.png",filepath];
    NSString *imagePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",photopath]];
    // 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    NSLog(@"=== %@", img);
    return img;
}

//初始化和注册通知
-(void)initNotification{
    // 必须写代理，不然无法监听通知的接收与点击
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate = self;
    
    //设置预设好的交互类型，NSSet里面是设置好的UNNotificationCategory
    [center setNotificationCategories:[self createNotificationCategoryActions]];
    
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
    if (settings.authorizationStatus==UNAuthorizationStatusNotDetermined){
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert|UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error){
                if (granted) {
                    } else {
                    }
                }];
            }
        else{
           //do other things
        }
    }];
    //移除一条通知
   // [center removePendingNotificationRequestsWithIdentifiers:@[@"time interval request"]];
}

//代理回调方法，通知即将展示的时候
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"即将展示通知");
//   UNNotificationRequest *request = notification.request; // 原始请求
//    NSDictionary * userInfo = notification.request.content.userInfo;//userInfo数据
//    UNNotificationContent *content = request.content; // 原始内容
//    NSString *title = content.title;  // 标题
//    NSString *subtitle = content.subtitle;  // 副标题
//    NSNumber *badge = content.badge;  // 角标
//    NSString *body = content.body;    // 推送消息体
//    UNNotificationSound *sound = content.sound;  // 指定的声音
//建议将根据Notification进行处理的逻辑统一封装，后期可在Extension中复用~
completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 回调block，将设置传入
}
//用户与通知进行交互后的response，比如说用户直接点开通知打开App、用户点击通知的按钮或者进行输入文本框的文本
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
//在此，可判断response的种类和request的触发器是什么，可根据远程通知和本地通知分别处理，再根据action进行后续回调
    if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {
        UNTextInputNotificationResponse * textResponse = (UNTextInputNotificationResponse*)response;
        NSString * text = textResponse.userText;
        NSLog(@"%@",text);
    }
    else{
        if ([response.actionIdentifier isEqualToString:@"see1"]){
            NSLog(@"I love it!!");
            ScanViewController *scan = [[ScanViewController alloc]init];
            scan.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:scan animated:NO];
        }
        if ([response.actionIdentifier isEqualToString:@"see2"]) {
            //I don't care~
            NSLog(@"I don't like it");
            [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[response.notification.request.identifier]];
        }
    }
    completionHandler();
//
//    UNNotificationRequest *request = response.notification.request; // 原始请求
////NSDictionary * userInfo = notification.request.content.userInfo;//userInfo数据
//    UNNotificationContent *content = request.content; // 原始内容
//    NSString *title = content.title;  // 标题
//    NSString *subtitle = content.subtitle;  // 副标题
//    NSNumber *badge = content.badge;  // 角标
//    NSString *body = content.body;    // 推送消息体
//    UNNotificationSound *sound = content.sound;
//在此，可判断response的种类和request的触发器是什么，可根据远程通知和本地通知分别处理，再根据action进行后续回调
}
-(void)sendNotification:(NSDate *)date idertifier:(NSString *)RequestIdentifier body:(NSString *)body{
        
       UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    
        content.title = @"Notification By Fosa";
        //content.subtitle = @"by Fosa";
        content.body = body;
        content.badge = @0;
//        if (self.food_image != NULL) {
//        //保存图片到沙盒
//            NSString *path = [self Savephoto:self.food_image];
//            NSError *error = nil;
//            //将本地图片的路径形成一个图片附件，加入到content中
//            UNNotificationAttachment *img_attachment = [UNNotificationAttachment attachmentWithIdentifier:@"att1" URL:[NSURL fileURLWithPath:path] options:nil error:&error];
//            if (error) {
//                NSLog(@"%@", error);
//            }
//            content.attachments = @[img_attachment];
//        }
//           NSString *path = [[NSBundle mainBundle] pathForResource:@"启动图2" ofType:@"png"];
           //设置为@""以后，进入app将没有启动页
           content.launchImageName = @"";
           UNNotificationSound *sound = [UNNotificationSound defaultSound];
           content.sound = sound;
           //设置时间间隔的触发器
            //格式化时间
//          NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
//          [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//          NSDate * date = [formatter dateFromString:@"2019-10-29 9:46:00"];
          NSDateComponents * components = [[NSCalendar currentCalendar]
                                             components:NSCalendarUnitYear |
                                             NSCalendarUnitMonth |
                                             NSCalendarUnitWeekday |
                                             NSCalendarUnitDay |
                                             NSCalendarUnitHour |
                                             NSCalendarUnitMinute |
                                             NSCalendarUnitSecond
                                             fromDate:date];
    
            //UNTimeIntervalNotificationTrigger *time_trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    UNCalendarNotificationTrigger *date_trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
           NSString *requestIdentifer = RequestIdentifier;
           //content.categoryIdentifier = @"seeCategory";
           content.categoryIdentifier = @"seeCategory";
           UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifer content:content trigger:date_trigger];
    
           [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
               NSLog(@"%@",error);
           }];
}
-(NSSet *)createNotificationCategoryActions{
    //定义按钮的交互button action
    UNNotificationAction * likeButton = [UNNotificationAction actionWithIdentifier:@"see1" title:@"I love it~" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive|UNNotificationActionOptionForeground];
    UNNotificationAction * dislikeButton = [UNNotificationAction actionWithIdentifier:@"see2" title:@"I don't care~" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive|UNNotificationActionOptionForeground];
    //定义文本框的action
    UNTextInputNotificationAction * text = [UNTextInputNotificationAction actionWithIdentifier:@"text" title:@"How about it~?" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive|UNNotificationActionOptionForeground];
    //将这些action带入category
    UNNotificationCategory * choseCategory = [UNNotificationCategory categoryWithIdentifier:@"seeCategory" actions:@[likeButton,dislikeButton] intentIdentifiers:@[@"see1",@"see2"] options:UNNotificationCategoryOptionNone];
    UNNotificationCategory * comment = [UNNotificationCategory categoryWithIdentifier:@"seeCategory1" actions:@[text] intentIdentifiers:@[@"text"] options:UNNotificationCategoryOptionNone];
    return [NSSet setWithObjects:choseCategory,comment,nil];
}

//UITextField判断是否可编辑
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (_CanEdit) {
        return YES;
    }else{
        return NO;
    }
}
//UITextView是否可编辑
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return NO;
}

//退出键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.aboutFood resignFirstResponder];
    [self.foodName resignFirstResponder];
    return YES;
}
-(void)keyboardWillShow:(NSNotification *)noti{
    NSLog(@"键盘弹出来了");
    //键盘输入的界面调整
    NSDictionary *userInfo = [noti userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect newFrame = self.view.frame;
    newFrame.size.height -= keyboardRect.size.height;
    [UIView beginAnimations:@"ResizetextView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.rootScrollview.frame = newFrame;
    [UIView commitAnimations];
}

-(void)keyboardWillHide:(NSNotification *)noti{
    
    NSLog(@"键盘被收起来了");
    NSDictionary *userInfo = [noti userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval animationDuration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect newFrame = self.view.frame;
    newFrame.size.height += keyboardRect.size.height;
    [UIView beginAnimations:@"ResizetextView" context:nil];
    [UIView setAnimationDuration:animationDuration];
    self.rootScrollview.frame = newFrame;
    [UIView commitAnimations];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
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
