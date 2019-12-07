//
//  PhotoViewController.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "PhotoViewController.h"
#import "ScanOneCodeViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <UserNotifications/UserNotifications.h>

@interface PhotoViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) AVCaptureSession *captureSession;//负责输入和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;//照片输出流
//@property (nonatomic,strong) AVCapturePhotoOutput *imageOutput; //图片输出流 （iOS10之后）
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层
@property (nonatomic, weak) UIView *containerView;//内容视图
@property (nonatomic, weak) UIView *TakingPhotoView;//拍照与照片缩略图
@property (nonatomic, weak) UIImageView *focusCursor;//聚焦按钮
@property (nonatomic, weak) UIImageView *imgView;//拍摄照片
@property (nonatomic, weak) UIButton *shutter;
@property (nonatomic, strong) UIImage *image;

//图片放大视图
@property (nonatomic,strong) UIScrollView *backGround;
@property (nonatomic,strong) UIImageView *bigImage;
@property (nonatomic,assign) CGFloat totalScale;
@end

@implementation PhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"拍照";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_scan"] style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem.target = self;     self.navigationItem.rightBarButtonItem.action = @selector(ScanEvent);
    self.view.backgroundColor = [UIColor blackColor];
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
    CGFloat containerViewH = h - 150;
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0,marginY, w, containerViewH)];
    containerView.backgroundColor = [UIColor whiteColor];
    containerView.layer.borderWidth = 1.f;
    containerView.layer.borderColor = [[UIColor grayColor] CGColor];
    [self.view addSubview:containerView];
    _containerView = containerView;

    //拍照控制视图
    UIView *takingPhoto =[[UIView alloc] initWithFrame:CGRectMake(0,containerViewH+marginY, w, 180)];
    takingPhoto.backgroundColor = [UIColor blackColor];
    [self.view addSubview:takingPhoto];
    _TakingPhotoView = takingPhoto;

    //摄像头切换按钮
    CGFloat cameraSwitchBtnW = 50.f;
    CGFloat cameraSwitchBtnMargin = 10.f;
    UIButton *cameraSwitchBtn = [[UIButton alloc] initWithFrame:CGRectMake(containerView.bounds.size.width - cameraSwitchBtnW - cameraSwitchBtnMargin, containerViewH+marginY+20, cameraSwitchBtnW, cameraSwitchBtnW)];
    [cameraSwitchBtn setImage:[UIImage imageNamed:@"camera_switch"] forState:UIControlStateNormal];
    [cameraSwitchBtn addTarget:self action:@selector(cameraSwitchBtnOnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraSwitchBtn];
    //拍摄快门按钮
    UIButton *shutter = [[UIButton alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2-cameraSwitchBtnW/2, containerViewH+marginY+20, cameraSwitchBtnW, cameraSwitchBtnW)];
    [shutter setImage:[UIImage imageNamed:@"icon_takePhoto"] forState:UIControlStateNormal];
    [shutter addTarget:self action:@selector(btnOnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shutter];
    
    //聚焦图片
    UIImageView *focusCursor = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 75, 75)];
    focusCursor.alpha = 0;
    focusCursor.image = [UIImage imageNamed:@"camera_focus_red"];
    [containerView addSubview:focusCursor];
    _focusCursor = focusCursor;
    
    //拍摄照片容器
    _image = [[UIImage alloc]init];
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, containerViewH+marginY+15,60,60)];
    imgView.hidden = NO;
    imgView.backgroundColor = [UIColor colorWithRed:80/255 green:80/255 blue:80/255 alpha:1.0];
    imgView.layer.borderWidth = 1.f;
    imgView.layer.borderColor = [[UIColor grayColor] CGColor];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    imgView.clipsToBounds = YES;
    imgView.userInteractionEnabled = YES;
    [self.view addSubview:imgView];
    UITapGestureRecognizer *clickRevognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(EnlargePhoto)];
    [imgView addGestureRecognizer:clickRevognizer];
    _imgView = imgView;
}
#pragma mark - 进入扫码界面
-(void)ScanEvent{
    ScanOneCodeViewController *scan = [[ScanOneCodeViewController alloc]init];
    scan.food_photo = [[UIImage alloc]init];
    scan.food_photo = self.image;
    scan.hidesBottomBarWhenPushed = YES;
    if (self.captureSession != nil) {
        NSLog(@"停止捕获");
        [self.captureSession stopRunning];
    }
    [self removeNotification];
    [self.navigationController pushViewController:scan animated:YES];
    [self.navigationController popoverPresentationController];
    
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
    
    //初始化AvcapturePhotoOutput
//    self.imageOutput = [[AVCapturePhotoOutput alloc] init];
//    NSDictionary *setDic = @{AVVideoCodecKey:AVVideoCodecTypeJPEG};
//    AVCapturePhotoSettings *imageSettings = [AVCapturePhotoSettings photoSettingsWithFormat:setDic];
//    [self.imageOutput capturePhotoWithSettings:imageSettings delegate:self];
    
    //将设备输入添加到会话中
    if ([_captureSession canAddInput:_captureDeviceInput]) {
        [_captureSession addInput:_captureDeviceInput];
    }
    //将设备输出添加到会话中
    if ([_captureSession canAddOutput:_captureStillImageOutput]) {
        [_captureSession addOutput:_captureStillImageOutput];
    }
    //将设备输出添加到会话中
//    if ([_captureSession canAddOutput:_imageOutput]) {
//        [_captureSession addOutput:_imageOutput];
//    }
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
    [self addNotificationToCaptureDevice:captureDevice];
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
           UIImageWriteToSavedPhotosAlbum(self.image, self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
            //self.imgView.image = [self getImage];
            self.imgView.contentMode = UIViewContentModeScaleAspectFill;
            self.imgView.clipsToBounds = YES;
            self.imgView.image = self.image;
            [self DetectQRcode:self.image];
            //self.imgView.hidden = NO;
        }
    }];
}
//保存照片到本地
-(void)Savephoto:(UIImage *)image{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"demo.png"]];// 保存文件的名称
    BOOL result =[UIImagePNGRepresentation(image) writeToFile:filePath  atomically:YES];// 保存成功会返回YES
    if(result == YES) {
        NSLog(@"保存成功");
    }
}
//取出保存在本地的图片
-(UIImage*)getImage {
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString*filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"demo.png"]];
// 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:filePath];
    NSLog(@"=== %@", img);
    return img;
}

#pragma mark -  放大缩小图片
- (void)EnlargePhoto{
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
    _bigImage.image = self.imgView.image;
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


#pragma mark - <保存到相册>
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if(error){
        msg = @"保存图片失败" ;
    }else{
        msg = @"保存图片成功" ;
    }
}

#pragma mark - 此方法用于检测画面中是否存在二维码
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
    }else{
        for (int index = 0; index < [features count]; index++) {
            CIQRCodeFeature *feature = [features objectAtIndex:index];
            NSString *result = feature.messageString;
            NSLog(@"画面中的二维码的内容是:%@",result);
            //[self sendLocalNotification];
        }
    }
}
- (void)sendLocalNotification {
}

#pragma mark - 通知
//给输入设备添加通知
- (void)addNotificationToCaptureDevice:(AVCaptureDevice *)captureDevice
{
    //注意添加区域改变捕获通知必须首先设置设备允许捕获
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        captureDevice.subjectAreaChangeMonitoringEnabled = YES;
    }];
    //捕获区域发生改变
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(areaChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
- (void)removeNotificationFromCaptureDevice:(AVCaptureDevice *)captureDevice
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:captureDevice];
}
//移除所有通知
- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//设备连接成功
- (void)deviceConnected:(NSNotification *)notification
{
    NSLog(@"设备已连接...");
}

//设备连接断开
- (void)deviceDisconnected:(NSNotification *)notification
{
    NSLog(@"设备已断开.");
}

//捕获区域改变
//- (void)areaChange:(NSNotification *)notification
//{
//    NSLog(@"捕获区域改变...");
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
#pragma mark 切换前后摄像头
- (void)cameraSwitchBtnOnClick
{
    AVCaptureDevice *currentDevice = [self.captureDeviceInput device];
    AVCaptureDevicePosition currentPosition = [currentDevice position];
    [self removeNotificationFromCaptureDevice:currentDevice];
    
    AVCaptureDevice *toChangeDevice;
    AVCaptureDevicePosition toChangePosition = AVCaptureDevicePositionFront;
    if (currentPosition == AVCaptureDevicePositionUnspecified || currentPosition == AVCaptureDevicePositionFront) {
        toChangePosition = AVCaptureDevicePositionBack;
    }
    toChangeDevice = [self getCameraDeviceWithPosition:toChangePosition];
    [self addNotificationToCaptureDevice:toChangeDevice];
    //获得要调整的设备输入对象
    AVCaptureDeviceInput *toChangeDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:toChangeDevice error:nil];
    
    //改变会话的配置前一定要先开启配置，配置完成后提交配置改变
    [self.captureSession beginConfiguration];
    //移除原有输入对象
    [self.captureSession removeInput:self.captureDeviceInput];
    //添加新的输入对象
    if ([self.captureSession canAddInput:toChangeDeviceInput]) {
        [self.captureSession addInput:toChangeDeviceInput];
        self.captureDeviceInput = toChangeDeviceInput;
    }
    //提交会话配置
    [self.captureSession commitConfiguration];
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
////拖动视图的方法
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    UITouch *touch = [touches anyObject];
//    // 当前触摸点
//    CGPoint currentPoint = [touch locationInView:self.bigImage];
//    // 上一个触摸点
//    CGPoint previousPoint = [touch previousLocationInView:self.bigImage];
//    // 当前view的中点
//    CGPoint center = self.bigImage.center;
//
//    center.x += (currentPoint.x - previousPoint.x);
//    center.y += (currentPoint.y - previousPoint.y);
//    // 修改当前view的中点(中点改变view的位置就会改变)
//    self.bigImage.center = center;
//}

- (void)dealloc
{
    [self removeNotification];
}
@end

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
