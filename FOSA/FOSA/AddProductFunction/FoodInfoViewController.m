//
//  FoodInfoViewController.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FoodInfoViewController.h"
#import "PhotoViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <sqlite3.h>
//图片宽高的最大值
#define KCompressibilityFactor 1280.00

@interface FoodInfoViewController ()<UITextFieldDelegate,UINavigationControllerDelegate,UNUserNotificationCenterDelegate,UITextViewDelegate,UIImagePickerControllerDelegate>{
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
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
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
#pragma mark - 创建并初始化界面
-(void)CreatAndInitView{
    _CanEdit = false;
    self.edit = [[UIButton alloc]initWithFrame:CGRectMake(0,0,40,40)];
    [self.edit setImage:[UIImage imageNamed:@"icon_edit"] forState:UIControlStateNormal];
    [self.edit addTarget:self action:@selector(BeginEditing) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.edit];
    self.navigationItem.rightBarButtonItem= rightItem;

    
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
    self.imageView1.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView1.clipsToBounds = YES;
    self.deviceName = [[UITextView alloc]initWithFrame:CGRectMake(0, 0,headerWidth/2, headerheight/4-5)];
    self.deviceName.backgroundColor = [UIColor clearColor];
    [self.headerView addSubview:_imageView1];   //添加图片视图
    [self.headerView addSubview:_deviceName];
    
    self.share = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-35,5,30,30)];
    [_share setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    
    self.takePhoto = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-45,40, 40, 40)];
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
    
    UILabel *remindLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 90, 40)];
    remindLabel.text = @"Remind Date:";
    remindLabel.font = [UIFont systemFontOfSize:13];
    [self.remindView addSubview:remindLabel];
    
    self.remindDate = [[UITextView alloc]initWithFrame:CGRectMake(95, 5, headerWidth/2, 40)];
    _remindDate.textColor = [UIColor blackColor];
    _remindDate.backgroundColor = [UIColor clearColor];
    [self.remindView addSubview:_remindDate];
    
    self.remindBtn = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-45, 5, 40, 40)];
    [_remindBtn setImage:[UIImage imageNamed:@"icon_date"] forState:UIControlStateNormal];
    [self.remindView addSubview:_remindBtn];
    [_remindBtn addTarget:self action:@selector(RemindDateSelect) forControlEvents:UIControlEventTouchUpInside];
    
    //过期日期视图
    self.expireView = [[UIView alloc]initWithFrame:CGRectMake(10, headerheight+200,headerWidth, 50)];
    _expireView.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _expireView.layer.cornerRadius = 5;
    [self.rootScrollview addSubview:_expireView];
    
    UILabel *expireLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 90, 40)];
    expireLabel.text = @"Expire Date:";
    expireLabel.font = [UIFont systemFontOfSize:13];
    [self.expireView addSubview:expireLabel];
    
    self.expireDate = [[UITextView alloc]initWithFrame:CGRectMake(95, 5, headerWidth/2, 40)];
    _expireDate.textColor = [UIColor blackColor];
    _expireDate.backgroundColor = [UIColor clearColor];
    [self.expireView addSubview:_expireDate];
    self.expireBtn = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-45, 5, 40, 40)];
    [_expireBtn setImage:[UIImage imageNamed:@"icon_date"] forState:UIControlStateNormal];
    [self.expireView addSubview:_expireBtn];
    [_expireBtn addTarget:self action:@selector(ExpireDateSelect) forControlEvents:UIControlEventTouchUpInside];
    
    //存储位置视图
    self.locationView = [[UIView alloc]initWithFrame:CGRectMake(10, headerheight+260,headerWidth, 50)];
    _locationView.backgroundColor = [UIColor colorWithRed:180/255.0 green:180/255.0 blue:180/255.0 alpha:1.0];
    _locationView.layer.cornerRadius = 5;
    [self.rootScrollview addSubview:_locationView];
    
    UILabel *LocationLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, 120, 40)];
    LocationLabel.text = @"Storage Location:";
    LocationLabel.font = [UIFont systemFontOfSize:13];
    [self.locationView addSubview:LocationLabel];
    
    
    self.location = [[UITextView alloc]initWithFrame:CGRectMake(125, 5, headerWidth/2, 40)];
   // _location.text = @"Storage Location";
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
    
    [self prohibitEdit];
}
#pragma mark - 禁止视图与外界交互
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
    self.takePhoto.userInteractionEnabled = NO;
}
-(void)AllowEdit{
    self.foodName.userInteractionEnabled = YES;
    self.aboutFood.userInteractionEnabled = YES;
    self.expireBtn.userInteractionEnabled = YES;
    self.remindBtn.userInteractionEnabled = YES;
    self.locationBtn.userInteractionEnabled = YES;
    self.weightBtn.userInteractionEnabled = YES;
    self.takePhoto.userInteractionEnabled = YES;
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
        self.remindDate.text = strDate;
        _redate = selectdate;
        remind_Date = strDate;
    }else{
        self.expireDate.text = strDate;
        _exdate = selectdate;
        expire_Date = strDate;
    }
    [dateView removeFromSuperview];
}
-(void)noSelect{
    [dateView removeFromSuperview];
}
#pragma mark - 分享
-(void)beginShare{
    NSLog(@"点击了分享");
    UIImage *sharephoto = [self getJPEGImagerImg:self.food_image];
    UIImage *sharephoto1 = [self getJPEGImagerImg:[UIImage imageNamed:@"启动图2"]];
    NSArray *activityItems = @[sharephoto,sharephoto1];
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

#pragma mark - 系统提示
-(void)SystemAlert:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notification" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:true completion:nil];
}


-(void)SelectOrChangephoto{
     [_takePhoto setImage:[UIImage imageNamed:@"icon_takePictureHL"] forState:UIControlStateNormal];
    UIAlertController *alert  = [UIAlertController alertControllerWithTitle:@"设置图片" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *photoLibary = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"即将打开相册");
        [self openPhotoLibrary];
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

#pragma mark - 切换图片的相关方法
-(void)openPhotoLibrary{
    NSLog(@"打开相册");
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //UIImagePickerControllerSourceTypeSavedPhotosAlbum
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
}
-(void)openCamera{
    NSLog(@"打开相机");
    
}
/// 返回一张不超过屏幕尺寸的 image
+ (UIImage *)LY_imageSizeWithScreenImage:(UIImage *)image {
    CGFloat imageWidth = image.size.width;
    CGFloat imageHeight = image.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if (imageWidth <= screenWidth && imageHeight <= screenHeight) {
        return image;
    }
    CGFloat max = MAX(imageWidth, imageHeight);
    CGFloat scale = max / (screenHeight * 2.0);
    
    CGSize size = CGSizeMake(imageWidth / scale, imageHeight / scale);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - 相册回调方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // 对选取照片的处理，如果选取的图片尺寸过大，则压缩选取图片，否则不作处理
    UIImage *image = [FoodInfoViewController LY_imageSizeWithScreenImage:info[UIImagePickerControllerOriginalImage]];
    // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
    //UIImage *image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
    self.imageView1.image = image;
    //self.imageView1.transform = CGAffineTransformMakeRotation(-M_PI/2);
}
#pragma mark - 保存照片到沙盒
-(void)Savephoto{
    //如果用户更换了图片，则删除之前保存的同名图片,若没有则不做任何操作
    if ([self.food_image isEqual: self.imageView1.image]&&[self.name isEqual:self.foodName.text]) {
        NSLog(@"图片没有更换");
    }else{
        NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
        NSString *photoName = [NSString stringWithFormat:@"%@.png",self.foodName.text];
        NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent: photoName];// 保存文件的路径
        [self deleteFile:filePath];
        NSLog(@"这个是照片的保存地址:%@",filePath);
        BOOL result =[UIImagePNGRepresentation(self.imageView1.image) writeToFile:filePath  atomically:YES];// 保存成功会返回YES
        if(result == YES) {
            NSLog(@"保存成功");
        }
    }
}
-(void)deleteFile:(NSString *)path {
NSFileManager* fileManager=[NSFileManager defaultManager];
BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:path];
if (!blHave) {
NSLog(@"no  have");
}else {
NSLog(@" have");
BOOL blDele= [fileManager removeItemAtPath:path error:nil];
if (blDele) {
NSLog(@"dele success");
}else {
NSLog(@"dele fail");
}
}
}
//数据库操作
#pragma mark - 创建或打开数据库
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
#pragma mark - 更新数据
-(void) UpdateInfo{
    NSString *sql = [NSString stringWithFormat:@"UPDATE Fosa2 SET foodName = '%@',aboutFood = '%@',expireDate = '%@',remindDate = '%@',photoPath = '%@'  WHERE deviceName = '%@'",self.foodName.text,self.aboutFood.text,self.expireDate.text,self.remindDate.text,self.foodName.text,self.deviceID];
    const char *updateSql = [sql UTF8String];
    int updateResult = sqlite3_exec(_database,updateSql,NULL,NULL,NULL);
    if (updateResult != SQLITE_OK) {
        [self SystemAlert:@"保存内容失败"];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
#pragma mark - 根据存储设备编号查找所存储内容的信息
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
            self.name = [NSString stringWithUTF8String:food_name];
            self.foodName.text = self.name;
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
            NSLog(@"----%@",[NSString stringWithUTF8String:photopath]);
            self.food_image = [self getImage:[NSString stringWithUTF8String:photopath]];    //保存原本的图片
            self.imageView1.image = self.food_image;
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
//完成输入，将数据写入数据库
-(void)BeginEditing{
    
    if (_CanEdit) {
        _CanEdit = false;
        [self.edit setImage:[UIImage imageNamed:@"icon_edit"] forState:UIControlStateNormal];
        [self Savephoto];
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
        self.edit.alpha = 0.5;
         [self.edit setImage:[UIImage imageNamed:@"icon_editHL"] forState:UIControlStateNormal];
        self.edit.alpha = 1;
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
#pragma mark - 取出保存在本地的图片
-(UIImage*)getImage:(NSString *)filepath{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photopath = [NSString stringWithFormat:@"%@.png",filepath];
    NSString *imagePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",photopath]];
    // 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    NSLog(@"=== %@", imagePath);
    return img;
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
#pragma mark - 键盘

-(void)viewTapped:(UITapGestureRecognizer*)tapGr{
   [self.aboutFood resignFirstResponder];
   [self.foodName resignFirstResponder];
}


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
