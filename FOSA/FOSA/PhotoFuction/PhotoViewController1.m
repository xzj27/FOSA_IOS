//
//  PhotoViewController1.m
//  FOSA
//
//  Created by hs on 2019/12/27.
//  Copyright © 2019 hs. All rights reserved.
//

#import "PhotoViewController1.h"
#import "ScanOneCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <UserNotifications/UserNotifications.h>

@interface PhotoViewController1 ()

@property (nonatomic, strong) AVCaptureSession *captureSession;//负责输入和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;//照片输出流
//@property (nonatomic,strong) AVCapturePhotoOutput *imageOutput; //图片输出流 （iOS10之后）
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层
@property (nonatomic, weak) UIView *containerView;//内容视图
@property (nonatomic, weak) UIView *TakingPhotoView;//拍照与照片缩略图
@property (nonatomic, weak) UIImageView *focusCursor;//聚焦按钮
@property (nonatomic, weak) UIImageView *imgView;//拍摄照片
@property (nonatomic, strong) UIButton *shutter,*cancel1;
@property (nonatomic, strong) UIImage *image;

//图片放大视图
@property (nonatomic,strong) UIScrollView *backGround;
@property (nonatomic,strong) UIImageView *bigImage;
@property (nonatomic,assign) CGFloat totalScale;
@end

@implementation PhotoViewController1
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
//    self.navigationItem.title = @"拍照";
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_scan"] style:UIBarButtonItemStylePlain target:nil action:nil];
//    self.navigationItem.rightBarButtonItem.target = self;     self.navigationItem.rightBarButtonItem.action = @selector(ScanEvent);
//    self.view.backgroundColor = [UIColor blackColor];
    //创建控件
    [self creatControl];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //初始化信息
    [self initPhotoInfo];
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.captureSession stopRunning];
}
- (void)creatControl
{
    CGFloat marginY = self.navigationController.navigationBar.frame.size.height;
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    //内容视图
    CGFloat containerViewH = h;
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, w, containerViewH)];
    containerView.backgroundColor = [UIColor whiteColor];
    //containerView.layer.borderWidth = 1.f;
    //containerView.layer.borderColor = [[UIColor grayColor] CGColor];
    [self.view addSubview:containerView];
    _containerView = containerView;

    //拍照控制视图
    UIView *takingPhoto =[[UIView alloc] initWithFrame:CGRectMake(0,containerViewH+marginY, w, 180)];
    takingPhoto.backgroundColor = [UIColor blackColor];
    [self.view addSubview:takingPhoto];
    _TakingPhotoView = takingPhoto;

    //摄像头切换按钮
    CGFloat cameraSwitchBtnW = 80.f;
    CGFloat cameraSwitchBtnMargin = 10.f;
    UIButton *cameraSwitchBtn = [[UIButton alloc] initWithFrame:CGRectMake(containerView.bounds.size.width - cameraSwitchBtnW - cameraSwitchBtnMargin, containerViewH+marginY+20, cameraSwitchBtnW, cameraSwitchBtnW)];
    [cameraSwitchBtn setBackgroundImage:[UIImage imageNamed:@"camera_switch"] forState:UIControlStateNormal];
    //[cameraSwitchBtn addTarget:self action:@selector(cameraSwitchBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    //[self.view addSubview:cameraSwitchBtn];
    //拍摄快门按钮
    self.shutter = [[UIButton alloc]initWithFrame:CGRectMake(screen_width/2-cameraSwitchBtnW/2, containerViewH*4/5, cameraSwitchBtnW, cameraSwitchBtnW)];
    [_shutter setImage:[UIImage imageNamed:@"icon_takePhoto"] forState:UIControlStateNormal];
    [_shutter addTarget:self action:@selector(btnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_shutter];
    
    //聚焦图片
    UIImageView *focusCursor = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 75, 75)];
    focusCursor.alpha = 0;
    focusCursor.image = [UIImage imageNamed:@"camera_focus_red"];
    [containerView addSubview:focusCursor];
    _focusCursor = focusCursor;
    
    //拍摄照片容器
    _pictureView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, NavigationHeight, screen_width, screen_height-NavigationHeight-40)];
    _pictureView1.contentMode = UIViewContentModeScaleAspectFill;
    _pictureView1.clipsToBounds = YES;
    _pictureView1.userInteractionEnabled = YES;
    //[self.view addSubview:_pictureView1];
    self.cancel1 = [[UIButton alloc]initWithFrame:CGRectMake(screen_width/2-cameraSwitchBtnW/2, containerViewH*2/3, cameraSwitchBtnW, cameraSwitchBtnW)];
    [self.cancel1 setBackgroundImage:[UIImage imageNamed:@"icon_cancel"] forState:UIControlStateNormal];
    [self.cancel1 addTarget:self action:@selector(takePictureAgain) forControlEvents:UIControlEventTouchUpInside];
    [_pictureView1 addSubview:_cancel1];

}

- (void)initPhotoInfo
{
    //初始化会话
    _captureSession = [[AVCaptureSession alloc] init];
    
    //设置分辨率
    if ([_captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    }
    //获得输入设备,取得后置摄像头
    AVCaptureDevice *captureDevice = [self getCameraDeviceWithPosition:AVCaptureDevicePositionBack];
    if (!captureDevice) {
        NSLog(@"取得后置摄像头时出现问题");
        return;
    }
    NSError *error = nil;
    //根据输入设备初始化设备输入对象，用于获得输入数据
    _captureDeviceInput = [[AVCaptureDeviceInput alloc]initWithDevice:captureDevice error:&error];
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@", error.localizedDescription);
        return;
    }
    //初始化设备输出对象，用于获得输出数据
    _captureStillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{AVVideoCodecKey:AVVideoCodecTypeJPEG};
    //输出设置
    [_captureStillImageOutput setOutputSettings:outputSettings];
    
    //将设备输入添加到会话中
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
    }
    //将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureStillImageOutput]) {
        [_captureSession addOutput:_captureStillImageOutput];
    }
    //创建视频预览层，用于实时展示摄像头状态
    _captureVideoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    
    //摄像头方向
    AVCaptureConnection *captureConnection = [self.captureVideoPreviewLayer connection];
    captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    CALayer *layer = _containerView.layer;
    layer.masksToBounds = YES;
    
    _captureVideoPreviewLayer.frame = layer.bounds;
    //填充模式
    _captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    //将视频预览层添加到界面中
    [layer insertSublayer:_captureVideoPreviewLayer below:self.focusCursor.layer];
    [self.captureSession startRunning];
//    [self addNotificationToCaptureDevice:captureDevice];
    [self addGenstureRecognizer];
    
     [_captureDeviceInput.device lockForConfiguration:nil];
       
       self.view.clipsToBounds = YES;
       self.view.layer.masksToBounds = YES;
       [captureDevice setVideoZoomFactor:1.0];
       //自动白平衡
       if([captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]){
           [_captureDeviceInput.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
       }
       
       //判断并开启自动对焦功能
       if(captureDevice.isFocusPointOfInterestSupported &&[captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
           [_captureDeviceInput.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
       }
       //自动曝光
       if([captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
           [_captureDeviceInput.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
       }
       [_captureDeviceInput.device unlockForConfiguration];
}
- (void)btnOnClick:(UIButton *)btn
{
    [self photoBtnOnClick];
}
#pragma mark 拍照
- (void)photoBtnOnClick
{
    //根据设备输出获得连接
    AVCaptureConnection *captureConnection = [self.captureStillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    captureConnection.videoOrientation = AVCaptureVideoOrientationPortrait;
    //根据连接取得设备输出的数据
    [self.captureStillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer) {
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            self.image = [UIImage imageWithData:imageData];
            CGFloat fixelW = CGImageGetWidth(self.image.CGImage);
            CGFloat fixelH = CGImageGetHeight(self.image.CGImage);
            NSLog(@"=========%f>>>>>>>>%f",fixelH,fixelW);
           //UIImageWriteToSavedPhotosAlbum(self.image, self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
            self.pictureView1.image = self.image;
            [self.imageArray1 replaceObjectAtIndex:1 withObject:self.image];
        }
    }];
    self.shutter.hidden = YES;
    [self.view addSubview:_pictureView1];
    [self.captureSession stopRunning];
}
- (void)takePictureAgain{
    [self.pictureView1 removeFromSuperview];
    [self.captureSession startRunning];
    self.shutter.hidden = NO;
}
//
//#pragma mark - <保存到相册>
//-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
//    NSString *msg = nil ;
//    if(error){
//        msg = @"保存图片失败" ;
//    }else{
//        msg = @"保存图片成功" ;
//    }
//}
//
//#pragma mark - 此方法用于检测画面中是否存在二维码
//-(void)DetectQRcode:(UIImage *)image{
//    //创建上下文对象
//    CIContext *context = [CIContext contextWithOptions:nil];
//    //创建CIImage对象
//    CIImage *ciImage  = [[CIImage alloc]initWithImage:image];
//    //创建探测器
//    CIDetector *ciDetector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
//    // 取得识别结果
//    NSArray *features = [ciDetector featuresInImage:ciImage];
//
//    if (features.count == 0) {
//        NSLog(@"暂未识别出扫描的二维码");
//    }else{
//        for (int index = 0; index < [features count]; index++) {
//            CIQRCodeFeature *feature = [features objectAtIndex:index];
//            NSString *result = feature.messageString;
//            NSLog(@"画面中的二维码的内容是:%@",result);
//            //[self sendLocalNotification];
//        }
//    }
//}

#pragma mark - 私有方法
//取得指定位置的摄像头
- (AVCaptureDevice *)getCameraDeviceWithPosition:(AVCaptureDevicePosition )position
{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if ([camera position] == position) {
            return camera;
        }
    }
    return nil;
}

//改变设备属性的统一操作方法
- (void)changeDeviceProperty:(void (^)(AVCaptureDevice *))propertyChange
{
    AVCaptureDevice *captureDevice = [self.captureDeviceInput device];
    NSError *error;
//注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
        
    }else {
        NSLog(@"设置设备属性过程发生错误，错误信息：%@", error.localizedDescription);
    }
}

//设置闪光灯模式
- (void)setFlashMode:(AVCaptureFlashMode)flashMode
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}
//设置聚焦模式
- (void)setFocusMode:(AVCaptureFocusMode)focusMode
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:focusMode];
        }
    }];
}
//设置曝光模式
- (void)setExposureMode:(AVCaptureExposureMode)exposureMode
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:exposureMode];
        }
    }];
}
//设置聚焦点
- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposureMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point
{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFocusModeSupported:focusMode]) {
            [captureDevice setFocusMode:AVCaptureFocusModeAutoFocus];
        }
        if ([captureDevice isFocusPointOfInterestSupported]) {
            [captureDevice setFocusPointOfInterest:point];
        }
        if ([captureDevice isExposureModeSupported:exposureMode]) {
            [captureDevice setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        if ([captureDevice isExposurePointOfInterestSupported]) {
            [captureDevice setExposurePointOfInterest:point];
        }
    }];
}
//添加点按手势，点按时聚焦
- (void)addGenstureRecognizer
{
    [self.containerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapScreen:)]];
}
- (void)tapScreen:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point = [tapGesture locationInView:self.containerView];
    //将UI坐标转化为摄像头坐标
    CGPoint cameraPoint = [self.captureVideoPreviewLayer captureDevicePointOfInterestForPoint:point];
    [self setFocusCursorWithPoint:point];
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposureMode:AVCaptureExposureModeAutoExpose atPoint:cameraPoint];
}
//设置聚焦光标位置
- (void)setFocusCursorWithPoint:(CGPoint)point
{
    self.focusCursor.center = point;
    self.focusCursor.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.focusCursor.alpha = 1.0;
    [UIView animateWithDuration:1.0 animations:^{
        self.focusCursor.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha = 0;
    }];
}

@end
