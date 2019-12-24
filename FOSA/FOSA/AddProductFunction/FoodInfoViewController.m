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
#import "FosaDatePickerView.h"
#import "SqliteManager.h"
//图片宽高的最大值
#define KCompressibilityFactor 1280.00
#define MaxSCale 3.0  //最大缩放比例
#define MinScale 0.5  //最小缩放比例
@interface FoodInfoViewController ()<UITextFieldDelegate,UINavigationControllerDelegate,UNUserNotificationCenterDelegate,UITextViewDelegate,UIImagePickerControllerDelegate,UIScrollViewDelegate,FosaDatePickerViewDelegate>{
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
    UIImage *codeImage; // 分享二维码
    NSString *shareMessage;
    
    Boolean isSelect; //标志是否查询到数据

   }
@property (nonatomic,assign) NSString *storagePath;;
@property (nonatomic,assign) sqlite3 *database;
//结果集定义
@property (nonatomic,assign) sqlite3_stmt *stmt;
//记录所选择的日期
@property (nonatomic,assign) NSDate *exdate,*redate;

//fosa 日期选择器
@property (nonatomic,strong) FosaDatePickerView *fosaDatePicker;

//图片放大视图
@property (nonatomic,strong) UIScrollView *backGround;
@property (nonatomic,strong) UIImageView *bigImage;
@property (nonatomic,assign) CGFloat totalScale;
@end

@implementation FoodInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    
    [self CreatAndInitView];
    [self InitialDatePicker];
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
   FosaDatePickerView *DatePicker = [[FosaDatePickerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 300)];
    DatePicker.delegate = self;
    DatePicker.title = @"请选择时间";
    [self.view addSubview:DatePicker];
    self.fosaDatePicker = DatePicker;
}
#pragma mark - 创建并初始化界面
-(void)CreatAndInitView{
    _CanEdit = false;
    isSelect = false;
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
    self.imageView1.userInteractionEnabled = YES;
    self.imageView1.layer.shadowColor = [UIColor redColor].CGColor;//阴影颜色
    // 点击图片放大还原
    UITapGestureRecognizer *clickRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(EnlargePhoto)];
    [self.imageView1 addGestureRecognizer:clickRecognizer];

    self.deviceName = [[UITextView alloc]initWithFrame:CGRectMake(0, 0,headerWidth/2, headerheight/4-5)];
    self.deviceName.userInteractionEnabled = NO;
    self.deviceName.backgroundColor = [UIColor clearColor];
    [self.headerView addSubview:_imageView1];   //添加图片视图
    [self.headerView addSubview:_deviceName];

    self.share = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-45,5,40,40)];
    [_share setImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    [_share addTarget:self action:@selector(beginShare) forControlEvents:UIControlEventTouchUpInside];
    
    self.takePhoto = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-45,40, 40, 40)];
    [_takePhoto setImage:[UIImage imageNamed:@"icon_takePicture"] forState:UIControlStateNormal];
    [_takePhoto addTarget:self action:@selector(SelectOrChangephoto) forControlEvents:UIControlEventTouchUpInside];
    
    self.like = [[UIButton alloc]initWithFrame:CGRectMake(headerWidth-45, self.imageView1.frame.origin.y+self.imageView1.frame.size.height-40,40,40)];
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
    [UIView animateWithDuration:0.3 animations:^{
        self.fosaDatePicker.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 300);
    }];
}
#pragma mark - 分享
//生成share的UIView
- (UIView *)CreatShareView:(NSString *)title body:(NSString *)body{
    NSLog(@"begin creating");
    CGFloat mainwidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat mainHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIView *notification = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainwidth,mainHeight)];
    notification.backgroundColor = [UIColor whiteColor];
    
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(mainwidth/12, mainwidth/12, 30, 30)];
    UILabel *brand = [[UILabel alloc]initWithFrame:CGRectMake(mainwidth/4+10, mainwidth/6, 50, 15)];
    UIImageView *InfoCodeView = [[UIImageView alloc]initWithFrame:CGRectMake(mainwidth*4/5-10, 5, mainwidth/5, mainwidth/5)];

    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0,mainHeight/4, mainwidth, mainHeight/2)];
    UILabel *Ntitle = [[UILabel alloc]initWithFrame:CGRectMake(5,mainHeight*3/4+10, mainwidth, 20)];
    UILabel *Nbody = [[UILabel alloc]initWithFrame:CGRectMake(5, mainHeight*3/4+40, mainwidth, 20)];
    [notification addSubview:logo];
    [notification addSubview:brand];
    [notification addSubview:InfoCodeView];
    [notification addSubview:Ntitle];
    [notification addSubview:image];
    [notification addSubview:Nbody];

    logo.image  = [UIImage imageNamed:@"logo"];
    image.image = self.food_image;
    image.contentMode = UIViewContentModeScaleAspectFill;
    image.clipsToBounds = YES;
    
    InfoCodeView.image = codeImage;
    InfoCodeView.backgroundColor = [UIColor redColor];
    InfoCodeView.contentMode = UIViewContentModeScaleAspectFill;
    InfoCodeView.clipsToBounds = YES;
    
    brand.font  = [UIFont systemFontOfSize:10];
    brand.textAlignment = NSTextAlignmentCenter;
    brand.text  = @"FOSA";
    
    Ntitle.font  = [UIFont systemFontOfSize:12];
    Ntitle.textColor = [UIColor redColor];
    Ntitle.text = title;

    Nbody.font   = [UIFont systemFontOfSize:5];
    Nbody.text = body;
    return notification;
}
//将UIView转化为图片并保存在相册
- (UIImage *)SaveViewAsPicture:(UIView *)view{
    NSLog(@"begin saving");
    UIImage *imageRet = [[UIImage alloc]init];
    //UIGraphicsBeginImageContextWithOptions(区域大小, 是否是非透明的, 屏幕密度);
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    imageRet = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageRet;
}
- (UIImage *)GenerateQRCodeByMessage:(NSString *)message{
    // 1. 创建一个二维码滤镜实例(CIFilter)
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 滤镜恢复默认设置
    [filter setDefaults];
    // 2. 给滤镜添加数据
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    // 3. 生成二维码
    CIImage *image = [filter outputImage];
    //[self createNonInterpolatedUIImageFormCIImage:image withSize:];
    return [UIImage imageWithCIImage:image];
}
-(void)beginShare{
    NSLog(@"@@@@@@@@@");
    if (isSelect) {
        NSLog(@"**************************");
        codeImage = [self GenerateQRCodeByMessage:shareMessage];
        NSString *title = @"My Share";
        NSString *body = @"You can get the detail of my food by Scanning the Qrcode";
        UIImage *sharephoto = [self SaveViewAsPicture:[self CreatShareView:title body:body]];
        NSArray *activityItems = @[sharephoto];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
        [self presentViewController:activityVC animated:TRUE completion:nil];
    }
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

    self.totalScale = 1;
    self.bigImage = [[UIImageView alloc]init];
    _bigImage.frame = self.view.frame;
    _bigImage.image = self.imageView1.image;
    _bigImage.userInteractionEnabled = YES;
    _bigImage.contentMode = UIViewContentModeScaleAspectFit;
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
- (void)creatOrOpensql
{
    self.database = [SqliteManager InitSqliteWithName:@"Fosa.db"];
}
#pragma mark - 重新插入数据
- (void) UpdateInfo{
    //更新之前先删除原来的，然后再插入新的数据
    NSString *deleteSql;
    if ([self.deviceID hasPrefix:@"FOSASealer"]) {
        deleteSql = [NSString stringWithFormat:@"delete from Fosa3 where deviceName = '%@' and foodName = '%@'",self.deviceID,self.name];
    }else{
        deleteSql = [NSString stringWithFormat:@"delete from Fosa2 where deviceName = '%@' and foodName = '%@'",self.deviceID,self.name];
    }
    [SqliteManager DeleteDataFromTable:deleteSql database:self.database];
    
    if ([self.deviceID hasPrefix:@"FOSASealer"]) {
       //获取当前日期
        NSDate *currentDate = [[NSDate alloc]init];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        NSString *str = [formatter stringFromDate:currentDate];
        //currentDate = [formatter dateFromString:str];
        NSLog(@"%@",str);
        NSString *SealerInsertSql = [NSString stringWithFormat:@"insert into Fosa3(foodName,deviceName,aboutFood,expireDate,remindDate,storageDate,photoPath)values('%@','%@','%@','%@','%@','%@','%@')",_foodName.text,_deviceName.text,_aboutFood.text,self.expireDate.text,self.remindDate.text,str,self.foodName.text];
        [SqliteManager InsertDataIntoTable:SealerInsertSql database:self.database];
    }else{
        NSString *sql =[NSString stringWithFormat:@"insert into Fosa2(foodName,deviceName,aboutFood,expireDate,remindDate,photoPath)values('%@','%@','%@','%@','%@','%@')",_foodName.text,_deviceName.text,_aboutFood.text,self.expireDate.text,self.remindDate.text,self.foodName.text];
        [SqliteManager InsertDataIntoTable:sql database:self.database];
    }
}
#pragma mark - 根据存储设备编号查找所存储内容的信息
- (void) SelectDataFromSqlite{
    //查询数据库里对应食物的详细信息
    NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$");
    NSString *sql;
    if ([self.deviceID hasPrefix:@"FOSASealer"]) {
        sql = [NSString stringWithFormat:@"select aboutFood,expireDate,remindDate,photoPath from Fosa3 where deviceName = '%@' and foodName = '%@'",self.deviceID,self.name];
    }else{
        sql = [NSString stringWithFormat:@"select aboutFood,expireDate,remindDate,photoPath from Fosa2 where deviceName = '%@' and foodName = '%@' ",self.deviceID,self.name];
    }
    self.stmt = [SqliteManager SelectDataFromTable:sql database:self.database];
    if (self.stmt != NULL) {
        NSLog(@"&*&**&*&*&*&*&*&*&*&*&");
        while (sqlite3_step(_stmt) == SQLITE_ROW) {
                self.foodName.text = self.name;
                self.deviceName.text = self.deviceID;
                const char *about_food  = (const char*)sqlite3_column_text(_stmt,0);
                NSLog(@"查询到数据:%@",[NSString stringWithUTF8String:about_food]);
                self.aboutFood.text = [NSString stringWithUTF8String:about_food];
                const char *expire_date = (const char*)sqlite3_column_text(_stmt,1);
                NSLog(@"查询到数据:%@",[NSString stringWithUTF8String:expire_date]);
                self.expireDate.text = [NSString stringWithUTF8String:expire_date];
                const char *remind_date = (const char*)sqlite3_column_text(_stmt,2);
                NSLog(@"查询到数据:%@",[NSString stringWithUTF8String:remind_date]);
                self.remindDate.text = [NSString stringWithUTF8String:remind_date];
                const char *photopath = (const char*)sqlite3_column_text(_stmt,3);
                NSLog(@"----%@",[NSString stringWithUTF8String:photopath]);
                self.food_image = [self getImage:[NSString stringWithUTF8String:photopath]];    //保存原本的图片
                self.imageView1.image = self.food_image;
            shareMessage = [NSString stringWithFormat:@"FOSA&%@&%@&%@&%@&%@&",self.foodName.text,self.deviceName.text,self.aboutFood.text,self.expireDate.text,self.remindDate.text];
            NSLog(@"%@",shareMessage);
            isSelect = true;
            }
    }
    if (!isSelect) {
        NSString *message = @"数据库中没有这个记录，是否保存？";
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notification" message:message preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"<<<<<<<<<YES");
             NSString *insertSql = [NSString stringWithFormat:@"insert into Fosa2(foodName,deviceName,aboutFood,expireDate,remindDate,photoPath)values('%@','%@','%@','%@','%@','%@')",self.name,self.deviceID,self.infoArray[3],self.infoArray[4],self.infoArray[5],self.name];
            [self InsertData:insertSql];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"》〉》〉》〉》〉》〉》〉》 Cancel");
        }]];
        [self presentViewController:alert animated:true completion:nil];
    }
}
//插入新数据
- (void)InsertData:(NSString *)sql{
    //错误信息定义
    char *erro = 0;
    int insertResult = sqlite3_exec(self.database, sql.UTF8String,NULL, NULL,&erro);
    if(insertResult == SQLITE_OK){
        NSLog(@"添加数据成功");
        [self Savephoto:self.food_image];
        [self SelectDataFromSqlite];
    }else{
        NSLog(@"插入数据失败");
    }
}
#pragma mark - 编辑与完成
-(void)BeginEditing{
    if (_CanEdit) {
        _CanEdit = false;
        [self prohibitEdit];        //禁止交互
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
         [self.edit setImage:[UIImage imageNamed:@"icon_ok"] forState:UIControlStateNormal];
        self.edit.alpha = 1;
        _CanEdit = true;
    }
}
//保存照片到沙盒
- (NSString *)Savephoto:(UIImage *)image{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photoName = [NSString stringWithFormat:@"%@.png",self.name];
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent: photoName];// 保存文件的路径
    NSLog(@"这个是照片的保存地址:%@",filePath);
    BOOL result =[UIImagePNGRepresentation(image) writeToFile:filePath  atomically:YES];// 保存成功会返回YES
    if(result == YES) {
        NSLog(@"保存成功");
    }
    return filePath;
}
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
#pragma mark - 点击与拖动的方法

//拖动视图的方法
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    // 当前触摸点
    CGPoint currentPoint = [touch locationInView:self.bigImage];
    // 上一个触摸点
    CGPoint previousPoint = [touch previousLocationInView:self.bigImage];
    // 当前view的中点
    CGPoint center = self.bigImage.center;
    
    center.x += (currentPoint.x - previousPoint.x);
    center.y += (currentPoint.y - previousPoint.y);
    // 修改当前view的中点(中点改变view的位置就会改变)
    self.bigImage.center = center;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}
@end
