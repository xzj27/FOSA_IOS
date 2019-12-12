//
//  FosaPoundViewController.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FosaPoundViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "ScanOneCodeViewController.h"
#import "SqliteManager.h"
#import "FoodInfoViewController.h"
#import "CategoryViewController.h"

#import "CellModel.h"
#import "SealerCell.h"
#import "CalorieTableViewCell.h"
//图片宽高的最大值
#define KCompressibilityFactor 1280.00
@interface FosaPoundViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,AVCaptureMetadataOutputObjectsDelegate,UITextFieldDelegate>{
    //Sealer数据数组
    NSMutableArray<CellModel *> *arrayData;
    //计算卡路里的食物数量
    int calorieNumber;
    //标记当前是否展开
    Boolean isExpand;
    //标记当前点击选择卡路里的cell
    NSInteger current;
    //table cell的内容
    NSString *foodname,*expireDate,*storageDate;
    
    //蓝牙磅和列表的中心
    CGPoint center,cellCenter,sealer2Center;
    //标记当前是否正在扫码
    Boolean isScan;
    NSString *result;
    
    //标记是否局部更新
    Boolean isUpdate;
    //标记是否已经选择卡路里
    Boolean *isSelect;
    //扫码相关
    /**扫码相关*/
    AVCaptureDevice * device;
    AVCaptureDeviceInput * input;
    AVCaptureMetadataOutput * output;//元数据输出流，需要指定他的输出类型及扫描范围
    AVCaptureVideoDataOutput *VideoOutput;
    AVCaptureSession * session; //AVFoundation框架捕获类的中心枢纽，协调输入输出设备以获得数据
    AVCaptureVideoPreviewLayer * previewLayer;//展示捕获图像的图层，是CALayer的子类
    UIImageView *activeImage;       //扫描框
    UIImageView *scanImage;         //扫描线
    AVMetadataMachineReadableCodeObject *object; //二维码对象
//    UIView *maskView;
}
@property (nonatomic,strong) UIButton *send;
@property (nonatomic,assign) sqlite3 *database;
@property (nonatomic,assign) sqlite3_stmt *stmt;

@property (nonatomic,strong) UITextField *weight;
@property (nonatomic,strong) UITextView *calorie;

@property (nonatomic,strong) UIImageView *focusCursor;       //标记二维码的位置
@end

@implementation FosaPoundViewController
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


#pragma mark - 主视图懒加载
- (UIScrollView *)rootView{
    if (_rootView == nil) {
        _rootView = [[UIScrollView alloc]init];
    }
    return _rootView;
}
- (UIView *)sealerView{
    if (_sealerView == nil) {
        _sealerView = [[UIView alloc]init];
    }
    return _sealerView;
}
- (UIImageView *)sealerImage{
    if (_sealerImage == nil) {
        _sealerImage = [[UIImageView alloc]init];
    }
    return _sealerImage;
}
- (UIButton *)scanBtn{
    if (_scanBtn == nil) {
        _scanBtn = [[UIButton alloc]init];
    }
    return _scanBtn;
}
- (UIView *)poundView{
    if (_poundView == nil) {
        _poundView = [[UIView alloc]init];
    }
    return _poundView;
}
- (UIImageView *)poundImage{
    if (_poundImage == nil) {
        _poundImage = [[UIImageView alloc]init];
    }
    return  _poundImage;
}

#pragma mark - 懒加载扫码相关属性
- (AVCaptureDevice *)device{
    if (device == nil) {
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //检查相机是否有摄像头
        if(!device){
            NSLog(@"该设备没有摄像头");
        }
    }
    return device;
}
- (AVCaptureDeviceInput *)input{
    if (input == nil) {
        //设备输入 初始化
        input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    }
    return input;
}
- (AVCaptureMetadataOutput *)output{
    if (output == nil) {
        //设备输出
        output = [[AVCaptureMetadataOutput alloc]init];
        CGFloat ScreenWidth = self.rootScanView.frame.size.width;
        //设置扫描作用域范围(中间透明的扫描框)
        CGRect intertRect = [self.previewLayer metadataOutputRectOfInterestForRect:CGRectMake(ScreenWidth*0.1, ScreenWidth*0.1, ScreenWidth*0.8, ScreenWidth*0.8)];
        output.rectOfInterest = intertRect;
    }
    return output;
}
- (AVCaptureVideoDataOutput *)VideoOutput{
    if (VideoOutput == nil) {
        VideoOutput = [[AVCaptureVideoDataOutput alloc]init];
    }
    return VideoOutput;
}
- (AVCaptureSession *)session{
    if (session == nil) {
        session = [[AVCaptureSession alloc]init];
    }
    return session;
}
- (AVCaptureVideoPreviewLayer *)previewLayer{
    if (previewLayer == nil) {
        previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    }
    return previewLayer;
}

-(void)startScan{
    //将底部视图添加到Sealer视图上
    [self.sealerView addSubview:self.rootScanView];
    
    //动态申请相机权限
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted){
        if(granted){
            //用户允许
            NSLog(@"用户同意");
        }else{
            NSLog(@"用户拒绝");
        }
    }];
     //会话添加设备的 输入 输出，建立连接
        if ([self.session canAddInput:self.input]) {
            [session addInput:self.input];
        }else{
            NSLog(@"找不到摄像头设备");
        }
        if ([self.session canAddOutput:self.output]) {
            [self.session addOutput:self.output];
        }
        if([self.session canAddOutput:self.VideoOutput]){
            [self.session addOutput:self.VideoOutput];
        }
    //指定设备的识别类型
        self.output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypePDF417Code];
    //设备输出 初始化，并设置代理和回调，当设备扫描到数据时通过该代理输出队列，一般输出队列都设置为主队列，也是设置了回调方法执行所在的队列环境
    //dispatch_queue_t queue = dispatch_queue_create("Sealerqueue", NULL);
    [self.output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //添加预览图层
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.rootScanView.bounds;
    [self.rootScanView.layer addSublayer:self.previewLayer];
    //开始捕获
    [self.session startRunning];
    
    //设置device的功能
    [self.input.device lockForConfiguration:nil];
    
    self.rootScanView.clipsToBounds = YES;
    self.rootScanView.layer.masksToBounds = YES;
    
    //自动白平衡
    if([self.device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]){
        [self.input.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
    }
    //判断并开启自动对焦功能
    if(self.device.isFocusPointOfInterestSupported &&[self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
        [self.input.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    }
    //自动曝光
    if([self.device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
        [self.input.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [self.input.device unlockForConfiguration];
    
    //扫码标识
    //聚焦图片
    UIImageView *focusCursor = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    focusCursor.alpha = 0;
    focusCursor.image = [UIImage imageNamed:@"camera_focus_red"];
    [self.rootScanView addSubview:focusCursor];
    _focusCursor = focusCursor;
    
    [self ScanOneByOne_ScanView];
    // 开始动画，扫描条上下移动
    [self performSelectorOnMainThread:@selector(timerFired) withObject:nil waitUntilDone:NO];
    
}
#pragma mark - 获取在扫描框中的二维码的中心坐标
-(CGPoint)getCenterOfQRcode:(AVMetadataMachineReadableCodeObject *)objc
{
        CGPoint center = CGPointZero;
        // 扫码区域的坐标计算是以横屏为基准，应以右上角为（0，0），根据二维码的同一个点的y坐标来进行判断每个二维码的位置关系
        NSArray *array = objc.corners;
        NSLog(@"cornersArray = %@",array);
        CGPoint point = CGPointZero;
        int index = 0;
        CFDictionaryRef dict = (__bridge CFDictionaryRef)(array[index++]);
        // 把字典转换为点，存在point里，成功返回true 其他false
        CGPointMakeWithDictionaryRepresentation(dict, &point);
        CGPoint point2 = CGPointZero;
        CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[index++], &point2);
        center.x=(point.x+point2.x)/2;
        CGPoint point3 = CGPointZero;
        CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[index++], &point3);
        center.y = (point2.y+point3.y)/2;
        CGPoint point4 = CGPointZero;
        CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[index++], &point4);

    return center;
}
#pragma mark - 设置在二维码位置显示聚焦光标
- (void)setFocusCursorWithPoint:(AVMetadataMachineReadableCodeObject *)objc
{
    
    CGPoint point = [self getCenterOfQRcode:objc];
    CGPoint center = CGPointZero;
   
    center.x = self.rootScanView.frame.size.width*(1-point.y);
    center.y = self.rootScanView.frame.size.height*(point.x);
    NSLog(@"******************************************%f",center.y);
    self.focusCursor.center = center;
    self.focusCursor.transform = CGAffineTransformMakeScale(3,3);
    self.focusCursor.alpha = 1.0;
    [UIView animateWithDuration:2.0 animations:^{
        self.focusCursor.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        //self.focusCursor.alpha = 0;
    }];
}
#pragma mark - 单个扫码模式
-(void)ScanOneByOne_ScanView{
    CGFloat imageX = self.rootScanView.frame.size.width*0.1;
    CGFloat imageY = self.rootScanView.frame.size.width*0.1;
    // 扫描框中的四个边角的背景图
//         self.scanImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"saoyisao@3x"]];
//         _scanImage.frame = CGRectMake(imageX, imageY, self.view.frame.size.width*0.7, self.view.frame.size.width*0.7);
//         [self.view addSubview:_scanImage];

         // 上下移动的扫描条
         activeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"saoyisao-3@3x"]];
         activeImage.frame = CGRectMake(imageX, imageY, self.rootScanView.frame.size.width*0.7, 4);
         [self.rootScanView addSubview:activeImage];
//      //添加全屏的黑色半透明蒙版
//        self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.rootScanView.frame.size.width+10, self.view.frame.size.height)];
//        _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
//        [self.rootScanView addSubview:_maskView];
//        //从蒙版中扣出扫描框那一块,这块的大小尺寸将来也设成扫描输出的作用域大小
//        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
//        [maskPath appendPath:[[UIBezierPath bezierPathWithRect:CGRectMake(imageX,imageY, self.view.frame.size.width*0.7, self.view.frame.size.width*0.7)] bezierPathByReversingPath]];
//        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//        maskLayer.path = maskPath.CGPath;
//        _maskView.layer.mask = maskLayer;
//    //闪光灯
//    self.flashBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-20, CGRectGetMaxY(_scanImage.frame)-45, 40, 40)];
//    _flashBtn.layer.cornerRadius = _flashBtn.frame.size.width/2;
//    _flashBtn.clipsToBounds = YES;
//    [_flashBtn setBackgroundImage:[UIImage imageNamed:@"shanguangdeng-an.png"] forState:(UIControlStateNormal)];
//    [_flashBtn addTarget:self action:@selector(openFlash:) forControlEvents:UIControlEventTouchUpInside];
//    //[self.view addSubview:self.flashBtn];
    
    //设置有效扫描区域
    CGRect intertRect = [previewLayer metadataOutputRectOfInterestForRect:CGRectMake(imageX, imageY, self.view.frame.size.width*0.8, self.view.frame.size.width*0.8)];
    output.rectOfInterest = intertRect;
    
//    //添加UISlider用于放大和缩小视图
//    _ZoomSlider = [[UISlider alloc] initWithFrame:CGRectMake(imageX,imageY+self.view.frame.size.width*0.7,self.view.frame.size.width*0.7,20)];
//    [self.view addSubview:_ZoomSlider];
//    _ZoomSlider.minimumValue = 0;
//    _ZoomSlider.maximumValue = 100;
//    [_ZoomSlider addTarget:self action:@selector(ZoomSliderValueChanged) forControlEvents:UIControlEventValueChanged];
}
#pragma mark - 加载扫描线动画
-(void)timerFired {
    [activeImage.layer addAnimation:[self moveY:2.5 Y:[NSNumber numberWithFloat:(self.rootScanView.frame.size.width-4)]] forKey:nil];
}
/**
 *  @param time 单次滑动完成时间
 *  @param y    滑动距离
 *
 *  @return 返回动画
 */
- (CABasicAnimation *)moveY:(float)time Y:(NSNumber *)y {
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath : @"transform.translation.y" ]; ///.y 的话就向下移动。
    animation.toValue = y;
    animation.duration = time;
    animation.removedOnCompletion = YES ; //yes 的话，又返回原位置了。
    animation.repeatCount = MAXFLOAT ;
    animation.fillMode = kCAFillModeForwards;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear]; //匀速变化
    return animation;
}

#pragma mark - 主视图加载
//局部更新
- (void)viewWillAppear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
    if (isUpdate) {
        isExpand = false;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self->arrayData removeAllObjects];
            [self SelectData];
        });
    }
    //添加键盘弹出与收回的事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    if (self.calorieData.count != 0) {
        NSLog(@"我更新了卡路里总量");
        dispatch_async(dispatch_get_main_queue(), ^{
           NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            self.calorieData[self->current].calorie= [defaults valueForKey:@"calorieValue"];
            [defaults setObject:0 forKey:@"calorieValue"];
            //self->current = -1;
           [self.calorieTable reloadData];
           [self UpdateAndCalculateCalorie];
        });
    }
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.userInteractionEnabled = YES;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(StopEdit:)];
    [self.view addGestureRecognizer:singleTap];

    [self InitView];
}
- (void)InitView{
    isScan = false; //扫码标记初始化
    isUpdate = false;
    isSelect = false;
    arrayData = [[NSMutableArray alloc]init];
    self.calorieData = [[NSMutableArray alloc]init];
    _weight = [[UITextField alloc]init];
    
    //rootView
    self.rootView.frame = CGRectMake(0, 0, screen_width, screen_height);
    self.rootView.bounces = NO;
    self.rootView.showsVerticalScrollIndicator = NO;
    self.rootView.showsHorizontalScrollIndicator = NO;
    self.rootView.contentSize = CGSizeMake(screen_width,screen_height*1.5);
    [self.view addSubview:self.rootView];
    //SealerView
    self.sealerView.frame = CGRectMake(5,10,screen_width-10,(screen_height)/4-10);
    self.sealerView.backgroundColor = [UIColor colorWithRed:0/255.0 green:191/255.0 blue:227/255.0 alpha:1.0];
    [self.rootView addSubview:self.sealerView];
    //SealerView content
    self.sealerImage.frame = CGRectMake(5, 5, self.sealerView.frame.size.height*2/3-10, self.sealerView.frame.size.height*2/3-10);
    self.sealerImage.image = [UIImage imageNamed:@"fosa.jpg"];
    [self.sealerView addSubview:self.sealerImage];
    
    //扫描按钮
    self.scanBtn.frame = CGRectMake(self.sealerView.frame.size.width-45, 5, 40, 40);
    [self.scanBtn setImage:[UIImage imageNamed:@"icon_scan"]  forState:UIControlStateNormal];
    [self.scanBtn addTarget:self action:@selector(ScanAction) forControlEvents:UIControlEventTouchUpInside];
    [self.sealerView addSubview:self.scanBtn];
    
    //初始化 扫码的底部视图
    self.rootScanView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.sealerView.frame.size.width-50, self.sealerView.frame.size.height*5/6-5)];
    //列表
    self.InfoMenu = [[UIView alloc]initWithFrame:CGRectMake(0, self.sealerView.frame.size.height*5/6, self.sealerView.frame.size.width,self.sealerView.frame.size.height/6)];
    _InfoMenu.backgroundColor = [UIColor colorWithRed:80/255.0 green:200/255.0 blue:240/255.0 alpha:1.0];
    self.indicator = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.InfoMenu.frame.size.height, self.InfoMenu.frame.size.height)];
    _indicator.image = [UIImage imageNamed:@"caret"];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ExpandList)];
    self.indicator.userInteractionEnabled = YES;
    [self.indicator addGestureRecognizer:recognizer];
    [self.InfoMenu addSubview:_indicator];
    [self.sealerView addSubview:self.InfoMenu];
    [self InitFoodTable];
    
    //sealerview2
    self.sealerView2 = [[UIView alloc]initWithFrame:CGRectMake(5,10+(screen_height)/4,screen_width-10,(screen_height)/4-10)];
    self.sealerView2.backgroundColor = [UIColor colorWithRed:0/255.0 green:191/255.0 blue:227/255.0 alpha:1.0];;
    [self.rootView addSubview:self.sealerView2];
    UIImageView *imageview2 = [[UIImageView alloc]initWithFrame: CGRectMake(5, 5, self.sealerView.frame.size.height*2/3-10, self.sealerView.frame.size.height*2/3-10)];
    imageview2.image = [UIImage imageNamed:@"fosa.jpg"];
    [self.sealerView2 addSubview:imageview2];
    //扫描按钮2
    UIButton *btn2 = [[UIButton alloc]initWithFrame:CGRectMake(self.sealerView.frame.size.width-45, 5, 40, 40)];
    
    [btn2 setImage:[UIImage imageNamed:@"icon_scan"]  forState:UIControlStateNormal];
    //[btn2 addTarget:self action:@selector(ScanAction) forControlEvents:UIControlEventTouchUpInside];
    [self.sealerView2 addSubview:btn2];
    
    UIView *infoMenu2 = [[UIView alloc]initWithFrame:CGRectMake(0, self.sealerView.frame.size.height*5/6, self.sealerView.frame.size.width,self.sealerView.frame.size.height/6)];
    infoMenu2.backgroundColor = [UIColor colorWithRed:80/255.0 green:200/255.0 blue:240/255.0 alpha:1.0];
    UIImageView *indicator2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.InfoMenu.frame.size.height, self.InfoMenu.frame.size.height)];
    indicator2.image = [UIImage imageNamed:@"caret"];
    //UITapGestureRecognizer *recognizer2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ExpandList)];
    indicator2.userInteractionEnabled = YES;
    [infoMenu2 addSubview:indicator2];
    //[indicator2 addGestureRecognizer:recognizer2];
    [_sealerView2 addSubview:infoMenu2];
    //列表
    
    self.poundView.frame = CGRectMake(5, StatusBarHeight+screen_height/2, screen_width-10, screen_height/8);
    self.poundView.backgroundColor = [UIColor colorWithRed:254/255.0 green:0/255.0 blue:151/255.0 alpha:1.0];
    
    //添加点击手势
    self.poundView.userInteractionEnabled = YES;
    UITapGestureRecognizer *poundrecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickToMove)];
    [self.poundView addGestureRecognizer:poundrecognizer];
    
    [self.rootView addSubview:self.poundView];
    self.poundImage.frame = CGRectMake(5, 5, self.poundView.frame.size.height-10, self.poundView.frame.size.height-10);
    self.poundImage.image = [UIImage imageNamed:@"img_pound.jpg"];
    [self.poundView addSubview:self.poundImage];
    //连接开关
    self.connect = [[UIButton alloc]initWithFrame:CGRectMake(self.poundView.frame.size.width-45, 5, 40, 40)];
    [self.connect setImage:[UIImage imageNamed:@"icon_disconnect"] forState:UIControlStateNormal];
    [self.poundView addSubview:self.connect];
    
    //添加底部卡路里总量视图
    self.calorieResultView = [[UIView alloc]initWithFrame:CGRectMake(0, screen_height-TabbarHeight-70, screen_width, 70)];
    _calorieResultView.backgroundColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0];
    self.totalcalorieLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, screen_width/3, self.calorieResultView.frame.size.height)];
    _totalcalorieLabel.text = @"卡路里总量(Kcal):";
    _totalcalorieLabel.font = [UIFont systemFontOfSize:14];
    [_calorieResultView addSubview:_totalcalorieLabel];
    self.Allcalorie = [[UILabel alloc]initWithFrame:CGRectMake(screen_width/3, 5, screen_width*2/3-70, self.calorieResultView.frame.size.height)];
    _Allcalorie.userInteractionEnabled = NO;
    _Allcalorie.layer.cornerRadius = 5;
    _Allcalorie.textAlignment = NSTextAlignmentCenter;
    _Allcalorie.backgroundColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1.0];
    
    [_calorieResultView addSubview:_Allcalorie];

    self.addCalorie = [[UIButton alloc]initWithFrame:CGRectMake(screen_width-70, 0, 70, 70)];
    [_addCalorie setImage:[UIImage imageNamed:@"icon_add"] forState:UIControlStateNormal];
    [_calorieResultView addSubview:_addCalorie];
    [_addCalorie addTarget:self action:@selector(addAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_calorieResultView];
    //calorieNumber = 0;

    center = self.poundView.center;
    cellCenter = self.calorieTable.center;
    sealer2Center = _sealerView2.center;
    [self InitCalorieTable];
}
- (void)CalorieData{
    NSString *weightText = @"";
    NSString *calorieText = @"";
    CalorieModel *model = [[CalorieModel alloc]initwithTextValue:weightText calorie:calorieText];
    [self.calorieData addObject:model];
}
#pragma mark - 食物列表
- (void)ExpandList{
    if (!isExpand) {
        self.indicator.image = [UIImage imageNamed:@"caret_open"];
        self.foodTable.hidden = NO;
        [self moveView];
    }else{
        self.indicator.image = [UIImage imageNamed:@"caret"];
        self.poundView.center = center;
        self.calorieTable.center = cellCenter;
        self.sealerView2.center = sealer2Center;
        self.foodTable.hidden = YES;
        isExpand = false;
        self.rootView.contentSize = CGSizeMake(screen_width,screen_height*1.5);
    }
}
- (void)clickToMove{
     [self.rootView setContentOffset:CGPointMake(0,self.poundView.frame.origin.y-StatusBarHeight) animated:YES];
}
- (void)moveView{
    isExpand = true;
    self.rootView.contentSize = CGSizeMake(screen_width,screen_height+self.foodTable.frame.size.height);
    
    CGPoint sCenter2 = CGPointZero;
    sCenter2.x = sealer2Center.x;
    sCenter2.y = sealer2Center.y+self.foodTable.frame.size.height;
    self.sealerView2.center = sCenter2;
    
    
    CGPoint center1 = CGPointZero;
    center1.x = screen_width/2;
    center1.y = center.y+self.foodTable.frame.size.height;
    self.poundView.center = center1;

    CGPoint listcenter = CGPointZero;
    listcenter.y = center1.y + self.poundView.frame.size.height/2+self.calorieTable.frame.size.height/2;
    listcenter.x = center1.x;
    self.calorieTable.center = listcenter;
}


- (void)InitData:(NSString *)foodName expireDate:(NSString *)expireDate storageDate:(NSString *)storageDate deviceID:(NSString *)deviceID {
    CellModel *model = [CellModel modelWithName:foodName expireDate:expireDate storageDate:storageDate fdevice:deviceID];
    [arrayData addObject:model];
}
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
//food table
- (void)InitFoodTable{
    self.foodTable = [[UITableView alloc]initWithFrame:CGRectMake(5, self.sealerView.frame.size.height+10, self.sealerView.frame.size.width,screen_height*3/4-TabbarHeight) style:UITableViewStylePlain];
    self.foodTable.backgroundColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0];
    _foodTable.delegate = self;
    _foodTable.dataSource = self;
    _foodTable.hidden = YES;
    _foodTable.showsVerticalScrollIndicator = NO;
    _foodTable.layer.borderWidth = 0.3;
    //[_foodTable setSeparatorColor:[UIColor grayColor]];

    [self.rootView insertSubview:_foodTable atIndex:10];
}
//calorie table
- (void)InitCalorieTable{
    self.calorieTable = [[UITableView alloc]initWithFrame:CGRectMake(_poundView.frame.origin.x, _poundView.frame.origin.y+self.poundView.frame.size.height, _poundView.frame.size.width,screen_height-TabbarHeight-70-self.poundView.frame.size.height) style:UITableViewStylePlain];
    _calorieTable.delegate = self;
    _calorieTable.dataSource = self;
    _calorieTable.hidden = YES;
    _calorieTable.showsVerticalScrollIndicator = NO;
    //[_calorieTable setSeparatorColor:[UIColor grayColor]];
    [self.rootView addSubview:_calorieTable];
    cellCenter = self.calorieTable.center;
    [self addAction];
}
- (void)addAction{
    if (self.calorieData.count > 0) {
        [self.rootView setContentOffset:CGPointMake(0,self.poundView.frame.origin.y-StatusBarHeight) animated:YES];
    }
    self.calorieTable.hidden = NO;
    [self CalorieData];
    [_calorieTable reloadData];
    //NSInteger index = calorieData.count;
    if (self.calorieData.count*110 > self.calorieTable.frame.size.height) {
        [self.calorieTable setContentOffset:CGPointMake(0, 110*(self.calorieData.count-(int)self.calorieTable.frame.size.height/110))];
    }
}
//行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:_foodTable]) {
        return 100;
    }else if([tableView isEqual:_calorieTable]){
        return 110;
    }else{
        return 0;
    }
}
//每组多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:_foodTable]) {
        return arrayData.count;
    }else{
        NSLog(@"%lu",(unsigned long)self.calorieData.count);
        return self.calorieData.count;
    }
    
}
//多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
//每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:_foodTable]) {
        static NSString *cellIdentifier = @"cell";
            //初始化cell，并指定其类型
            SealerCell *cell = [tableView  dequeueReusableCellWithIdentifier:cellIdentifier];
            if (cell == nil) {
                //创建cell
                cell = [[SealerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            }
            NSInteger row = indexPath.row;
        cell.foodImgView.image = [self getImage:arrayData[row].foodName];
            //取消点击cell时显示的背景色
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.foodNameLabel.text =  arrayData[row].foodName;
        cell.storageLabel.font = [UIFont systemFontOfSize:10];
            cell.storageLabel.text = [NSString stringWithFormat:@"存储日期: %@",arrayData[row].storageDate];

            cell.expireLabel.font = [UIFont systemFontOfSize:10];
            cell.expireLabel.text =  [NSString stringWithFormat:@"有效日期: %@",arrayData[row].expireDate];
            NSArray *tag = @[arrayData[row].foodName,arrayData[row].device];
            //cell.checkBtn.accessibilityElements = tag;

            //添加点击手势
            UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cellAction:)];
        recognizer.accessibilityElements = tag;
            [cell addGestureRecognizer:recognizer];
            //[cell.checkBtn addTarget:self action:@selector(cellAction:) forControlEvents:UIControlEventTouchUpInside];
            //返回cell
            return cell;
    }else{
        static NSString *cellIndentify = @"cell";
        //初始化cell，并指定其类型
        CalorieTableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:cellIndentify];
        if (cell == nil) {
                //创建cell
            cell = [[CalorieTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentify];
        }
        NSInteger row = indexPath.row;
        cell.weight.tag = row;
        cell.weight.text = self.calorieData[row].weight;
        cell.calorie.text = self.calorieData[row].calorie;
        _weight = cell.weight;
        _weight.delegate = self;
            //取消点击cell时显示的背景色
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        [cell.select  addTarget:self action:@selector(showCategory:) forControlEvents:UIControlEventTouchUpInside];
        cell.select.tag = row;
        
        [cell.delete_cell addTarget:self action:@selector(DeleteCell:) forControlEvents:UIControlEventTouchUpInside];
        cell.delete_cell.tag = row;
        
        [cell.units addTarget:self action:@selector(changeUnits:) forControlEvents:UIControlEventTouchUpInside];
        cell.units.tag = 0;
            //返回cell
            return cell;
    }
}
/**cell的点击事件*/
- (void)cellAction:(UITapGestureRecognizer *)sender{
    FoodInfoViewController *info = [[FoodInfoViewController alloc]init];
    info.name = sender.accessibilityElements[0];
    info.deviceID = sender.accessibilityElements[1];
    info.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:info animated:YES];
    isUpdate = true;
}
#pragma mark - 点击事件
//扫描按钮
- (void)ScanAction{
    if (!isScan) {
        if (isExpand) {
            [self ExpandList];
        }
        [self startScan];
        [self.scanBtn setImage:[UIImage imageNamed:@"icon_finish"] forState:UIControlStateNormal];
        isScan = true;
    }else{
        [self.rootScanView removeFromSuperview];
        [self.scanBtn setImage:[UIImage imageNamed:@"icon_scan"] forState:UIControlStateNormal];
        isScan = false;
    }
}
#pragma mark - 计算卡路里
//更新卡路里
- (void)UpdateAndCalculateCalorie{
    CGFloat weight,calorie,SumofCalorie;
    SumofCalorie = 0.0;
    for (NSInteger i = 0; i < self.calorieData.count; i++) {
        weight = [self.calorieData[i].weight floatValue];
        calorie = [self.calorieData[i].calorie floatValue];
        SumofCalorie = SumofCalorie + (weight/100)*calorie;
//NSLog(@"weight=%f,calorie=%f,allcalorie=%f",weight,calorie,(weight/100)*calorie);
    }
    self.Allcalorie.text = [NSString stringWithFormat:@"%g",SumofCalorie];

}
//食物选择按钮
- (void)showCategory:(UIButton *)sender{
    NSLog(@"选择食物");
    current = sender.tag;
    CategoryViewController *category = [[CategoryViewController alloc]init];
    category.hidesBottomBarWhenPushed = YES;
    category.current = current;
    [self.navigationController pushViewController:category animated:YES];
    //isUpdate = true;
}
//删除记录按钮
- (void)DeleteCell:(UIButton *)sender{
    [self.rootView setContentOffset:CGPointMake(0,self.poundView.frame.origin.y-StatusBarHeight) animated:YES];
    NSLog(@"%ld",(long)sender.tag);
    NSLog(@"<><><><>%@<><><><><>",_weight.text);
    [self.calorieData removeObjectAtIndex:sender.tag];
    [self.calorieTable reloadData];
    [self UpdateAndCalculateCalorie];
}
//转换单位
- (void)changeUnits:(UIButton *)sender{
    switch (sender.tag) {
        case 0:
            [sender setTitle:@"g" forState:UIControlStateNormal];
            sender.tag = 1;
            break;
        case 1:
            //1oz=28.35g
            [sender setTitle:@"oz" forState:UIControlStateNormal];
            sender.tag = 2;
            break;
        case 2:
            //1lb=453.59g
            [sender setTitle:@"lb" forState:UIControlStateNormal];
            sender.tag = 0;
        default:
            break;
    }
}
#pragma mark - 扫码结果
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    [arrayData removeAllObjects];
    [session stopRunning];
    object = metadataObjects.firstObject;
    result = object.stringValue;
    NSLog(@"%@",result);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setFocusCursorWithPoint:self->object];
    });
    if ([result hasPrefix:@"FOSASealer"]) {
        [self SelectData];
    }else if(result != NULL){
        //[self setFocusCursorWithPoint:object];
        [self SystemAlert:@"This is not belong to FosaSealer!"];
    }
}
//查询数据库
- (void)SelectData{
    self.database = [SqliteManager InitSqliteWithName:@"Fosa.db"];
    NSString *sealerSql = [NSString stringWithFormat:@"select foodName,deviceName,aboutFood,expireDate,remindDate,storageDate,photoPath from Fosa3 where deviceName ='%@'",result];
    _stmt = [SqliteManager SelectDataFromTable:sealerSql database:self.database];
    if (_stmt != NULL) {
        NSLog(@"********");
        while (sqlite3_step(_stmt) == SQLITE_ROW) {
            NSLog(@"^^^^^^^^^^^^^^");
            const char *food_name = (const char *)sqlite3_column_text(_stmt, 0);
            const char *device_name = (const char*)sqlite3_column_text(_stmt,1);
            const char *about_food = (const char*)sqlite3_column_text(_stmt, 2);
            const char *expired_date = (const char *)sqlite3_column_text(_stmt,3);
            const char *remind_date = (const char*)sqlite3_column_text(_stmt,4);
            const char *storage_date = (const char*)sqlite3_column_text(_stmt, 5);
            const char *photo_path = (const char *)sqlite3_column_text(_stmt,6);
            NSLog(@"查询到数据1:%@",[NSString stringWithUTF8String:food_name]);
            NSLog(@"查询到数据2:%@",[NSString stringWithUTF8String:device_name]);
            NSLog(@"查询到数据3:%@",[NSString stringWithUTF8String:about_food]);
            NSLog(@"查询到数据4:%@",[NSString stringWithUTF8String:expired_date]);
            NSLog(@"查询到数据5:%@",[NSString stringWithUTF8String:remind_date]);
            NSLog(@"查询到数据6:%@",[NSString stringWithUTF8String:storage_date]);
            NSLog(@"查询到数据7:%@",[NSString stringWithUTF8String:photo_path]);
            [self InitData:[NSString stringWithUTF8String:food_name] expireDate:[NSString stringWithUTF8String:expired_date] storageDate:[NSString stringWithUTF8String:storage_date] deviceID:[NSString stringWithUTF8String:device_name]];
            }
        [self.foodTable reloadData];
        [self ExpandList];
        [self StopAndRelease];
    }else{
        NSLog(@"查询失败");
    }
    if (arrayData.count == 0 && result != NULL) {
        [self SystemAlert:@"此二维码的设备没有食物记录"];
    }
}
//弹出系统提示
- (void)SystemAlert:(NSString *)message{
    [self.session stopRunning];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notification" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.focusCursor.alpha = 0;
        [self.session startRunning];
    }]];
    [self presentViewController:alert animated:true completion:nil];
}
- (void)StopAndRelease{
    [self.session stopRunning];
    [self.scanBtn setImage:[UIImage imageNamed:@"icon_scan"] forState:UIControlStateNormal];
    isScan = false;
}
#pragma mark - 退出键盘
-(void)StopEdit:(UITapGestureRecognizer *)gestureRecognizer
{
    [self.view endEditing:YES];
}
-(void)keyboardWillShow:(NSNotification *)noti{
    NSLog(@"键盘弹出来了");
}
-(void)keyboardWillHide:(NSNotification *)noti{
    [self.rootView setContentOffset:CGPointMake(0,self.poundView.frame.origin.y-StatusBarHeight) animated:YES];
    NSLog(@"键盘被收起来了");
}

//点击文本框，弹出键盘时的监听
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    NSLog(@"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~%lu",textField.tag);
    NSInteger index = textField.tag;
    if (textField.tag>3) {
        index = 4;
    }
    //设置底层视图滚动位置
       [self.rootView setContentOffset:CGPointMake(0,self.poundView.frame.origin.y+self.poundView.frame.size.height+index*110-StatusBarHeight) animated:YES];
}
//点击软键盘返回键退出解盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    NSLog(@"收回键盘");
    [self.weight resignFirstResponder];
    return YES;
}
//监听文本内容变化
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //得到输入框的内容
    NSString *toBeString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    //限制小数点的输入次数
    NSArray *array = [toBeString componentsSeparatedByString:@"."];
    NSInteger count = [array count]-1;
    if (count>=2 && [string isEqualToString:@"."]) {
        return NO;
    }
    //限制小数点后的位数
    NSInteger flag=0;
    //const NSInteger limited =[self.currentModel.decimal integerValue];
    for (NSInteger i = toBeString.length-1; i>=0; i--) {
        if ([toBeString characterAtIndex:i] == '.') {
            if (flag > 4) {
                return NO;
            }
            break;
        }
        flag++;
    }
    // 限制第一位不能是小数点
    if(textField.text.length == 0 && [string isEqualToString:@"."]) {
        return NO;
    }
    // 限制"-"负数符号不能在中间，只能在第一位
    if(textField.text.length > 0 && [string isEqualToString:@"-"]) {
        return NO;
    }
    //限定输入值的范围
    //CGFloat maxValue=[self.currentModel.value_max floatValue];
    //CGFloat minValue=[self.currentModel.value_min floatValue];
    //当前值
//    CGFloat currentValue=[toBeString floatValue];
//
//    if (currentValue>=minValue&&currentValue<=maxValue) {
//        return YES;
//    }else{
//        return NO;
//    }
    return YES;
}
//输入结束
- (void)textFieldDidEndEditing:(UITextField *)textField{
    self.calorieData[textField.tag].weight = textField.text;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if (isScan) {
        isScan = false;
        [self.scanBtn setImage:[UIImage imageNamed:@"icon_scan"] forState:UIControlStateNormal];
    }
    [self StopAndRelease];
    [self.previewLayer removeFromSuperlayer];
    [self.rootScanView removeFromSuperview];
    self.navigationController.navigationBar.hidden = NO;
}
@end
