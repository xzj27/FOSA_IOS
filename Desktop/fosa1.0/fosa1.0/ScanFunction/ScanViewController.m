//
//  ScanViewController.m
//  fosa1.0
//
//  Created by hs on 2019/10/16.
//  Copyright © 2019 hs. All rights reserved.
//

#import "ScanViewController.h"
#import "FosaAlertView.h"
#import "CircleAlertView.h"
#import "AlertModel.h"
#import "AddViewController.h"
#import "ResultViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <sqlite3.h>
#import "Fosa_Queue.h"
@interface ScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,UIImagePickerControllerDelegate>{
    //用于初始化数据模型的数据
    NSString *food,*fdevice,*expire,*remind,*photoPath;
    
    //GCD定时器
    dispatch_source_t _timer;
}
@property (nonatomic, strong) AVCaptureDevice * device;
@property (nonatomic, strong) AVCaptureDeviceInput * input;
@property (nonatomic, strong) AVCaptureMetadataOutput * output;//元数据输出流，需要指定他的输出类型及扫描范围
@property (nonatomic, strong) AVCaptureSession * session; //AVFoundation框架捕获类的中心枢纽，协调输入输出设备以获得数据
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * previewLayer;//展示捕获图像的图层，是CALayer的子类

@property (nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;//照片输出流

@property (nonatomic, weak)  UIImageView *activeImage;       //扫描框
@property (nonatomic,strong) UIImageView *scanImage;         //扫描线
@property (nonatomic,strong) UIView *maskView;               //扫描面板
@property (nonatomic,strong) UIImageView *focusCursor,*focusCursor1,*focusCursor2;       //标记二维码的位置
@property (nonatomic ,strong) UILabel *label,*myQrcode;      //提示信息，选取我的二维码
@property (nonatomic,strong) UIButton *flashBtn;             //闪光灯
@property (nonatomic,strong) UISlider *ZoomSlider;           //用于放大缩小视图

@property(nonatomic,assign) CGFloat scale;      //记录上一次放大的倍数；
@property(nonatomic,assign) int count;          //统计弹窗的个数
@property(nonatomic,assign) BOOL isGetResult;   //判断是否读取到二维码信息

//扫描结果
@property(nonatomic,strong)NSMutableArray<NSString *> *array;   //save the content of the qrcode
@property(nonatomic,strong)NSMutableArray<AVMetadataMachineReadableCodeObject *> *AlertCodeArray; //save the object of the qrcode
@property(nonatomic,strong)NSMutableArray<AVMetadataMachineReadableCodeObject *> *QRcode; //存储所有识别过的二维码
//队列
@property (nonatomic,strong) Fosa_Queue *codeQueue;
@property (nonatomic,assign) CGFloat centerPoint;
@property (nonatomic,assign) int flag;

@property (nonatomic,weak) UIImage *QRimage;

//自定义内容弹框
//每次扫描多个
@property (nonatomic,strong) FosaAlertView *contentAlertView;
@property (nonatomic,strong) CircleAlertView *circleAlertView1,*circleAlertView2,*circleAlertView3;
// 用于禁止与用户交互的view
@property (nonatomic,weak) UIView *forbidview;
//每次扫描一个
@property (nonatomic,strong) FosaAlertView *fosaAlertView;
@property(nonatomic,assign) int ScanModel;      //determine the current scanning model:0 for which Scan QRCode for everytime,1 for which scan three or four QrCode for every time

//数据库查询相关
@property(nonatomic,assign)sqlite3 *database;
//结果集定义
@property(nonatomic,assign)sqlite3_stmt *stmt;
@end

@implementation ScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self initScanning];
    [self initScan];
    // 开始动画，扫描条上下移动
    [self performSelectorOnMainThread:@selector(timerFired) withObject:nil waitUntilDone:NO];
    
    // 添加监听->APP从后台返回前台，重新扫描
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionStartRunning:) name:UIApplicationDidBecomeActiveNotification object:nil];
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self sessionStartRunning:nil];
}
//扫描框
-(void)initScan{
    //两个按钮的父类view
        UIView *rightButtonView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 50)];
    //识别本地图片按钮
        UIButton *historyBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        [rightButtonView addSubview:historyBtn];
        [historyBtn setImage:[UIImage imageNamed:@"icon_qrcode"] forState:UIControlStateNormal];
        [historyBtn addTarget:self action:@selector(selectPhoto) forControlEvents:UIControlEventTouchUpInside];
        
        //转换扫码模式按钮
        UIButton *mainAndSearchBtn = [[UIButton alloc] initWithFrame:CGRectMake(50, 0, 50, 50)];
        [rightButtonView addSubview:mainAndSearchBtn];
        [mainAndSearchBtn setImage:[UIImage imageNamed:@"icon_changescanmodel"] forState:UIControlStateNormal];
        [mainAndSearchBtn addTarget:self action:@selector(changeScanModel) forControlEvents:UIControlEventTouchUpInside];
         
        //把右侧的两个按钮添加到rightBarButtonItem
        UIBarButtonItem *rightCunstomButtonView = [[UIBarButtonItem alloc] initWithCustomView:rightButtonView];
        self.navigationItem.rightBarButtonItem = rightCunstomButtonView;
    
     //聚焦图片
    UIImageView *focusCursor = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    focusCursor.alpha = 0;
    focusCursor.image = [UIImage imageNamed:@"camera_focus_red"];

//    UIImageView *focusCursor1 = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
//    focusCursor1.alpha = 0;
//    focusCursor1.image = [UIImage imageNamed:@"icon_code"];
//
//    UIImageView *focusCursor2 = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
//    focusCursor2.alpha = 0;
//    focusCursor.image = [UIImage imageNamed:@"icon_code"];//camera_focus_red
       
    [self.view addSubview:focusCursor];
   // [self.view addSubview:focusCursor1];
   // [self.view addSubview:focusCursor2];
    _focusCursor = focusCursor;
   // _focusCursor1 = focusCursor1;
    //_focusCursor2 = focusCursor2;
    
    [self setScanScale:0];
}
//this fuction for setting the scanning scale
-(void)setScanScale:(int)scanmodel{
    //移除原来的视图
    [_scanImage removeFromSuperview];
    [_activeImage removeFromSuperview];
    [_maskView removeFromSuperview];
    [_ZoomSlider removeFromSuperview];
    [_flashBtn removeFromSuperview];
    
    //根据扫描模式设置扫描框
    if (scanmodel == 0) {
        [self ScanOneByOne_ScanView];
    }else if(scanmodel == 1){
        [self ScanMore_ScanView];
    }
}
//多个扫码模式
-(void)ScanMore_ScanView{
    CGFloat mainWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat mainHeight =  [UIScreen mainScreen].bounds.size.height;
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    CGFloat imageX = mainWidth*0.45;
    CGFloat imageY = navHeight+80;
    self.scanImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"saoyisao@3x"]];
    _scanImage.frame = CGRectMake(imageX, imageY,mainWidth*0.55-10, mainHeight-navHeight-160);
    [self.view addSubview:_scanImage];
                 // 左右移动的扫描条
    //             UIImageView *activeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"saoyisao-3@3x"]];
    //             activeImage.frame = CGRectMake(imageX, imageY, self.view.frame.size.width-20, 4);
    //             [self.view addSubview:activeImage];
    //             self.activeImage = activeImage;
              //添加全屏的黑色半透明蒙版
    _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width+10, self.view.frame.size.height)];
    _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [self.view addSubview:_maskView];
            //从蒙版中扣出扫描框那一块,这块的大小尺寸将来也设成扫描输出的作用域大小
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [maskPath appendPath:[[UIBezierPath bezierPathWithRect:CGRectMake(imageX, imageY,mainWidth*0.55-10, mainHeight-navHeight-160)] bezierPathByReversingPath]];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = maskPath.CGPath;
    _maskView.layer.mask = maskLayer;
                
    _ZoomSlider = [[UISlider alloc] initWithFrame:CGRectMake(imageX,imageY+(mainHeight-navHeight-60)/2,mainHeight-navHeight-60,20)];
    [self.view addSubview:_ZoomSlider];
    _ZoomSlider.minimumValue = 0;
    _ZoomSlider.maximumValue = 100;
    _ZoomSlider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    [_ZoomSlider addTarget:self action:@selector(ZoomSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    
    //扫码范围
    CGRect intertRect = [_previewLayer metadataOutputRectOfInterestForRect:CGRectMake(imageX, imageY,mainWidth*0.55-10, mainHeight-navHeight-160)];
    _output.rectOfInterest = intertRect;
}
//单个扫码模式
-(void)ScanOneByOne_ScanView{
    CGFloat imageX = self.view.frame.size.width*0.15;
    CGFloat imageY = self.view.frame.size.width*0.15+30;         // 扫描框中的四个边角的背景图
         self.scanImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"saoyisao@3x"]];
         _scanImage.frame = CGRectMake(imageX, imageY, self.view.frame.size.width*0.7, self.view.frame.size.width*0.7);
         [self.view addSubview:_scanImage];

         // 上下移动的扫描条
         UIImageView *activeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"saoyisao-3@3x"]];
         activeImage.frame = CGRectMake(imageX, imageY, self.view.frame.size.width*0.7, 4);
         [self.view addSubview:activeImage];
         self.activeImage = activeImage;

      //添加全屏的黑色半透明蒙版
        self.maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width+10, self.view.frame.size.height)];
        _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        [self.view addSubview:_maskView];
        //从蒙版中扣出扫描框那一块,这块的大小尺寸将来也设成扫描输出的作用域大小
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
        [maskPath appendPath:[[UIBezierPath bezierPathWithRect:CGRectMake(imageX,imageY, self.view.frame.size.width*0.7, self.view.frame.size.width*0.7)] bezierPathByReversingPath]];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.path = maskPath.CGPath;
        _maskView.layer.mask = maskLayer;
    
    //闪光灯
    self.flashBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2-20, CGRectGetMaxY(_scanImage.frame)-45, 40, 40)];
    _flashBtn.layer.cornerRadius = _flashBtn.frame.size.width/2;
    _flashBtn.clipsToBounds = YES;
    [_flashBtn setBackgroundImage:[UIImage imageNamed:@"shanguangdeng-an.png"] forState:(UIControlStateNormal)];
    [_flashBtn addTarget:self action:@selector(openFlash:) forControlEvents:UIControlEventTouchUpInside];
    
    //设置有效扫描区域
    CGRect intertRect = [_previewLayer metadataOutputRectOfInterestForRect:CGRectMake(imageX, imageY, self.view.frame.size.width*0.7, self.view.frame.size.width*0.7)];
    _output.rectOfInterest = intertRect;
    
    //添加UISlider用于放大和缩小视图
    _ZoomSlider = [[UISlider alloc] initWithFrame:CGRectMake(imageX,imageY+self.view.frame.size.width*0.7,self.view.frame.size.width*0.7,20)];
    [self.view addSubview:_ZoomSlider];
    _ZoomSlider.minimumValue = 0;
    _ZoomSlider.maximumValue = 100;
    [_ZoomSlider addTarget:self action:@selector(ZoomSliderValueChanged) forControlEvents:UIControlEventValueChanged];
}

-(void)changeScanModel{
    if (_ScanModel == 0){//扫单个变成扫多个
        [self setScanScale:1];
        [_fosaAlertView removeFromSuperview];
        [self sessionStopRunning];
        _ScanModel = 1;
        self.focusCursor.alpha = 0;
    }else if(_ScanModel == 1){  //扫多个变成扫单个
        [self setScanScale:0];
        [self.codeQueue removeAllObjects];
        _ScanModel = 0;
        self.focusCursor.alpha = 0;
        [self removeView];
        [self sessionStopRunning];
    }
}
//初始化二维码扫描设置
-(void) initScanning{
    //存储结果
    self.array = [[NSMutableArray alloc]init];
    self.AlertCodeArray = [[NSMutableArray alloc]init];
    self.QRcode = [[NSMutableArray alloc]init];
    //用于存储可读码的队列
    self.codeQueue = [[Fosa_Queue alloc]initWithCapacity:3];
    
    //扫码模式,默认扫一个
    self.ScanModel = 0;
    //notification window
    self.circleAlertView1 = [[CircleAlertView alloc] init];
    self.circleAlertView2 = [[CircleAlertView alloc] init];
    self.circleAlertView3 = [[CircleAlertView alloc] init];
    //  放大倍数
    self.scale = 1.0;
    self.count = 0;
    self.flag = 0;
    self.isGetResult = false;//初始化时还没有得到扫描结果
    //配置二维码扫描
    //默认使用后置摄像头进行扫描,使用AVMediaTypeVideo表示视频
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //检查相机是否有摄像头
    if(!_device){
        NSLog(@"该设备没有摄像头");
        return;
    }
    //设备输入 初始化
    _input = [[AVCaptureDeviceInput alloc]initWithDevice:_device error:nil];
    //设备输出 初始化，并设置代理和回调，当设备扫描到数据时通过该代理输出队列，一般输出队列都设置为主队列，也是设置了回调方法执行所在的队列环境
    _output = [[AVCaptureMetadataOutput alloc]init];
    dispatch_queue_t queue = dispatch_queue_create("myqueue", NULL);
    [_output setMetadataObjectsDelegate:self queue:queue];

    //视频流输出初始化与设置
    AVCaptureVideoDataOutput *VideoOutput = [[AVCaptureVideoDataOutput alloc]init];
    [VideoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    VideoOutput.videoSettings =    [NSDictionary dictionaryWithObject:
                        [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                        forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    
    //会话 初始化，通过 会话 连接设备的 输入 输出，并设置采样质量为高
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPreset1920x1080];
    
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
    if ([_session canAddInput:_input]) {
        [_session addInput:_input];
    }else{
        NSLog(@"找不到摄像头设备");
    }
    if ([_session canAddOutput:_output]) {
        [_session addOutput:_output];
    }
    if([_session canAddOutput:VideoOutput]){
        [_session addOutput:VideoOutput];
    }
//指定设备的识别类型
    _output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypePDF417Code];
    //预览层初始化，self.session负责驱动input进行信息的采集，layer负责把图像渲染显示
//预览层的区域设置为整个屏幕，这样可以方便我们进行移动二维码到扫描区域,在上面我们已经对我们的扫描区域进行了相应的设置
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:_session];

    //_previewLayer.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width+20, [UIScreen mainScreen].bounds.size.height*0.8);
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    self.previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:_previewLayer];

    //开始捕获
    [_session startRunning];
    CGFloat ScreenWidth = self.view.frame.size.width;
    //设置扫描作用域范围(中间透明的扫描框)
    CGRect intertRect = [_previewLayer metadataOutputRectOfInterestForRect:CGRectMake(ScreenWidth*0.15, ScreenWidth*0.15+64, ScreenWidth*0.7, ScreenWidth*0.7)];
    _output.rectOfInterest = intertRect;
    [_input.device lockForConfiguration:nil];
    
    self.view.clipsToBounds = YES;
    self.view.layer.masksToBounds = YES;
    
    //自动白平衡
    if([_device isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]){
        [_input.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
    }
    
    //判断并开启自动对焦功能
    if(_device.isFocusPointOfInterestSupported &&[_device isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
        [_input.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    }
    //自动曝光
    if([_device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
        [_input.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [_input.device unlockForConfiguration];
    
    //用于定时检查是否扫描到二维码以及扫描到二维码之后定时清空数组
    
    //设置时间间隔
    NSTimeInterval period = 5.f;
    dispatch_queue_t queue1 = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue1);
    dispatch_source_set_timer(_timer, dispatch_walltime(NULL, 0), period*NSEC_PER_SEC, 0);
    //事件回调
    dispatch_source_set_event_handler(_timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"开始判断");
            if (self.isGetResult == false) {
                [self.device lockForConfiguration:nil];
                if(self.scale >= [self maxZoomFactor]){
                    //NSLog(@"######%f",self.scale);
                    self.scale = [self maxZoomFactor];
                    dispatch_source_cancel(self->_timer);
                    [self NotifyWarn];
                    [self ResetZoom];
                }else if(self.scale >4){
                    //NSLog(@"more than 4");
                    self.scale = self.scale+0.5;
                    self.ZoomSlider.value = (self.scale-1)*10;
                    NSLog(@"-----%f",self.scale);
                }else{
                    if(self.scale != 1){
                       self.scale = self.scale + 0.8;
                       self.ZoomSlider.value = (self.scale-1)*10;
                    }else{self.scale = 1.01;}
                }
                [self.device setVideoZoomFactor:self.scale];
                [self.device unlockForConfiguration];
            }else{
//                NSLog(@"stop");
//                dispatch_source_cancel(_timer);
                if (self.array.count!=0&&self.AlertCodeArray.count != 0){
                    //[self.array removeAllObjects];
                    //[self.AlertCodeArray removeAllObjects];
                }
            }
        });
    });
    //开启定时器
    dispatch_resume(_timer);
}
//若长时间识别不出二维码内容则通知用户二维码失效或者距离太远识别不出
-(void)NotifyWarn{
    NSLog(@"Warning");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Warning" message:@"找不到能识别的二维码" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:true completion:nil];
}

-(void)ResetZoom{
    NSLog(@"复原镜头");
        [_device lockForConfiguration:nil];
        [_device setVideoZoomFactor:1.0];
        [_device unlockForConfiguration];
}
//ZoomSlider的拖动事件响应
-(void)ZoomSliderValueChanged{
    
    [_device lockForConfiguration:nil];
    self.scale = (_ZoomSlider.value/100)*10+1;
    [_device setVideoZoomFactor:self.scale];
    [_device unlockForConfiguration];
}

//打开闪光灯
-(void)openFlash:(UIButton *)sender{
    [_device lockForConfiguration:nil];
    if(_device.torchMode == AVCaptureTorchModeOff){
         NSLog(@"open flash");
        [_device setTorchMode:AVCaptureTorchModeOn];
        [_flashBtn setBackgroundImage:[UIImage imageNamed:@"shanguangdeng-liang.png"] forState:(UIControlStateNormal)];
    }else{
         NSLog(@"close flash");
        [_device setTorchMode:AVCaptureTorchModeOff];
        [_flashBtn setBackgroundImage:[UIImage imageNamed:@"shanguangdeng-an.png"] forState:(UIControlStateNormal)];
        // [self.flashBtn removeFromSuperview];
    }
    [_device unlockForConfiguration];
}
- (void)sessionStartRunning:(NSNotification *)notification {
    if (_session != nil) {
        // AVCaptureSession开始工作
        [_session startRunning];
        [self ResetZoom];
        //开始动画
        [self performSelectorOnMainThread:@selector(timerFired) withObject:nil waitUntilDone:NO];
    }
}
- (void)sessionStopRunning{
    //[self.session stopRunning];
    [self ResetZoom];
    [self.array removeAllObjects];
    [self.AlertCodeArray removeAllObjects];
}
/**
 *  加载动画
 */
-(void)timerFired {
    //    [self.activeImage.layer addAnimation:[self moveY:3 Y:[NSNumber numberWithFloat:ScreenWidth*0.7-4]] forKey:nil];
    [self.activeImage.layer addAnimation:[self moveY:2.5 Y:[NSNumber numberWithFloat:(self.view.frame.size.width*0.7-4)]] forKey:nil];
}
/**
 *  扫描线动画
 *
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
-(CGFloat)minZoomFactor{
    CGFloat minZoomFactor = 1.0;
    if(@available(iOS 11.0,*)){
        minZoomFactor = self.device.minAvailableVideoZoomFactor;
    }
    return minZoomFactor;
}
-(CGFloat)maxZoomFactor{
    CGFloat maxZoomFactor = self.device.activeFormat.videoMaxZoomFactor;
    if(@available(iOS 11.0,*)){
        maxZoomFactor = self.device.maxAvailableVideoZoomFactor;
        NSLog(@"最大放大倍数：%lf",maxZoomFactor);
    }
    if(maxZoomFactor > 8.0){
        maxZoomFactor = 8.0;
    }
    return maxZoomFactor;
}
- (AVCaptureConnection *)connectionWithMediaType:(NSString *)mediaType fromConnections:(NSArray *)connections
{
    for ( AVCaptureConnection *connection in connections ) {
        for ( AVCaptureInputPort *port in [connection inputPorts] ) {
            if ( [[port mediaType] isEqual:mediaType] ) {
                return connection;
            }
        }
    }
    return nil;
}
-(CGPoint)getCenterOfQRcode:(AVMetadataMachineReadableCodeObject *)objc
{
        CGPoint center = CGPointZero;
    // 扫码区域的坐标计算是以横屏为基准，应以右上角为（0，0），根据二维码的同一个点的y坐标来进行判断每个二维码的位置关系
        NSArray *array = objc.corners;
         //NSLog(@"cornersArray = %@",array);
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
        // NSLog(@"X:%f -- Y:%f",point4.x,point4.y);
        
    return center;
}
- (CGFloat)getVideoCenter:(AVMetadataMachineReadableCodeObject *)objc
{
    // 扫码区域的坐标计算是以横屏为基准，应以右上角为（0，0），根据二维码的同一个点的y坐标来进行判断每个二维码的位置关系
    NSArray *array = objc.corners;  //二维码四个角点的坐标
    CGPoint point = CGPointZero;
    int index = 0;
    CFDictionaryRef dict = (__bridge CFDictionaryRef)(array[index++]);
    // 把字典转换为点，存在point里，成功返回true 其他false
    CGPointMakeWithDictionaryRepresentation(dict, &point);
    CGPoint point2 = CGPointZero;
    CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[index++], &point2);
    //CGFloat center_x = (point.x+point2.x)/2;
    CGPoint point3 = CGPointZero;
    CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[index++], &point3);
    //CGFloat center_y = (point2.y+point3.y)/2;

    CGPoint point4 = CGPointZero;
    CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[index++], &point4);
     return point.x;
}

#pragma mask - 原本用于点击放大镜头
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    //UITouch *touch = [touches anyObject];
    //[self processTouch:touch];
}
-(void)processTouch:(UITouch *)touch{
    //获取点击处的坐标
    CGPoint touchPoint = [touch locationInView:self.view];
    CGFloat x = touchPoint.x;
    CGFloat y = touchPoint.y;
    NSLog(@"%f,%f",x,y);
    if(x > self.view.frame.size.width*0.15 && x<self.view.frame.size.width*0.85){
        if(y > self.view.frame.size.width*0.15+64 && y<self.view.frame.size.width*0.85+64){
            self.scale = _scale+0.8;
            if(self.scale > [self maxZoomFactor]){
                self.scale = [self maxZoomFactor];
            }
            [self.device lockForConfiguration:nil];
            [_device setVideoZoomFactor:self.scale];
            [self.device unlockForConfiguration];
        }
    }
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate
//wo can get the data in this callback function
-(void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    //用于标志每次捕获是否识别到新的二维码
    _flag = 0;
    NSInteger count = 3;
    if(metadataObjects.count > 0) {
       NSString *content;
        AVMetadataMachineReadableCodeObject *mobject = metadataObjects.firstObject;
        if([[mobject type] isEqualToString:AVMetadataObjectTypeQRCode]){
            //[self performSelectorOnMainThread:@selector(setFocusCursorWithPoint:) withObject:mobject waitUntilDone:NO];      //在主线程中标记二维码的位置（还不够准确）
            self.isGetResult = true;
            NSString *result = mobject.stringValue;
            if(result != nil && [result hasPrefix:@"Fosa"]){

                if([_array containsObject:result]==0){
                    }
               }
        }
       // 识别多个码的信息，并将每一个二维码的内容存放在不重复的数组中
            for(AVMetadataObject *object in metadataObjects){
                //如果是可读的码的对象
                if ([object isKindOfClass:[AVMetadataMachineReadableCodeObject class]]){
                    content = [(AVMetadataMachineReadableCodeObject *) object stringValue];
                    //检查二维码信息是否已经被记录，否的话则添加记录
                    if([_array containsObject:content]==0){
    
                        //播放提示音
                        [self ScanSuccess:@"ding.wav"];
                        
                        _flag++;
                        [_array addObject:content]; //二维码内容添加
                        [_AlertCodeArray addObject:(AVMetadataMachineReadableCodeObject *) object];//二维码对象添加
                        [_QRcode addObject:(AVMetadataMachineReadableCodeObject *)object];
                        
                        //队列操作
                                           if (_codeQueue.size < 3 ) {
                                               [_codeQueue enqueue:(AVMetadataMachineReadableCodeObject *) object];
                                               NSLog(@"*****--%@",content);
                                           }else if(_codeQueue.size == 3){
                                               [_codeQueue dequeue];
                                               [_codeQueue enqueue:(AVMetadataMachineReadableCodeObject *) object];
                                               NSLog(@"%@",_codeQueue.firstObject.stringValue);
                                           }
                        
                        
                       // NSLog(@"这是扫描到的内容%@",content);
                    
                        if (_ScanModel == 0) {
                            //扫描单个二维码模式
                            if (self.food_photo == nil) {//UIImage对象为空说明并不是在添加过程进行扫码
                                 [self performSelectorOnMainThread:@selector(setFocusCursorWithPoint:) withObject:(AVMetadataMachineReadableCodeObject *)object waitUntilDone:NO];      //在主线程中标记二维码的位置（还不够准确）
                                if([content hasPrefix:@"http://"]){
                                                    //打开这个链接
                                    [self performSelectorOnMainThread:@selector(OpenURL:) withObject:content waitUntilDone:NO];
                                }else if([content hasPrefix:@"Fosa"]||[content hasPrefix:@"FS9"]){
                                            [self performSelectorOnMainThread:@selector(showOneMessage:) withObject:content waitUntilDone:NO]; //在主线程中
                                }else{
                                    [self performSelectorOnMainThread:@selector(JumpToResult:) withObject:content waitUntilDone:NO];
                                }
                            }else{  //UIImage不为空则说明现在正处于添加功能中拍照完成后的扫码阶段
                                 //[self performSelectorOnMainThread:@selector(setFocusCursorWithPoint:) withObject:(AVMetadataMachineReadableCodeObject *)object waitUntilDone:NO];
                                if([content hasPrefix:@"FS9"]||[content hasPrefix:@"Fosa"]){
                                    //判断所扫描的二维码属于fosa产品
                                     [self performSelectorOnMainThread:@selector(JumpToAdd:) withObject:content waitUntilDone:NO];
                                }else{
                                    NSString *message = [NSString stringWithFormat:@"this QRcode does not belong to FOSA.  Its content is %@",content];
                                    [self performSelectorOnMainThread:@selector(SystemAlert:) withObject:message waitUntilDone:NO];
                                }
                            }
                        }
                    }
                }
            }
        //[self performSelectorOnMainThread:@selector(stopScanning) withObject:nil waitUntilDone:NO];
        //对数组的二维码内容，按照位置进行排序,展示多个
        if (_flag>0 && _ScanModel == 1) {
            self.count = 0;
            [self performSelectorOnMainThread:@selector(removeView) withObject:nil waitUntilDone:NO];
            for (int i = 0; i < [_codeQueue size]-1; i++) {
                for (int j = i+1; j < [_codeQueue size]; j++) {
                    if ([self getVideoCenter:[_codeQueue returnArray][i]] > [self getVideoCenter:[_codeQueue returnArray][j]] ) {
                        AVMetadataMachineReadableCodeObject *temp = [_codeQueue returnArray][i];
                        [_codeQueue returnArray][i] = [_codeQueue returnArray][j];
                        [_codeQueue returnArray][j] = temp;
                    }
                }
            }
            if ([_codeQueue size] < count) {
                count = [_codeQueue size];
            }
            for (int k = 0;k < count;k++) {
                //NSLog(@"%@",_array[k]);
                [self performSelectorOnMainThread:@selector(setFocusCursorWithPoint:) withObject:[_codeQueue returnArray][k] waitUntilDone:NO];
                [self performSelectorOnMainThread:@selector(showMoreMessage:) withObject:[_codeQueue returnArray][k] waitUntilDone:NO];
            }
        }
    }
}
/*
 获取环境光亮数值，判断是否打开闪光灯
 */
#pragma mark- AVCaptureVideoDataOutputSampleBufferDelegate的方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
   // NSLog(@"%f",brightnessValue);
    // 根据brightnessValue的值来打开和关闭闪光灯
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    BOOL result = [device hasTorch];// 判断设备是否有闪光灯
    if ((brightnessValue < -1) && result) {
        //提示打开闪光灯
        [self.view insertSubview:_flashBtn atIndex:10];
    }else if((brightnessValue > -1) && result) {
        if(device.torchMode == AVCaptureTorchModeOff){
            [self.flashBtn removeFromSuperview];
        }
    }
    
    //判断每一帧图片中是否存在矩形
   // UIImage *buffer_image = [self imageFromSampleBuffer:sampleBuffer];
   // [self analyseRectImage:buffer_image];
}

// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
 
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
 
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
 
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
 
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
      bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);

    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    // Create an image object from the Quartz image
    UIImage *image = [UIImage imageWithCGImage:quartzImage];
    // Release the Quartz image
    CGImageRelease(quartzImage);
    return (image);
}
//跳转到添加界面
-(void)JumpToAdd:(NSString *)massage{
    AddViewController *add = [[AddViewController alloc]init];
    
    CGFloat headerWidth = [UIScreen mainScreen].bounds.size.width-20;
    CGFloat headerheight = [UIScreen mainScreen].bounds.size.height/3;
    
    add.imageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(15, headerheight/4-5,headerWidth*2/3,headerheight*3/4-5)];
    add.imageView1.image = self.food_photo;
    add.imageView1.backgroundColor = [UIColor redColor];
    add.food_image = [[UIImage alloc]init];
    add.food_image = self.food_photo;
    
    add.deviceName = [[UITextView alloc]initWithFrame:CGRectMake(15, 0,headerWidth/2, headerheight/4-5)];
    add.deviceName.backgroundColor = [UIColor clearColor];
    add.deviceName.textColor = [UIColor blackColor];
    add.deviceName.text = massage;
    [add.headerView addSubview:add.deviceName];
    [add.headerView addSubview:add.imageView1];
    
    //add.hidesBottomBarWhenPushed = Yes;
    [self.navigationController pushViewController:add animated:YES];
    
}
//跳转到结果界面
-(void)JumpToResult:(NSString *)message{
    ResultViewController *result = [[ResultViewController alloc]init];
    result.hidesBottomBarWhenPushed = YES;
    result.resultLabel = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/4, [UIScreen mainScreen].bounds.size.height/2, [UIScreen mainScreen].bounds.size.width/2,50)];
    result.resultLabel.font = [UIFont systemFontOfSize:20];
    result.resultLabel.textAlignment = NSTextAlignmentCenter;
    result.resultLabel.textColor = [UIColor redColor];
    result.resultLabel.text = message;
    [self.navigationController pushViewController:result animated:YES];
}

//扫描成功的提示音
-(void)ScanSuccess:(NSString *)name{
    
        NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
        NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
        SystemSoundID soundID = 0;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
        AudioServicesPlaySystemSound(soundID);//播放音效
}

//打开扫描到的网页
-(void)OpenURL:(NSString *)url{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}
//弹出系统提示
-(void)SystemAlert:(NSString *)message{
    [self.session stopRunning];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notification" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:true completion:^{
        //回掉
        NSLog(@"SystemAlert------我把捕获打开了");
        [self.session startRunning];
    }];
}

//生成弹窗，显示二维码内容
-(void)showMoreMessage:(AVMetadataMachineReadableCodeObject *)code{
    NSString *message = [code stringValue];
    CGFloat mainWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    CircleAlertView *circleAlertView = [[CircleAlertView alloc]init];
    circleAlertView.model = [self OpenAndSelectsql:message];
    circleAlertView.frame = CGRectMake(0,(self.count)*(mainWidth*0.55+5)+1.5*navHeight,mainWidth*0.55,mainWidth*0.55);
    circleAlertView.backgroundColor = [UIColor grayColor];
    //circleAlertView.layer.cornerRadius = mainWidth*0.2;
    circleAlertView.layer.masksToBounds = YES;
    
    circleAlertView.transform = CGAffineTransformMakeRotation(M_PI_2);
    //添加点击事件
    UITapGestureRecognizer *OpentapgestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [circleAlertView addGestureRecognizer:OpentapgestureRecognizer];
    OpentapgestureRecognizer.accessibilityValue = message;
    
    UITapGestureRecognizer *tapgestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(CloseAlert:)];
    //[_circleAlertView1.close addGestureRecognizer:tapgestureRecognizer];
    switch (_count) {
        case 0:_circleAlertView1 = circleAlertView;
            [self.view addSubview:_circleAlertView1];
            [_circleAlertView1.close addGestureRecognizer:tapgestureRecognizer];
            tapgestureRecognizer.view.tag = 0;
            break;
        case 1:_circleAlertView2 = circleAlertView;
            [self.view addSubview:_circleAlertView2];
            [_circleAlertView2.close addGestureRecognizer:tapgestureRecognizer];
            tapgestureRecognizer.view.tag = 1;
            break;
        case 2:_circleAlertView3 = circleAlertView;
            [self.view addSubview:_circleAlertView3];
            [_circleAlertView3.close addGestureRecognizer:tapgestureRecognizer];
            tapgestureRecognizer.view.tag = 2;
            break;
        default:
            break;
    }
    self.count = (self.count+1)%3;
    NSLog(@"%d",self.count);
}

#pragma show one alertView with the content of the QrCode
-(void)showOneMessage:(NSString *)message{
    [self.session stopRunning];
    [_fosaAlertView removeFromSuperview];
    _fosaAlertView = [[FosaAlertView alloc] init];
    AlertModel *model =  [self OpenAndSelectsql:message];
    [_fosaAlertView setModel:model];
    _fosaAlertView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-250,[UIScreen mainScreen].bounds.size.width,250);
    //添加点击事件
    [_fosaAlertView.edited addTarget:self action:@selector(removeCurrentAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_fosaAlertView];
}

//remove fosaAlertView
-(void)removeView{
    NSLog(@"remove");
    [_circleAlertView1 removeFromSuperview];
    [_circleAlertView2 removeFromSuperview];
    [_circleAlertView3 removeFromSuperview];
    _circleAlertView1 = NULL;
    _circleAlertView2 = NULL;
    _circleAlertView3 = NULL;
}
#pragma 点击下方通知弹出具体内容
-(void)tapAction:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    UIView *forbid = [[UIView alloc]init];
    forbid.frame = self.view.frame;
    self.forbidview = forbid;
    [self.view addSubview:self.forbidview];
    _fosaAlertView = [[FosaAlertView alloc]init];
    _fosaAlertView.model = [self OpenAndSelectsql:tap.accessibilityValue];
    _fosaAlertView.frame = CGRectMake(0, (self.view.frame.size.height-self.view.frame.size.width)*2/3, self.view.frame.size.width, self.view.frame.size.width*3/4);
    //视图顺时针旋转90度
    _fosaAlertView.transform = CGAffineTransformMakeRotation(M_PI/2);
    //给内容弹窗的关闭按钮添加点击动作盒响应
    [_fosaAlertView.edited addTarget:self action:@selector(removeCurrentAlert) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_fosaAlertView];
}

-(void)CloseAlert:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    if (tap.view.tag == 0) {
        [_circleAlertView1 removeFromSuperview];
    }else if (tap.view.tag == 1){
        [_circleAlertView2 removeFromSuperview];
    }else if (tap.view.tag == 2){
        [_circleAlertView3 removeFromSuperview];
    }
}

//用于移除当前点开的具体内容弹窗
-(void)removeCurrentAlert{
    [self.fosaAlertView removeFromSuperview];
    [self.forbidview removeFromSuperview];
    self.focusCursor.alpha = 0;
    _fosaAlertView = NULL;
    _forbidview = NULL;
    [self.session startRunning];
}
#pragma 设置在二维码位置显示聚焦光标
-(void)setFocusCursorWithPoint:(AVMetadataMachineReadableCodeObject *)objc
{
    //[self.session stopRunning];//停止捕获
  //  NSLog(@"location");
    CGPoint point = [self getCenterOfQRcode:objc];
 //   NSLog(@"x=%f--------y=%f",point.x,point.y);
    CGPoint center = CGPointZero;
    center.x = [UIScreen mainScreen].bounds.size.width*(1-point.y);
    center.y = [UIScreen mainScreen].bounds.size.height*(point.x);

//    CGPoint center = CGPointZero;
//    center.x = [UIScreen mainScreen].bounds.size.width*CGRectGetMidY(objc.bounds);
//    center.y = [UIScreen mainScreen].bounds.size.height*CGRectGetMidX(objc.bounds);
//    NSLog(@"----%f======%f",center.x,center.y);
    self.focusCursor.center = center;
    self.focusCursor.alpha = 1.0;
//    self.focusCursor.transform = CGAffineTransformMakeScale(1.5, 1.5);
//    self.focusCursor.alpha = 1.0;
//    [UIView animateWithDuration:5.0 animations:^{
//        self.focusCursor.transform = CGAffineTransformIdentity;
//    } completion:^(BOOL finished) {
//        self.focusCursor.alpha = 0;
//    }];
    //[self.session startRunning];
}
#pragma  数据库查询的方法
-(AlertModel *)OpenAndSelectsql:(NSString *)device
{
    NSString *path = [self getPath];
    int sqlStatus = sqlite3_open_v2([path UTF8String], &_database,SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE,NULL);
    if (sqlStatus == SQLITE_OK) {
        NSLog(@"数据库打开成功");
    }
    //查询数据库新添加的食物
    NSString *sql = [NSString stringWithFormat:@"select foodName,deviceName,aboutFood,expireDate,remindDate,photoPath from Fosa2 where deviceName ='%@'",device];
    const char *selsql = (char *)[sql UTF8String];
    int selresult = sqlite3_prepare_v2(self.database, selsql, -1,&_stmt, NULL);
    
    const char  *food_name = NULL;
    const char *device_name = NULL;
    const char *about_food  = NULL;
    const char *expire_date = NULL;
    const char *remind_date = NULL;
    const char *photo_path = NULL;
    if(selresult != SQLITE_OK){
        NSLog(@"查询失败");
    }else{
        while (sqlite3_step(_stmt) == SQLITE_ROW) {
            food_name = (const char *)sqlite3_column_text(_stmt, 0);
            food = [NSString stringWithUTF8String:food_name];

            device_name = (const char *)sqlite3_column_text(_stmt,1);
            fdevice = [NSString stringWithUTF8String:device_name];
           
            about_food = (const char *)sqlite3_column_text(_stmt,2);
            NSLog(@"查询到数据:%@",[NSString stringWithUTF8String:about_food]);
            
            expire_date = (const char *)sqlite3_column_text(_stmt,3);
            expire = [NSString stringWithUTF8String:expire_date];
            
            remind_date = (const char *)sqlite3_column_text(_stmt,4);
            remind = [NSString stringWithUTF8String:remind_date];
            
            photo_path = (const char *)sqlite3_column_text(_stmt, 5);
            photoPath = [NSString stringWithUTF8String:photo_path];
        }
    }
    NSLog(@"查询到数据:%@",food);
    NSLog(@"查询到数据:%@",fdevice);
    NSLog(@"查询到数据:%@",expire);
    NSLog(@"查询到数据:%@",remind);
    NSLog(@"查询到数据:%@",photoPath);
    AlertModel *model = [AlertModel modelWithName:food device_name:fdevice icon:photoPath expire_date:expire remind_date:remind];
    food = NULL;
    fdevice = NULL;
    photoPath = NULL;
    expire  = NULL;
    remind  = NULL;
    return model;
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
#pragma 识别图片中的矩形
-(NSArray *)analyseRectImage:(UIImage *)image{
    NSMutableArray * dataArray = [NSMutableArray array];
    CIImage * cImage = [CIImage imageWithCGImage:image.CGImage];
    NSDictionary* opts = [NSDictionary dictionaryWithObject:
                          CIDetectorAccuracyHigh forKey:CIDetectorAccuracy];
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeRectangle
                                              context:nil options:opts];
    NSArray* features = [detector featuresInImage:cImage];
    CGSize inputImageSize = [cImage extent].size;
    CGAffineTransform  transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, 1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -inputImageSize.height);
    
    for (CIRectangleFeature *feature in features){
        NSLog(@"%lu",features.count);
        NSMutableDictionary * dic = [NSMutableDictionary dictionary];
        CGRect viewBounds = CGRectApplyAffineTransform(feature.bounds, transform);
        [dic setValue:[NSValue valueWithCGRect:viewBounds] forKey:@"rectBounds"];
        CGPoint topLeft = CGPointApplyAffineTransform(feature.topLeft, transform);
        [dic setValue:[NSValue valueWithCGPoint:topLeft] forKey:@"topLeft"];
        CGPoint topRight = CGPointApplyAffineTransform(feature.topRight, transform);
        [dic setValue:[NSValue valueWithCGPoint:topRight] forKey:@"topRight"];
        CGPoint bottomLeft = CGPointApplyAffineTransform(feature.bottomLeft, transform);
        [dic setValue:[NSValue valueWithCGPoint:bottomLeft] forKey:@"bottomLeft"];
        CGPoint bottomRight = CGPointApplyAffineTransform(feature.bottomRight, transform);
        [dic setValue:[NSValue valueWithCGPoint:bottomRight] forKey:@"bottomRight"];
        [dataArray addObject:dic];
    }
    return [dataArray copy];
}

#pragma 选取相册图片进行识别
-(void)selectPhoto{
    [self sessionStopRunning];
    NSLog(@"打开相册");
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary; //UIImagePickerControllerSourceTypeSavedPhotosAlbum
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:YES completion:nil];
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
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // 对选取照片的处理，如果选取的图片尺寸过大，则压缩选取图片，否则不作处理
    UIImage *image = [ScanViewController LY_imageSizeWithScreenImage:info[UIImagePickerControllerOriginalImage]];
    // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
    [self dismissViewControllerAnimated:YES completion:nil];
    
    // 声明一个 CIDetector，并设定识别类型 CIDetectorTypeQRCode
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyHigh}];

    // 取得识别结果
    NSArray *features = [detector featuresInImage:[CIImage imageWithCGImage:image.CGImage]];

    if (features.count == 0) {
        [self SystemAlert:@"识别不到二维码"];
        return;
    } else {
        CIQRCodeFeature *firstfeature = [features objectAtIndex:0];
        NSString *firstResult = firstfeature.messageString;
        [self SystemAlert:firstResult];
//        for (int index = 0; index < [features count]; index ++) {
//            CIQRCodeFeature *feature = [features objectAtIndex:index];
//            NSString *resultStr = feature.messageString;
//            NSLog(@"相册中读取二维码数据信息 - - %@", resultStr);
//        }
    }

}
- (void)getImageAndDetect
{
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    //根据连接取得设备输出的数据
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            [self DetectQRcode:image];
        }
    }];
}//此方法用于检测画面中是否存在二维码
-(void)DetectQRcode:(UIImage *)image{
    //创建上下文对象
    CIContext *context = [CIContext contextWithOptions:nil];
    //创建CIImage对象
    CIImage *ciImage  = [[CIImage alloc]initWithImage:image];
    //创建探测器
    CIDetector *ciDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    // 取得识别结果
    NSArray *features = [ciDetector featuresInImage:ciImage];
    if (features.count == 0) {
        NSLog(@"暂未识别出扫描的二维码");
        self.isGetResult = false;
    }else{
        for (int index = 0; index < [features count]; index ++) {
            CIQRCodeFeature *feature = [features objectAtIndex:index];
            NSString *result = feature.messageString;
            NSLog(@"画面中的二维码的内容是:%@",result);
        }
        self.isGetResult = true;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"即将退出扫描");
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.session stopRunning];
    self.focusCursor.alpha = 0;
    dispatch_source_cancel(self->_timer); //关闭定时器
    self.device = NULL;
    self.input = NULL;
    [self.view removeFromSuperview];
    NSLog(@"扫描结束-----定时器关闭");
}
@end
