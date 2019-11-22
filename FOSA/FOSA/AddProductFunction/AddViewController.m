//
//  AddViewController.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "AddViewController.h"
#import "ScanOneCodeViewController.h"
#import "PhotoViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <sqlite3.h>

//图片宽高的最大值
#define KCompressibilityFactor 1280.00

@interface AddViewController ()<UITextFieldDelegate,UNUserNotificationCenterDelegate>{
    //日期选择
    UIDatePicker *datePicker;
    //日期选择器的容器
    UIView *dateView;
    UIButton *sure,*cancel;
    NSString *picturePath;
    //选择的日期
    NSString *expire_Date,*remind_Date;
    
    //区分是属于提醒日期还是过期日期
    Boolean isRemind;
   
   }
@property(nonatomic,assign) NSString *storagePath;;
@property(nonatomic,assign)sqlite3 *database;
//结果集定义
@property(nonatomic,assign)sqlite3_stmt *stmt;

//记录所选择的日期
@property (nonatomic,assign) NSDate *exdate,*redate;
@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
    [self InitialDatePicker];
    [self CreatAndInitView];
    
}
-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
   [self.aboutFood resignFirstResponder];
   [self.foodName resignFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //添加键盘弹出与收回的事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    

}
#pragma mark - 初始化日期选择器
-(void)InitialDatePicker{
    
    dateView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height*2/3-50,self.view.frame.size.width,self.view.frame.size.height/3+50)];
    dateView.backgroundColor = [UIColor whiteColor];
    
    sure = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width/2, 50)];
    cancel = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, self.view.frame.size.width/2, 50)];
    [sure setTitle:@"确定" forState:UIControlStateNormal];
    [sure setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    [cancel setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    sure.backgroundColor = [UIColor colorWithRed:200/255 green:200/255 blue:200/255 alpha:1.0];
//    cancel.backgroundColor = [UIColor colorWithRed:190/255 green:190/255 blue:190/255 alpha:1.0];
    [dateView addSubview:sure];
    [dateView addSubview:cancel];
    
    //添加响应
    [sure addTarget:self action:@selector(selected) forControlEvents:UIControlEventTouchUpInside];
    [cancel addTarget:self action:@selector(noSelect) forControlEvents:UIControlEventTouchUpInside];
    
    //初始化日期选择器
    datePicker = [[UIDatePicker alloc]initWithFrame: CGRectMake(0, 50, self.view.frame.size.width, self.view.frame.size.height/3)];
    
    datePicker.backgroundColor = [UIColor grayColor];
    
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
#pragma mark - 创建并初始化界面
-(void)CreatAndInitView{
    
   self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_done"] style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem.target = self;     self.navigationItem.rightBarButtonItem.action = @selector(finish);
    
    self.mainWidth = [UIScreen mainScreen].bounds.size.width;
    self.mainheight = [UIScreen mainScreen].bounds.size.height;
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    
    //底部滚动视图
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
    [self.headerView addSubview:_imageView1];   //添加图片视图
    [self.headerView addSubview:_deviceName];
    
    self.share = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-35,5,30,30)];
    [_share setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    self.like = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-35, headerheight-30,30,30)];
    [_like setImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateNormal];
    
    [self.headerView addSubview:_share];
    [self.headerView addSubview:_like];
    
    //给对应按钮添加响应
    [_share addTarget:self action:@selector(beginShare) forControlEvents:UIControlEventTouchUpInside];
    
    //添加名称输入框视图
    self.foodNameView = [[UIView alloc]initWithFrame:CGRectMake(10, headerheight+20,headerWidth, 50)];
    _foodNameView.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _foodNameView.layer.cornerRadius = 5;
    [self.rootScrollview addSubview:_foodNameView];
    
    UILabel *foodlabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 90, 40)];
    foodlabel.text = @"Food name:";
    foodlabel.font = [UIFont systemFontOfSize:13];
    [self.foodNameView addSubview:foodlabel];
    
    self.foodName = [[UITextField alloc]initWithFrame:CGRectMake(95, 5, headerWidth-95, 40)];
    _foodName.layer.borderColor = [[UIColor grayColor] CGColor];
    _foodName.font = [UIFont fontWithName:@"Arial" size:15.0f];
    _foodName.textColor = [UIColor blackColor];
    _foodName.placeholder = @"输入食品名称";
    _foodName.delegate = self;
    _foodName.returnKeyType = UIReturnKeyDone;
    [self.foodNameView addSubview:_foodName];
    
    //食品描述框
    self.aboutFoodView = [[UIView alloc]initWithFrame:CGRectMake(10, headerheight+80, headerWidth, 50)];
    [self.rootScrollview addSubview:self.aboutFoodView];
    _aboutFoodView .backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _aboutFoodView .layer.cornerRadius = 5;
    
    self.aboutFood = [[UITextField alloc]initWithFrame:CGRectMake(95, 0, headerWidth-95, 50)];
    _aboutFood.layer.borderColor = [[UIColor grayColor] CGColor];
    _aboutFood.placeholder = @"您可以在这里输入一些说明!";
    self.aboutFood.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _aboutFood.font = [UIFont fontWithName:@"Arial" size:15.0f];
    _aboutFood.textColor = [UIColor blackColor];
    _aboutFood.delegate = self;
    _aboutFood.returnKeyType = UIReturnKeyDone;
    
    UILabel *aboutfoodlabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 90, 40)];
    aboutfoodlabel.text = @"About Food:";
    aboutfoodlabel.font = [UIFont systemFontOfSize:13];
    [self.aboutFoodView addSubview:aboutfoodlabel];
    [self.aboutFoodView addSubview:_aboutFood];
    
    //提醒日期视图
    self.remindView = [[UIView alloc]initWithFrame:CGRectMake(10, headerheight+140,headerWidth, 50)];
    _remindView.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _remindView.layer.cornerRadius = 5;
    [self.rootScrollview addSubview:_remindView];
    
    self.remindDate = [[UITextView alloc]initWithFrame:CGRectMake(95, 5, headerWidth/2, 40)];
    _remindDate.textColor = [UIColor blackColor];
    _remindDate.backgroundColor = [UIColor clearColor];
    _remindDate.userInteractionEnabled = NO;
    [self.remindView addSubview:_remindDate];
    
    UILabel *remindLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 90, 40)];
    remindLabel.text = @"Remind Date:";
    remindLabel.font = [UIFont systemFontOfSize:13];
    [self.remindView addSubview:remindLabel];
    
    self.remindBtn = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-45, 5, 40, 40)];
    [_remindBtn setImage:[UIImage imageNamed:@"icon_date"] forState:UIControlStateNormal];
    [self.remindView addSubview:_remindBtn];
    [_remindBtn addTarget:self action:@selector(RemindDateSelect) forControlEvents:UIControlEventTouchUpInside];
    
    //过期日期视图
    self.expireView = [[UIView alloc]initWithFrame:CGRectMake(10, headerheight+200,headerWidth, 50)];
    _expireView.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _expireView.layer.cornerRadius = 5;
    [self.rootScrollview addSubview:_expireView];
    
    self.expireDate = [[UITextView alloc]initWithFrame:CGRectMake(95, 5, headerWidth/2, 40)];
    _expireDate.textColor = [UIColor blackColor];
    _expireDate.backgroundColor = [UIColor clearColor];
    _expireDate.userInteractionEnabled = NO;
    [self.expireView addSubview:_expireDate];
    
    UILabel *expireLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 90, 40)];
    expireLabel.text = @"Expire Date:";
    expireLabel.font = [UIFont systemFontOfSize:13];
    [self.expireView addSubview:expireLabel];
    
    self.expireBtn = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-45, 5, 40, 40)];
    [_expireBtn setImage:[UIImage imageNamed:@"icon_date"] forState:UIControlStateNormal];
    [self.expireView addSubview:_expireBtn];
    [_expireBtn addTarget:self action:@selector(ExpireDateSelect) forControlEvents:UIControlEventTouchUpInside];

    //存储位置视图
    self.locationView = [[UIView alloc]initWithFrame:CGRectMake(10, headerheight+260,headerWidth, 50)];
    _locationView.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _locationView.layer.cornerRadius = 5;
    [self.rootScrollview addSubview:_locationView];
    
    UILabel *locationLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 90, 40)];
    locationLabel.text = @"Location:";
    locationLabel.font = [UIFont systemFontOfSize:13];
    [self.locationView addSubview:locationLabel];
    
    self.location = [[UITextView alloc]initWithFrame:CGRectMake(45, 5, headerWidth/2, 40)];
//    _location.text = @"Storage Location";
    _location.textColor =[UIColor blackColor];
    _location.backgroundColor = [UIColor clearColor];
    _location.userInteractionEnabled = NO;
    
    [self.locationView addSubview:_location];
    self.locationBtn = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-45, 5, 40, 40)];
    [_locationBtn setImage:[UIImage imageNamed:@"icon_location"] forState:UIControlStateNormal];
    [self.locationView addSubview:_locationBtn];
    
    //重量视图
    self.weightView = [[UIView alloc]initWithFrame:CGRectMake(10, headerheight+320, headerWidth/2-10, 50)];
    _weightView.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _weightView.layer.cornerRadius = 5;
    [self.rootScrollview addSubview:_weightView];
    
    UILabel *weightLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 90, 40)];
    weightLabel.text = @"Weight";
    weightLabel.font = [UIFont systemFontOfSize:13];
    [self.weightView addSubview:weightLabel];
    
    self.weightBtn = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth/2-50, 5, 40, 40)];
    [_weightBtn setImage:[UIImage imageNamed:@"icon_weight"] forState:UIControlStateNormal];
    [self.weightView addSubview:_weightBtn];
    
    //卡路里视图
    self.calorieView = [[UIView alloc]initWithFrame:CGRectMake(headerWidth/2+20, headerheight+320, headerWidth/2-10,50)];
    _calorieView.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _calorieView.layer.cornerRadius = 5;
    [self.rootScrollview addSubview:_calorieView];
    
    UILabel *calorieLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 90, 40)];
       calorieLabel.text = @"Calorie";
       calorieLabel.font = [UIFont systemFontOfSize:13];
       [self.calorieView addSubview:calorieLabel];
    
    self.calBtn = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth/2-50, 5, 40, 40)];
    //_calBtn.backgroundColor = [UIColor blackColor];
    [self.calBtn setImage:[UIImage imageNamed:@"icon_calorie"] forState:UIControlStateNormal];
    [self.calorieView addSubview:_calBtn];
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
#pragma mark - 选择日期
-(void)selected{
    NSDate *selectdate = datePicker.date;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:selectdate];
    if(isRemind){
        self.remindDate.text = strDate;
        _redate = selectdate;
        remind_Date = strDate;
        NSLog(@"%@",remind_Date);
    }else{
        self.expireDate.text = strDate;
        _exdate = selectdate;
        expire_Date = strDate;
        NSLog(@"%@",expire_Date);
    }
    [dateView removeFromSuperview];
}
-(void)noSelect{
    [dateView removeFromSuperview];
}

#pragma mark - 分享
-(void)beginShare{
    NSLog(@"点击了分享");
    //UIImage *sharephoto = [self getJPEGImagerImg:self.food_image];
    UIImage *sharephoto1 = [self getJPEGImagerImg:[UIImage imageNamed:@"启动图2"]];
    NSArray *activityItems = @[sharephoto1];
    UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
    [self presentViewController:activityVC animated:TRUE completion:nil];
}
#pragma mark - 压缩图片
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
#pragma mark - 数据库操作
//创建或打开数据库
-(void)creatOrOpensql
{
    NSString *path = [self getPath];
    char *erro = 0;
    int sqlStatus = sqlite3_open_v2([path UTF8String], &_database,SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE,NULL);
    if (sqlStatus == SQLITE_OK) {
        NSLog(@"数据库打开成功");
    }
    //创建数据库表 Fosa2(编号，食品名称，设备名称，描述，过期日期，提醒日期，重量，卡路里，地点)
    const char *sql = "create table if not exists Fosa2(id integer primary key,foodName text,deviceName text,aboutFood text,expireDate text,remindDate text,photoPath text)";
    int tabelStatus = sqlite3_exec(self.database, sql,NULL, NULL, &erro);//运行结果
    if (tabelStatus == SQLITE_OK)
    {
        NSLog(@"表创建成功");
    }
    //数据库操作
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
-(void) InsertDataIntoSqlite:(NSString *)ExpireDate remind:(NSString *)remindDate{
    
    //错误信息定义
    char *erro = 0;
    if(self.foodName.text != nil){
    //插入语句
    NSString *insertSql =[NSString stringWithFormat:@"insert into Fosa2(foodName,deviceName,aboutFood,expireDate,remindDate,photoPath)values('%@','%@','%@','%@','%@','%@')",_foodName.text,_deviceName.text,_aboutFood.text,self.expireDate.text,self.remindDate.text,self.foodName.text];
        int insertResult = sqlite3_exec(self.database, insertSql.UTF8String,NULL, NULL,&erro);
        if(insertResult == SQLITE_OK){
            NSLog(@"添加数据成功");
        }else{
            NSLog(@"插入数据失败");
        }
    }else{
        
    }
    //查询数据库新添加的食物
    const char *selsql = "select foodName,deviceName,aboutFood,expireDate,remindDate,photoPath from Fosa2";
    int selresult = sqlite3_prepare_v2(self.database, selsql, -1,&_stmt, NULL);
    if(selresult != SQLITE_OK){
        NSLog(@"查询失败");
    }else{
        while (sqlite3_step(_stmt) == SQLITE_ROW) {
            const char *food_name   = (const char*)sqlite3_column_text(_stmt, 5);
            NSLog(@"查询到数据:%@",[NSString stringWithUTF8String:food_name]);
//            const char *device_name = (const char*)sqlite3_column_text(_stmt,1);
//            NSLog(@"查询到数据:%@",[NSString stringWithUTF8String:device_name]);
//            const char *about_food  = (const char*)sqlite3_column_text(_stmt,2);
//            NSLog(@"查询到数据:%@",[NSString stringWithUTF8String:about_food]);
//            const char *expire_date = (const char*)sqlite3_column_text(_stmt,3);
//            NSLog(@"查询到数据:%@",[NSString stringWithUTF8String:expire_date]);
//            const char *remind_date = (const char*)sqlite3_column_text(_stmt,4);
//            NSLog(@"查询到数据:%@",[NSString stringWithUTF8String:remind_date]);
        }
    }
}

#pragma mark - 获取DB数据库所在的document路径
-(NSString *)getPath
{
    NSString *filename = @"Fosa.db";
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [doc stringByAppendingPathComponent:filename];
    NSLog(@"%@",filePath);
    return filePath;
}
#pragma mark - 完成输入，将数据写入数据库
-(void)finish{
    [self creatOrOpensql];
    [self InsertDataIntoSqlite:expire_Date remind:remind_Date];
    
    //[self SavePhotoIntoLibrary:self.imageView1.image];
    picturePath = [self Savephoto:[self fixOrientation:self.imageView1.image]];
    //格式化时间
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *Edate = [formatter dateFromString:[NSString stringWithFormat:@"%@ 14:00:00",expire_Date]];
    NSLog(@"%@",[formatter stringFromDate:Edate]);
    NSDate *Rdate = [formatter dateFromString:[NSString stringWithFormat:@"%@ 13:30:00",remind_Date]];
    NSLog(@"%@",[formatter stringFromDate:Rdate]);
    //[self sendNotification:Edate idertifier:@"EXPIRE" body:@"Your food have expired"];
    //[self sendNotification:Rdate idertifier:@"REMIND" body:[NSString stringWithFormat:@"Your food will expire on %@",expire_Date]];
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 保存照片到相册
- (void)SavePhotoIntoLibrary:(UIImage *)image{
    UIImageWriteToSavedPhotosAlbum(image, self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
}
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if(error){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
        //将保存在相册的图片再存到沙盒中
        [self Savephoto:image];
    }
}
#pragma mark - 保存照片到沙盒
-(NSString *)Savephoto:(UIImage *)image{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photoName = [NSString stringWithFormat:@"%@.png",self.foodName.text];
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent: photoName];// 保存文件的路径
    NSLog(@"这个是照片的保存地址:%@",filePath);
    BOOL result =[UIImagePNGRepresentation(image) writeToFile:filePath  atomically:YES];// 保存成功会返回YES
    if(result == YES) {
        NSLog(@"保存成功");
    }
    return filePath;
}

- (UIImage *)normalizedImage:(UIImage *)img {
    if (img.imageOrientation == UIImageOrientationUp) return img;

    UIGraphicsBeginImageContextWithOptions(img.size, NO, img.scale);
    [img drawInRect:(CGRect){0, 0, img.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}
- (UIImage *)fixOrientation:(UIImage *)aImage {
// No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
     switch (aImage.imageOrientation) {
         case UIImageOrientationDown:
         case UIImageOrientationDownMirrored:
             transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
             transform = CGAffineTransformRotate(transform, M_PI);
             break;
         case UIImageOrientationLeft:
         case UIImageOrientationLeftMirrored:
             transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
             transform = CGAffineTransformRotate(transform, M_PI_2);
             break;
         case UIImageOrientationRight:
         case UIImageOrientationRightMirrored:
             transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
             transform = CGAffineTransformRotate(transform, -M_PI_2);
             break;
         default:
             break;
     }
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
     CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,CGImageGetBitsPerComponent(aImage.CGImage), 0,CGImageGetColorSpace(aImage.CGImage),CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
// And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}


//取出保存在本地的图片
//-(UIImage*)getImage{
//    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString*filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"demo.png"]];
//// 保存文件的名称
//    UIImage *img = [UIImage imageWithContentsOfFile:filePath];
//    NSLog(@"=== %@", img);
//    return img;
//}
#pragma mark - 退出键盘
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
