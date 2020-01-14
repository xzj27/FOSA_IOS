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
#import "SqliteManager.h"
#import "FosaDatePickerView.h"
#define KCompressibilityFactor 1280.00 //图片宽高的最大值

@interface AddViewController ()<UIScrollViewDelegate,UITextFieldDelegate,UNUserNotificationCenterDelegate,FosaDatePickerViewDelegate>{
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
@property (nonatomic,assign) NSString *storagePath;;
@property (nonatomic,assign) sqlite3 *database;
//结果集定义
@property (nonatomic,assign) sqlite3_stmt *stmt;
@property (nonatomic,strong) UIButton *done;

//记录所选择的日期
@property (nonatomic,assign) NSDate *exdate,*redate;

//图片放大视图
@property (nonatomic,strong) UIScrollView *backGround;
@property (nonatomic,strong) UIImageView *bigImage;

@property (nonatomic,weak) FosaDatePickerView *fosaDatePicker;

@end

@implementation AddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
    [self CreatAndInitView];
    [self InitialDatePicker];
    
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
    FosaDatePickerView *DatePicker = [[FosaDatePickerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 300)];
    DatePicker.delegate = self;
    DatePicker.title = @"请选择时间";
    [self.view addSubview:DatePicker];
    self.fosaDatePicker = DatePicker;
}
#pragma mark - 创建并初始化界面
-(void)CreatAndInitView{
    self.done = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    [_done setImage:[UIImage imageNamed:@"icon_done"] forState:UIControlStateNormal];
    [_done addTarget:self action:@selector(finish) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:_done];
       self.navigationItem.rightBarButtonItem= rightItem;

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
    //初始化轮播器
    self.picturePlayer = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, headerWidth, headerheight*3/4)];
    _picturePlayer.pagingEnabled = YES;
    _picturePlayer.delegate = self;
    _picturePlayer.showsHorizontalScrollIndicator = NO;
    _picturePlayer.bounces = NO;
    _picturePlayer.contentSize = CGSizeMake(headerWidth*3, headerheight*3/4);
    for (int i = 0; i < 3; i++) {
        CGRect frame = CGRectMake(i*headerWidth, 0, headerWidth, headerheight*3/4);
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:frame];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        imgView.image = self.food_image[i];
        [self.picturePlayer addSubview:imgView];
    }
    [self.headerView addSubview:_picturePlayer];
    
    //页面指示器
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(headerWidth/3, headerheight*3/4-30, headerWidth/3, 20)];
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = 3;
    self.pageControl.pageIndicatorTintColor = [UIColor redColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
    [self.headerView addSubview:self.pageControl];

    
    // 添加点击手势
    self.imageView1.userInteractionEnabled = YES;
    UITapGestureRecognizer *clickRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(EnlargePhoto)];
    [self.imageView1 addGestureRecognizer:clickRecognizer];
    
    self.share = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-50,headerheight*3/4-50,40,40)];
    self.share.backgroundColor = [UIColor whiteColor];
    [_share setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    self.like = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-45, self.imageView1.frame.origin.y+self.imageView1.frame.size.height-40,40,40)];
    [_like setImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateNormal];
    
    [self.headerView insertSubview:_share atIndex:10];
    //[self.headerView addSubview:_like];
    
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
    [UIView animateWithDuration:0.3 animations:^{
        self.fosaDatePicker.frame = CGRectMake(0, self.view.frame.size.height - 300, self.view.frame.size.width, 300);
        [self.fosaDatePicker show];
    }];
}
-(void)RemindDateSelect{
    isRemind = true;
    NSLog(@"select reminding date");
    [UIView animateWithDuration:0.3 animations:^{
        self.fosaDatePicker.frame = CGRectMake(0, self.view.frame.size.height - 300, self.view.frame.size.width, 300);
        [self.fosaDatePicker show];
    }];
}
#pragma mark -- UIScrollerView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat offset = scrollView.contentOffset.x;
    NSInteger index = offset/self.headerView.frame.size.width;
    self.pageControl.currentPage = index;
}

#pragma mark -- FosaDatePickerViewDelegate
/**
 保存按钮代理方法

 @param timer 选择的数据
 */
- (void)datePickerViewSaveBtnClickDelegate:(NSString *)timer {
    NSLog(@"保存点击");
    if (isRemind) {
        self.remindDate.text = timer;
    }else{
        self.expireDate.text  = timer;
    }
    [UIView animateWithDuration:0.3 animations:^{
       self.fosaDatePicker.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 300);
   }];
}
/**
 取消按钮代理方法
 */
- (void)datePickerViewCancelBtnClickDelegate {
    NSLog(@"取消点击");
//    self.btn.hidden = YES;
    [UIView animateWithDuration:0.3 animations:^{
        self.fosaDatePicker.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 300);
    }];
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
    self.database = [SqliteManager InitSqliteWithName:@"Fosa.db"];
    //创建fosa食品盒数据库表
    NSString *creatFosaSql = @"create table if not exists Fosa2(id integer primary key,foodName text,deviceName text,aboutFood text,expireDate text,remindDate text,photoPath text)";
    [SqliteManager InitTableWithName:creatFosaSql database:self.database];

    //创建fosasealer数据库表
    NSString *creatSealerSql = @"create table if not exists Fosa3(id integer primary key,foodName text,deviceName text,aboutFood text,expireDate text,remindDate text,storageDate text,photoPath text)";
    [SqliteManager InitTableWithName:creatSealerSql database:self.database];
}
-(void) InsertDataIntoSqlite{
    if(self.foodName.text != nil){
        if ([self.deviceName.text hasPrefix:@"FOSASealer"]) {
            NSLog(@"************");
            //获取当前日期
            NSDate *currentDate = [[NSDate alloc]init];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
            NSString *str = [formatter stringFromDate:currentDate];
            //currentDate = [formatter dateFromString:str];
            NSLog(@"%@",str);
            NSString *SealerInsertSql = [NSString stringWithFormat:@"insert into Fosa3(foodName,deviceName,aboutFood,expireDate,remindDate,storageDate,photoPath)values('%@','%@','%@','%@','%@','%@','%@')",_foodName.text,_deviceName.text,_aboutFood.text,self.expireDate.text,self.remindDate.text,str,self.foodName.text];
            [SqliteManager InsertDataIntoTable:SealerInsertSql database:self.database];
        }else{
        //插入语句
        NSString *FosaInsertSql =[NSString stringWithFormat:@"insert into Fosa2(foodName,deviceName,aboutFood,expireDate,remindDate,photoPath)values('%@','%@','%@','%@','%@','%@')",_foodName.text,_deviceName.text,_aboutFood.text,self.expireDate.text,self.remindDate.text,self.foodName.text];
        [SqliteManager InsertDataIntoTable:FosaInsertSql database:self.database];
        }
    }
}
#pragma mark - 完成输入，将数据写入数据库
-(void)finish{
    [self creatOrOpensql];
    [self InsertDataIntoSqlite];
    //[self SavePhotoArray:self.food_image];
    
    picturePath = [self Savephoto:[self fixOrientation:self.food_image[0]]];
    //格式化时间
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *Edate = [formatter dateFromString:[NSString stringWithFormat:@"%@ 14:00:00",expire_Date]];
    NSLog(@"%@",[formatter stringFromDate:Edate]);
    NSDate *Rdate = [formatter dateFromString:[NSString stringWithFormat:@"%@ 13:30:00",remind_Date]];
    NSLog(@"%@",[formatter stringFromDate:Rdate]);
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
- (void)SavePhotoArray:(NSMutableArray<UIImage *> *)array{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photoName;
    NSString *filePath ;// 保存文件的路径
    for (int i = 0; i < array.count; i++) {
        photoName = [NSString stringWithFormat:@"%@%d.png",self.foodName.text,i];
        filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent: photoName];
        NSLog(@"这个是照片的保存地址:%@",filePath);
        BOOL result =[UIImagePNGRepresentation(array[i]) writeToFile:filePath  atomically:YES];// 保存成功会返回YES
           if(result == YES) {
               NSLog(@"保存成功");
           }
    }
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
#pragma mark -  放大缩小图片
- (void)EnlargePhoto{
    NSLog(@"***********************************");
    [self.aboutFood resignFirstResponder];
    [self.foodName resignFirstResponder];
    self.navigationController.navigationBar.hidden = YES;   //隐藏导航栏
    [UIApplication sharedApplication].statusBarHidden = YES;             //隐藏状态栏
    //底层视图
    self.backGround = [[UIScrollView alloc]init];
    _backGround.backgroundColor = [UIColor blackColor];
    _backGround.contentSize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
    _backGround.frame = self.view.frame;
    _backGround.showsHorizontalScrollIndicator = NO;
    _backGround.showsVerticalScrollIndicator = NO;
    _backGround.multipleTouchEnabled = YES;
    _backGround.maximumZoomScale = 5;
    _backGround.minimumZoomScale = 1;
    _backGround.delegate = self;

    self.bigImage = [[UIImageView alloc]init];
    _bigImage.frame = self.view.frame;
    _bigImage.image = self.imageView1.image;
    _bigImage.userInteractionEnabled = YES;
    _bigImage.contentMode = UIViewContentModeScaleToFill;
    _bigImage.clipsToBounds = YES;
    UITapGestureRecognizer *shrinkRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(shirnkPhoto)];
    [shrinkRecognizer setNumberOfTapsRequired:1];
    [_bigImage addGestureRecognizer:shrinkRecognizer];
    //添加双击事件
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTapGesture setNumberOfTapsRequired:2];
    [_bigImage addGestureRecognizer:doubleTapGesture];
    
    [shrinkRecognizer requireGestureRecognizerToFail:doubleTapGesture];
    
    [_backGround addSubview:self.bigImage];
    [self.view addSubview:self.backGround];
}
#pragma mark -  scrollview代理
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.bigImage;
}
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
//    self.bigImage.center = self.view.center;
//}

/**双击定点放大*/
- (void)handleDoubleTap:(UIGestureRecognizer *)gesture
{
    CGFloat zoomScale = self.backGround.zoomScale;
    NSLog(@"%f",self.backGround.zoomScale);
    zoomScale = (zoomScale == 1.0) ? 3.0 : 1.0;
    CGRect zoomRect = [self zoomRectForScale:zoomScale withCenter:[gesture locationInView:gesture.view]];
    [self.backGround zoomToRect:zoomRect animated:YES];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
{
    CGRect zoomRect;
    zoomRect.size.height =self.view.frame.size.height / scale;
    zoomRect.size.width  =self.view.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  /2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height /2.0);
    return zoomRect;
}
//点击缩小视图
- (void)shirnkPhoto{
    [self.backGround removeFromSuperview];
    self.navigationController.navigationBar.hidden = NO;
    [UIApplication sharedApplication].statusBarHidden = NO;
}

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

@end
