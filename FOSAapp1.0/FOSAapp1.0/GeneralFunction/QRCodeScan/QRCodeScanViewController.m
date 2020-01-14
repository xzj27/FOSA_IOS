//
//  QRCodeScanViewController.m
//  FOSAapp1.0
//
//  Created by hs on 2019/12/31.
//  Copyright © 2019 hs. All rights reserved.
//

#import "QRCodeScanViewController.h"
#import "FoodInfoView.h"
#import "FoodMoreInfoView.h"
#import "FMDB.h"
#import "FoodModel.h"
#import "FoodViewController.h"

@interface QRCodeScanViewController ()<AVCaptureMetadataOutputObjectsDelegate,UINavigationControllerDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,UIImagePickerControllerDelegate,UIScrollViewDelegate>{
    CGPoint scanLineVerticalCenter; //竖屏的扫描线的起始中心点
    CGPoint scanLineHorizontalCenter; //横屏的扫描线的起始中心点
    Boolean stopAnimation;     //停止扫描标志
    Boolean isJump;            //控制器跳转标志
    NSMutableArray<UIImage *> *imgArray;
    //数据库对象
    FMDatabase *db;
    //通知项计数
    int AlertCount;
    
}
@property (nonatomic,strong) FoodMoreInfoView *circleAlertView1,*circleAlertView2,*circleAlertView3;
@end

@implementation QRCodeScanViewController
#pragma mark - 懒加载属性
- (UIImageView *)scanFrame{
    if (_scanFrame == nil) {
        _scanFrame = [[UIImageView alloc]init];
    }
    return _scanFrame;
}
- (UIImageView *)scanLine{
    if (_scanLine == nil) {
        _scanLine = [[UIImageView alloc]init];
    }
    return _scanLine;
}
- (UIView *)scanMaskView{
    if (_scanMaskView == nil) {
        _scanMaskView = [[UIView alloc]init];
    }
    return _scanMaskView;
}
- (UIButton *)flashBtn{
    if (_flashBtn == nil) {
        _flashBtn = [[UIButton alloc]init];
    }
    return _flashBtn;
}
- (UISlider *)zoomSlider{
    if (_zoomSlider == nil) {
        _zoomSlider = [[UISlider alloc]init];
    }
    return _zoomSlider;
}
- (AVCaptureDevice *)captureDevice{
    if (_captureDevice == nil) {
        _captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //检查相机是否有摄像头
        if(!_captureDevice){
            NSLog(@"该设备没有摄像头");
        }
    }
    return _captureDevice;
}
- (AVCaptureDeviceInput *)captureInput{
    if (_captureInput == nil) {
        //设备输入 初始化
        _captureInput = [[AVCaptureDeviceInput alloc]initWithDevice:self.captureDevice error:nil];
    }
    return _captureInput;
}
- (AVCaptureMetadataOutput *)captureOutput{
    if (_captureOutput == nil) {
        //设备输出
        _captureOutput = [[AVCaptureMetadataOutput alloc]init];
        CGFloat ScreenWidth = self.view.frame.size.width;
        //设置扫描作用域范围(中间透明的扫描框)
        CGRect intertRect = [self.previewLayer metadataOutputRectOfInterestForRect:CGRectMake(ScreenWidth*0.15, ScreenWidth*0.15+64, ScreenWidth*0.7, ScreenWidth*0.7)];
        _captureOutput.rectOfInterest = intertRect;
    }
    return _captureOutput;
}
- (AVCaptureVideoDataOutput *)VideoOutput{
    if (_VideoOutput == nil) {
        _VideoOutput = [[AVCaptureVideoDataOutput alloc]init];
    }
    return _VideoOutput;
}
- (AVCaptureSession *)captureSession{
    if (_captureSession == nil) {
        _captureSession = [[AVCaptureSession alloc]init];
    }
    return _captureSession;
}
- (AVCaptureVideoPreviewLayer *)previewLayer{
    if (_previewLayer == nil) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    }
    return _previewLayer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self startScanQRCode];
    [self CreatVerticalScanView];
    
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.captureSession startRunning];
    [self InitData];
    [self CreatNavigationButtonAndFocusBtn];
}

#pragma mark - 扫码属性初始化
-(void)startScanQRCode{
    stopAnimation = false;
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
        if ([self.captureSession canAddInput:self.captureInput]) {
            [_captureSession addInput:self.captureInput];
        }else{
            NSLog(@"找不到摄像头设备");
        }
        if ([self.captureSession canAddOutput:self.captureOutput]) {
            [self.captureSession addOutput:self.captureOutput];
        }
        if([self.captureSession canAddOutput:self.VideoOutput]){
            [self.captureSession addOutput:self.VideoOutput];
        }
    //指定设备的识别类型
        self.captureOutput.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeCode128Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeAztecCode,AVMetadataObjectTypeCode39Code,AVMetadataObjectTypeCode93Code,AVMetadataObjectTypeUPCECode,AVMetadataObjectTypeCode39Mod43Code,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypePDF417Code];
    //设备输出 初始化，并设置代理和回调，当设备扫描到数据时通过该代理输出队列，一般输出队列都设置为主队列，也是设置了回调方法执行所在的队列环境
    dispatch_queue_t queue = dispatch_queue_create("fosaQueue", NULL);
    [self.captureOutput setMetadataObjectsDelegate:self queue:queue];
    //视频流输出
     [self.VideoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    //添加预览图层
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.frame = self.view.bounds;
    [self.view.layer addSublayer:self.previewLayer];
    //开始捕获
    [self.captureSession startRunning];
    
    //设置device的功能
    [self.captureInput.device lockForConfiguration:nil];
    
    self.view.clipsToBounds = YES;
    self.view.layer.masksToBounds = YES;
    
    //自动白平衡
    if([self.captureDevice isWhiteBalanceModeSupported:AVCaptureWhiteBalanceModeAutoWhiteBalance]){
        [self.captureInput.device setWhiteBalanceMode:AVCaptureWhiteBalanceModeAutoWhiteBalance];
    }
    //判断并开启自动对焦功能
    if(self.captureDevice.isFocusPointOfInterestSupported &&[self.captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]){
        [self.captureInput.device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    }
    //自动曝光
    if([self.captureDevice isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]){
        [self.captureInput.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [self.captureInput.device unlockForConfiguration];
}
#pragma mark - 视图创建与初始化
/**初始化标志与参数*/
- (void)InitData{
    UIImage *image = [UIImage imageNamed:@"icon_logoHL"];
    UIImage *image1 = [UIImage imageNamed:@"icon_logoHL"];
    UIImage *image2 = [UIImage imageNamed:@"icon_logoHL"];
    imgArray = [[NSMutableArray alloc]init];
    [imgArray addObject:image];
    [imgArray addObject:image1];
    [imgArray addObject:image2];
    isJump = false;
    AlertCount = 0;
    //用于存储可读码的队列
    self.codeQueue = [[Fosa_QRCode_Queue alloc]initWithCapacity:3];
    self.QRcode = [[Fosa_NSString_Queue alloc]initWithCapacity:3];
    
    //notification window
    self.circleAlertView1 = [[FoodMoreInfoView alloc] init];
    self.circleAlertView2 = [[FoodMoreInfoView alloc] init];
    self.circleAlertView3 = [[FoodMoreInfoView alloc] init];
    
}
 /**竖屏布局*/
- (void)CreatVerticalScanView{
    self.ScanModel = 0;
    CGFloat imageX = screen_width*0.15;
    CGFloat imageY = (screen_height-screen_width*0.7)/2;
    self.scanMaskView.frame = self.view.bounds;
    self.scanMaskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [self.view addSubview:self.scanMaskView];
    //从蒙版中扣出扫描框那一块,这块的大小尺寸将来也设成扫描输出的作用域大小
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [maskPath appendPath:[[UIBezierPath bezierPathWithRect:CGRectMake(imageX, imageY,screen_width*0.7,screen_width*0.7)] bezierPathByReversingPath]];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = maskPath.CGPath;
    self.scanMaskView.layer.mask = maskLayer;
    //扫描框
    self.scanFrame.frame = CGRectMake(imageX, imageY,screen_width*0.7,screen_width*0.7);
    self.scanFrame.image = [UIImage imageNamed:@"saoyisao@3x"];
    [self.view addSubview:self.scanFrame];
    //扫描线
    self.scanLine.frame = CGRectMake(imageX, imageY, screen_width*0.7, 4);
    self.scanLine.image = [UIImage imageNamed:@"scanLine_Horizontal"];
    scanLineVerticalCenter = self.scanLine.center;
    [self.view addSubview:self.scanLine];
    //开始动画
    stopAnimation = false;
    [self VerticalScanLineAnimation];
    //闪光灯
    self.flashBtn.frame = CGRectMake(screen_width/2-20, CGRectGetMaxY(_scanFrame.frame)-45, 40, 40);
    self.flashBtn.layer.cornerRadius = _flashBtn.frame.size.width/2;
    self.flashBtn.clipsToBounds = YES;
    [self.flashBtn setBackgroundImage:[UIImage imageNamed:@"icon_flashOff.png"] forState:UIControlStateNormal];
    [self.flashBtn addTarget:self action:@selector(OpenOrCloseFlash) forControlEvents:UIControlEventTouchUpInside];
    //UISlider
    self.zoomSlider.frame = CGRectMake(imageX,imageY+self.view.frame.size.width*0.7,self.view.frame.size.width*0.7,20);
    [self.view addSubview:self.zoomSlider];
    self.zoomSlider.minimumValue = 0;
    self.zoomSlider.maximumValue = 100;
    [self.zoomSlider addTarget:self action:@selector(ZoomSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    
    //设置有效扫描区域
    CGRect intertRect = [_previewLayer metadataOutputRectOfInterestForRect:CGRectMake(imageX, imageY,screen_width/2,screen_width/2)];
    _captureOutput.rectOfInterest = intertRect;
}
/**横屏布局*/
- (void)CreatHorizontalScanView{
    self.ScanModel = 1;
    [self.QRcode removeAllObjects];
    [self.codeQueue removeAllObjects];
    CGFloat imageX = screen_width*0.45;
    CGFloat imageY = NavigationBarHeight*2;
    self.scanMaskView.frame = self.view.bounds;
    self.scanMaskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [self.view addSubview:self.scanMaskView];
    //从蒙版中扣出扫描框那一块,这块的大小尺寸将来也设成扫描输出的作用域大小
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [maskPath appendPath:[[UIBezierPath bezierPathWithRect:CGRectMake(imageX, imageY,screen_width*0.5,screen_height-NavigationBarHeight*4)] bezierPathByReversingPath]];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = maskPath.CGPath;
    self.scanMaskView.layer.mask = maskLayer;
    //扫描框
    self.scanFrame.frame = CGRectMake(imageX, imageY,screen_width*0.5,screen_height-NavigationBarHeight*4);
    self.scanFrame.image = [UIImage imageNamed:@"saoyisao@3x"];
    [self.view addSubview:self.scanFrame];
    //扫描线
    self.scanLine.frame = CGRectMake(screen_width*0.95, imageY, 4, screen_height-NavigationBarHeight*4);
    self.scanLine.image = [UIImage imageNamed:@"scanLine_Vertical"];
    scanLineHorizontalCenter = self.scanLine.center;
    [self.view addSubview:self.scanLine];
    //开始动画
    stopAnimation = false;
    [self HorizontalScanLineAnimation];
    //闪光灯
    self.flashBtn.frame = CGRectMake(screen_width/2, screen_height/2-20, 40, 40);
    self.flashBtn.layer.cornerRadius = self.flashBtn.frame.size.width/2;
    self.flashBtn.clipsToBounds = YES;
    [self.flashBtn setBackgroundImage:[UIImage imageNamed:@"icon_flashOff.png"] forState:UIControlStateNormal];
    [self.flashBtn addTarget:self action:@selector(OpenOrCloseFlash) forControlEvents:UIControlEventTouchUpInside];
    self.zoomSlider.frame = CGRectMake(imageX,screen_height-NavigationBarHeight*2,self.view.frame.size.width*0.5,20);
    [self.view addSubview:self.zoomSlider];
    self.zoomSlider.minimumValue = 0;
    self.zoomSlider.maximumValue = 100;
    [self.zoomSlider addTarget:self action:@selector(ZoomSliderValueChanged) forControlEvents:UIControlEventValueChanged];
    
    //设置有效扫描区域
    CGRect intertRect = [_previewLayer metadataOutputRectOfInterestForRect:CGRectMake(imageX, imageY,screen_width*0.5,screen_height-NavigationBarHeight*4)];
    _captureOutput.rectOfInterest = intertRect;
}
/**导航栏按钮*/
-(void)CreatNavigationButtonAndFocusBtn{
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
        [mainAndSearchBtn setImage:[UIImage imageNamed:@"icon_switch"] forState:UIControlStateNormal];
        [mainAndSearchBtn addTarget:self action:@selector(SwitchScanStyle) forControlEvents:UIControlEventTouchUpInside];
         
        //把右侧的两个按钮添加到rightBarButtonItem
        UIBarButtonItem *rightCunstomButtonView = [[UIBarButtonItem alloc] initWithCustomView:rightButtonView];
        self.navigationItem.rightBarButtonItem = rightCunstomButtonView;
     //聚焦图片
    UIImageView *focusCursor = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    focusCursor.alpha = 0;
    focusCursor.image = [UIImage imageNamed:@"camera_focus_red"];

    self.focusCursor1 = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    self.focusCursor1.alpha = 0;
    self.focusCursor1.image = [UIImage imageNamed:@"icon_focusRed"];

    self.focusCursor2 = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    self.focusCursor2.alpha = 0;
    self.focusCursor2.image = [UIImage imageNamed:@"icon_focusGreen"];

    self.focusCursor3 = [[UIImageView alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    self.focusCursor3.alpha = 0;
    self.focusCursor3.image = [UIImage imageNamed:@"icon_focusBlue"];

    [self.view addSubview:focusCursor];
    [self.view addSubview:self.focusCursor1];
    [self.view addSubview:self.focusCursor2];
    [self.view addSubview:self.focusCursor3];
    _focusCursor = focusCursor;
}
#pragma mark - 视图相关事件
//竖屏扫描动画
- (void)VerticalScanLineAnimation{
    [UIView animateWithDuration:2.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.scanLine.center = CGPointMake(self.scanLine.center.x, CGRectGetMaxY(self->_scanFrame.frame));
    } completion:^(BOOL finished) {
        if (self->stopAnimation == false && self.ScanModel == 0) {
            self.scanLine.center = self->scanLineVerticalCenter;
            [self VerticalScanLineAnimation];
        }
    }];
}
//横屏扫描事件
- (void)HorizontalScanLineAnimation{
    [UIView animateWithDuration:2.0 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        self.scanLine.center = CGPointMake(screen_width*0.45,self.scanLine.center.y);
    } completion:^(BOOL finished) {
        if (self->stopAnimation == false && self.ScanModel == 1) {
            self.scanLine.center = self->scanLineHorizontalCenter;
            [self HorizontalScanLineAnimation];
        }
    }];
}
//闪光灯事件
- (void)OpenOrCloseFlash{
    [self.captureDevice lockForConfiguration:nil];
       if(self.captureDevice.torchMode == AVCaptureTorchModeOff){
            NSLog(@"open flash");
           [self.captureDevice setTorchMode:AVCaptureTorchModeOn];
           [_flashBtn setBackgroundImage:[UIImage imageNamed:@"icon_flashON.png"] forState:(UIControlStateNormal)];
       }else{
            NSLog(@"close flash");
           [self.captureDevice setTorchMode:AVCaptureTorchModeOff];
           [_flashBtn setBackgroundImage:[UIImage imageNamed:@"icon_flashOff.png"] forState:(UIControlStateNormal)];
           // [self.flashBtn removeFromSuperview];
       }
       [self.captureDevice unlockForConfiguration];
}
//zoom事件
- (void)ZoomSliderValueChanged{
    [self.captureDevice lockForConfiguration:nil];
       self.scale = (self.zoomSlider.value/100)*10+1;
       [self.captureDevice setVideoZoomFactor:self.scale];
       [self.captureDevice unlockForConfiguration];
}
- (void)SwitchScanStyle{
    NSLog(@"SwitchScanStyle");
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        if (self.ScanModel == 0) {
            [self.captureSession startRunning];
            self.flashBtn.transform = CGAffineTransformRotate(self.flashBtn.transform, M_PI/2);
            [self CreatHorizontalScanView];
        }else if(self.ScanModel == 1){
            [self removeView];
            [self.captureSession startRunning];
            self.flashBtn.transform = CGAffineTransformRotate(self.flashBtn.transform, -M_PI/2);
            [self CreatVerticalScanView];
        }
    } completion:nil];
}
#pragma mark - 扫码相关方法
// 竖屏模式获取在扫描框中的二维码的中心坐标
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

    return center;
}

//横屏模式获取二维码的中心点坐标
-(CGPoint)getCenter:(AVMetadataMachineReadableCodeObject *)objc
{
    
        CGPoint center = CGPointZero;
    //横屏状态下，二维码每个角的坐标顺序与竖屏时的有区别
        NSArray *array = objc.corners;
    //    NSLog(@"cornersArray = %@",array);
        CGPoint point = CGPointZero;
        int index = 0;
        CFDictionaryRef dict = (__bridge CFDictionaryRef)(array[index++]);
        // 把字典转换为点，存在point里，成功返回true 其他false
        CGPointMakeWithDictionaryRepresentation(dict, &point);
        CGPoint point2 = CGPointZero;
        CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[index++], &point2);
        center.y=(point.y+point2.y)/2;
        CGPoint point3 = CGPointZero;
        CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[index++], &point3);
        center.x = (point2.x+point3.x)/2;
        CGPoint point4 = CGPointZero;
        CGPointMakeWithDictionaryRepresentation((__bridge CFDictionaryRef)array[index++], &point4);
         //NSLog(@"X:%f -- Y:%f",point4.x,point4.y);
        
    return center;
}
#pragma mark - 点击扫码区域重新扫码
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    [self processTouch:touch];
}
-(void)processTouch:(UITouch *)touch{
    //获取点击处的坐标
    CGPoint touchPoint = [touch locationInView:self.view];
    CGFloat x = touchPoint.x;
    CGFloat y = touchPoint.y;
    NSLog(@"%f,%f",x,y);
    if(x > [UIScreen mainScreen].bounds.size.width*0.45 && x < [UIScreen mainScreen].bounds.size.width*9/10){
        if(y > NavigationBarHeight*2 && y< screen_height-NavigationBarHeight*2){
            [self StartRunning];
        }
    }
}
#pragma mark - AVCaptureMetadataOutputObjectsDelegate
//wo can get the data in this callback function
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    //NSLog(@"停止扫描");
    //[self.captureSession stopRunning];
    stopAnimation = true;
    //用于标志每次捕获是否识别到新的二维码
    _flag = 0;
    if(metadataObjects.count > 0) {
        AVMetadataMachineReadableCodeObject *mobject = metadataObjects.firstObject;
        NSString *result = mobject.stringValue;
        if (_ScanModel == 0) {//当前是单个扫码模式，对每一个二维码进行逐个处理
            [self.captureSession stopRunning];
            [self ScanResultOperationOnLandScape:result code:(AVMetadataMachineReadableCodeObject *)mobject];
        }else if(_ScanModel == 1){//当前是多个扫码模式
            [self ScanResultOperationOnPortait:metadataObjects];
        }
    }
}
//竖屏扫描结果处理
- (void)ScanResultOperationOnLandScape:(NSString *)result code:(AVMetadataMachineReadableCodeObject *)mobject{
    if([[mobject type] isEqualToString:AVMetadataObjectTypeQRCode]){//如果是一个可读二维码对象
        self.isGetResult = true;                                    //修改标志，不再自动放大镜头
            if (self.food_photo.count == 0){//食物图片数组对象为空说明并不是在添加食物的过程进行扫码
                    [self performSelectorOnMainThread:@selector(setFocusCursorWithPoint:) withObject:(AVMetadataMachineReadableCodeObject *) mobject waitUntilDone:NO];      //在主线程中标记二维码的位置（还不够准确）
                    if([result hasPrefix:@"http://"]){//若是一个网站，就打开这个链接
                        if (!isJump) {
                            [self ScanSuccess:@"ding.wav"];
                            [self performSelectorOnMainThread:@selector(OpenURL:) withObject:result waitUntilDone:NO];
                            isJump = true;
                        }
                    }else if([result hasPrefix:@"Fosa"]||[result hasPrefix:@"FS9"]||[result hasPrefix:@"FOSASealer"]){
                        [self ScanSuccess:@"ding.wav"];
                        [self performSelectorOnMainThread:@selector(showOneMessage:) withObject:result waitUntilDone:NO]; //在主线程中展示这个物品的通知
                    }else if ([result hasPrefix:@"FOSAINFO"]) {
                        FoodViewController *food = [[FoodViewController alloc]init];
                        //分割字符串的测试
                        food.infoArray = [NSArray array];
                        food.infoArray = [result componentsSeparatedByString:@"&"];
                        NSLog(@"图片中的食物二维码信息为:%@",food.infoArray);
                        food.isAdding = false;
                       [self.navigationController pushViewController:food animated:YES];
                    }else{
                        if (!isJump) {//当前还没有发生跳转
                            [self ScanSuccess:@"ding.wav"];
                            [self performSelectorOnMainThread:@selector(JumpToResult:) withObject:result waitUntilDone:NO];
                            isJump = true;  //不再处理其他跳转
                        }
                    }
            }else{  //UIImage不为空则说明现在正处于添加功能中拍照完成后的扫码阶段
                if([result hasPrefix:@"FOSASealer"]||[result hasPrefix:@"FS9"]){//判断所扫描的二维码属于fosa产品
                    [self.captureSession stopRunning];
                    [self performSelectorOnMainThread:@selector(setFocusCursorWithPoint:) withObject:(AVMetadataMachineReadableCodeObject *) mobject waitUntilDone:NO];
                    if (!isJump) {
                        [self ScanSuccess:@"ding.wav"];
                    //标记识别到的二维码
                        [self performSelectorOnMainThread:@selector(JumpToAdd:) withObject:result waitUntilDone:NO];
                        isJump = true;
                    }
                }else{
                    [self ScanSuccess:@"ding.wav"];
                    NSString *message = [NSString stringWithFormat:@"this QRcode does not belong to FOSA.  Its content is %@",result];
                    [self performSelectorOnMainThread:@selector(SystemAlert:) withObject:message waitUntilDone:NO];
                }
            }
    }else{
        if (!isJump) {//不属于二维码对象，则将内容在另一个页面展示
            [self ScanSuccess:@"ding.wav"];
            [self performSelectorOnMainThread:@selector(JumpToResult:) withObject:result waitUntilDone:NO];
            isJump = true;
        }
    }
}
//横屏扫描结果处理
- (void)ScanResultOperationOnPortait:(NSArray<__kindof AVMetadataObject *> *)metadataObjects{
    
        if (AlertCount == 3 ){
            [self.captureSession stopRunning];
            stopAnimation = true;
        }
        //self.isGetResult = true;
        NSInteger count = 3;    //展示通知上限
        NSString *content;
        // 识别多个码的信息，并将每一个二维码的内容存放在不重复的队列中
        if (metadataObjects.count <= 3) {
            count = metadataObjects.count;
        }
        for(int i = 0; i < count;i++){
            AVMetadataObject *object = metadataObjects[i];
            //如果是可读的码的对象
            if ([object isKindOfClass:[AVMetadataMachineReadableCodeObject class]]){
                content = [(AVMetadataMachineReadableCodeObject *) object stringValue];
                //检查二维码信息是否已经被记录，否的话则添加记录
                if([self.QRcode isContainObject:content]){
                    if (self.QRcode.size < 3) {
                        [self.QRcode enqueue:content];
                    }else if (self.QRcode.size == 3){
                        [self.QRcode dequeue];
                        [self.QRcode enqueue:content];
                    }
                    _flag++;
                    //队列操作
                    if (_codeQueue.size < 3 ) {
                        [_codeQueue enqueue:(AVMetadataMachineReadableCodeObject *) object];
                        NSLog(@"*****--%@",content);
                    }else if(_codeQueue.size == 3){
                        [_codeQueue dequeue];
                        [_codeQueue enqueue:(AVMetadataMachineReadableCodeObject *) object];
                        NSLog(@"&&&&&&&&&--%@",content);
                    }
                }else{
                    //更新位置
                    int index = [self.QRcode getTheSameObjectIndex:content];
                    [_codeQueue returnArray][index] = (AVMetadataMachineReadableCodeObject *) object;
                }
            }
        }
        //对数组的二维码内容，按照位置进行排序,展示多个
        if (_flag>0) {
                   self.count = 0;
            //删除与生成有时候顺序混乱，怀疑是进程的问题
                   [self performSelectorOnMainThread:@selector(MoreFoodInfo) withObject:nil waitUntilDone:NO];
            }
        NSLog(@"ENDENDENDENDENDENDENDENDENDeNDendend");
}

//扫描成功的提示音
- (void)ScanSuccess:(NSString *)name{
        NSString *audioFile = [[NSBundle mainBundle] pathForResource:name ofType:nil];
        NSURL *fileUrl = [NSURL fileURLWithPath:audioFile];
        SystemSoundID soundID = 0;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)(fileUrl), &soundID);
        AudioServicesPlaySystemSound(soundID);//播放音效
}
- (void)showOneMessage:(NSString *)result{
    NSLog(@"%@",result);
    isJump = true;
    FoodViewController *food = [[FoodViewController alloc]init];
    food.isAdding = false;
    [self CheckFoodInfoWithName:result];
    
}
//打开扫描到的网页
- (void)OpenURL:(NSString *)url{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}
//弹出系统提示
- (void)SystemAlert:(NSString *)message{
    [self.captureSession stopRunning];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notification" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:true completion:^{
        //回掉
        NSLog(@"SystemAlert------我把捕获打开了");
        [self .captureSession startRunning];
    }];
}
//跳转到添加界面
- (void)JumpToAdd:(NSString *)message{
    NSLog(@"扫码结果：%@",message);
    [NSThread sleepForTimeInterval: 2.0];
    //初始化食物添加视图控制器
    FoodViewController *food = [[FoodViewController alloc]init];
    food.isAdding = true;
    food.food_image = [[NSMutableArray alloc]init];
    food.food_image = self.food_photo;
    food.device = message;
    [self.navigationController pushViewController:food animated:YES];
}
//跳转到结果界面
- (void)JumpToResult:(NSString *)message{
    ResultViewController *result = [[ResultViewController alloc]init];
    result.hidesBottomBarWhenPushed = YES;
    result.resultLabel = [[UILabel alloc]initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/4, [UIScreen mainScreen].bounds.size.height/2, [UIScreen mainScreen].bounds.size.width/2,50)];
    result.resultLabel.font = [UIFont systemFontOfSize:20];
    result.resultLabel.textAlignment = NSTextAlignmentCenter;
    result.resultLabel.textColor = [UIColor redColor];
    result.resultLabel.text = message;
    [self.navigationController pushViewController:result animated:YES];
}
#pragma mark -扫多个二维码的界面
- (void)MoreFoodInfo{
    [self removeView];
    NSInteger count = 3;    //展示通知上限
    if ([_codeQueue size] < count) {
        count = [_codeQueue size];
        }
    if (AlertCount == 0) {
        for (int k = 0;k < count;k++) {
            NSLog(@"-------------------------------------------------%d",k);
                if (k == 0) {
                    [self SetFocusOnQRcode1:[_codeQueue returnArray][k]];
                }else if(k == 1){
                    [self SetFocusOnQRcode2:[_codeQueue returnArray][k]];
                }else if(k == 2){
                    [self SetFocusOnQRcode3:[_codeQueue returnArray][k]];;
                }
           [self showMoreMessage:[_codeQueue returnArray][k]];
            [self ScanSuccess:@"ding.wav"];
        }
    }
}
- (void)showMoreMessage:(AVMetadataMachineReadableCodeObject *)code{
    NSLog(@"%d",AlertCount);
    AlertCount++;
    NSString *message = [code stringValue];
    CGFloat navHeight = self.navigationController.navigationBar.frame.size.height;
    FoodMoreInfoView *circleAlertView = [[FoodMoreInfoView alloc]init];
    circleAlertView.model = [self CheckFoodInfoWithName:message];
    circleAlertView.frame = CGRectMake(screen_width/5 -screen_height/6+5,(self.count)*(screen_height/3)+navHeight,screen_height/3-5,screen_width*2/5);
    circleAlertView.layer.masksToBounds = YES;
    
    circleAlertView.transform = CGAffineTransformMakeRotation(M_PI_2);
    //添加点击事件
//    UITapGestureRecognizer *OpentapgestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
//    [circleAlertView addGestureRecognizer:OpentapgestureRecognizer];
//    OpentapgestureRecognizer.accessibilityValue = message;

    UITapGestureRecognizer *tapgestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(CloseAlert:)];
    switch (_count) {
        case 0:_circleAlertView1 = circleAlertView;
            
            _circleAlertView1.backgroundColor = FOSAAlertBacgBlue;

            _circleAlertView1.foodName.backgroundColor = FOSAAlertBlue;
            _circleAlertView1.remindDate.backgroundColor = FOSAAlertBlue;
            _circleAlertView1.expireDate.backgroundColor = FOSAAlertBlue;
            
            [self.view addSubview:_circleAlertView1];
            [_circleAlertView1.close addGestureRecognizer:tapgestureRecognizer];
            tapgestureRecognizer.view.tag = 0;
            break;
        case 1:_circleAlertView2 = circleAlertView;
              _circleAlertView2.backgroundColor = FOSAAlertBacgGreen;
            _circleAlertView2.foodName.backgroundColor = FOSAAlertGreen;
            _circleAlertView2.remindDate.backgroundColor = FOSAAlertGreen;
            _circleAlertView2.expireDate.backgroundColor = FOSAAlertGreen;
            [self.view addSubview:_circleAlertView2];
            [_circleAlertView2.close addGestureRecognizer:tapgestureRecognizer];
            tapgestureRecognizer.view.tag = 1;
            break;
        case 2:_circleAlertView3 = circleAlertView;
              _circleAlertView3.backgroundColor = FOSAAlertBacgYellow;
            _circleAlertView3.foodName.backgroundColor = FOSAAlertYellow;
            _circleAlertView3.remindDate.backgroundColor = FOSAAlertYellow;
            _circleAlertView3.expireDate.backgroundColor = FOSAAlertYellow;
            [self.view addSubview:_circleAlertView3];
            [_circleAlertView3.close addGestureRecognizer:tapgestureRecognizer];
            tapgestureRecognizer.view.tag = 2;
            break;
        default:
            break;
    }
    self.count = (self.count+1)%3;
}
- (void)removeView{
    [_circleAlertView1 removeFromSuperview];
    [_circleAlertView2 removeFromSuperview];
    [_circleAlertView3 removeFromSuperview];
    _circleAlertView1 = NULL;
    _circleAlertView2 = NULL;
    _circleAlertView3 = NULL;
    self.focusCursor1.alpha = 0;
    self.focusCursor2.alpha = 0;
    self.focusCursor3.alpha = 0;
    AlertCount = 0;
    NSLog(@"我移除了上一次的通知");
}
-(void)CloseAlert:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer *)sender;
    if (tap.view.tag == 0) {
        [_circleAlertView1 removeFromSuperview];
        self.focusCursor1.alpha = 0;
    }else if (tap.view.tag == 1){
        [_circleAlertView2 removeFromSuperview];
        self.focusCursor2.alpha = 0;
    }else if (tap.view.tag == 2){
        [_circleAlertView3 removeFromSuperview];
        self.focusCursor3.alpha = 0;
    }
    AlertCount--;
    if (AlertCount == 0) {
        [self StartRunning];
    }
}
- (void)StartRunning{
    [self removeView];
    [self.captureSession startRunning];
    self.scanLine.center = self->scanLineHorizontalCenter;
    stopAnimation = false;
    [self HorizontalScanLineAnimation];
    [self.QRcode removeAllObjects];
    [self.codeQueue removeAllObjects];
}

#pragma mark -  选取相册图片进行识别
-(void)selectPhoto{
    [self.captureSession stopRunning];
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

#pragma mark - 扫描相册中的二维码-UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    // 对选取照片的处理，如果选取的图片尺寸过大，则压缩选取图片，否则不作处理
   // UIImage *image = [ScanOneCodeViewController LY_imageSizeWithScreenImage:info[UIImagePickerControllerOriginalImage]];
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSLog(@"%@",image);
    // CIDetector(CIDetector可用于人脸识别)进行图片解析，从而使我们可以便捷的从相册中获取到二维码
    [self dismissViewControllerAnimated:YES completion:nil];
    //[self analyseRectImage:image];
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
        if ([firstResult hasPrefix:@"FOSA"]) {
            FoodViewController *food = [[FoodViewController alloc]init];
             //分割字符串的测试
             food.infoArray = [NSArray array];
             food.infoArray = [firstResult componentsSeparatedByString:@"&"];
             NSLog(@"图片中的食物二维码信息为:%@",food.infoArray);
             food.isAdding = false;
             [imgArray  replaceObjectAtIndex:0 withObject:[self getPartOfImage:image inRect:CGRectMake(0,screen_height/8, screen_width, screen_height/2)]];
            food.food_image = [[NSMutableArray alloc]init];
            food.food_image = imgArray;
            [self.navigationController pushViewController:food animated:YES];
        }else{
            [self SystemAlert:firstResult];
        }
    }
}
- (UIImage *)getPartOfImage:(UIImage *)img inRect:(CGRect)rect
{
    //把像 素rect 转化为 点rect（如无转化则按原图像素取部分图片）
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat x= rect.origin.x*scale,y=rect.origin.y*scale,w=rect.size.width*scale,h=rect.size.height*scale;
    CGRect dianRect = CGRectMake(x, y, w, h);
    
    CGImageRef cgRef = img.CGImage;
    NSLog(@"cgRef:  %@",cgRef);
    CGImageRef imageRef = CGImageCreateWithImageInRect(cgRef, dianRect);
    //UIImage *thumbScale = [UIImage imageWithCGImage:imageRef];
    UIImage *newImage = [UIImage imageWithCGImage:imageRef scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    CGImageRelease(imageRef);
     UIImageWriteToSavedPhotosAlbum(newImage, self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
    return newImage;
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

#pragma mark - 设置在二维码位置显示聚焦光标
- (void)setFocusCursorWithPoint:(AVMetadataMachineReadableCodeObject *)objc
{
    CGPoint point = [self getCenterOfQRcode:objc];
    CGPoint center = CGPointZero;
    center.x = [UIScreen mainScreen].bounds.size.width*(1-point.y);
    center.y = [UIScreen mainScreen].bounds.size.height*(point.x);

    self.focusCursor.center = center;
    self.focusCursor.transform = CGAffineTransformMakeScale(3,3);
    self.focusCursor.alpha = 1.0;
    [UIView animateWithDuration:1.5 animations:^{
        self.focusCursor.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        self.focusCursor.alpha = 0;
    }];
}
- (void)SetFocusOnQRcode1:(AVMetadataMachineReadableCodeObject *)objc
{
    CGPoint point = [self getCenter:objc];
    CGPoint center = CGPointZero;
    center.x = [UIScreen mainScreen].bounds.size.width*(1-point.y);
    center.y = [UIScreen mainScreen].bounds.size.height*(point.x);
    self.focusCursor1.center = center;
    self.focusCursor1.alpha = 1.0;
}
- (void)SetFocusOnQRcode2:(AVMetadataMachineReadableCodeObject *)objc
{
    CGPoint point = [self getCenter:objc];
    CGPoint center = CGPointZero;
    center.x = [UIScreen mainScreen].bounds.size.width*(1-point.y);
    center.y = [UIScreen mainScreen].bounds.size.height*(point.x);
    self.focusCursor2.center = center;
    self.focusCursor2.alpha = 1.0;
}
- (void)SetFocusOnQRcode3:(AVMetadataMachineReadableCodeObject *)objc
{
    CGPoint point = [self getCenter:objc];
    CGPoint center = CGPointZero;
    center.x = [UIScreen mainScreen].bounds.size.width*(1-point.y);
    center.y = [UIScreen mainScreen].bounds.size.height*(point.x);
    self.focusCursor3.center = center;
    self.focusCursor3.alpha = 1.0;
}

#pragma mark- AVCaptureVideoDataOutputSampleBufferDelegate的方法
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
    CFRelease(metadataDict);
    NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
    float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
                //NSLog(@"%f",brightnessValue);
    // 根据brightnessValue的值来打开和关闭闪光灯
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    BOOL result = [device hasTorch];// 判断设备是否有闪光灯
    if ((brightnessValue < -1) && result) {
        //提示打开闪光灯
        [self.view insertSubview:self.flashBtn atIndex:10];
    }else if((brightnessValue > -1) && result) {
        if(device.torchMode == AVCaptureTorchModeOff){
            [self.flashBtn removeFromSuperview];
        }
    }
}
//   隐藏扫码标识
- (void)unShowFocus{
    self.focusCursor.alpha = 0;
    self.focusCursor1.alpha = 0;
    self.focusCursor2.alpha = 0;
    self.focusCursor3.alpha = 0;
}

#pragma mark - 数据库操作
- (void)OpenSqlDatabase:(NSString *)dataBaseName{
    //获取数据库地址
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
    NSLog(@"%@",docPath);
    //设置数据库名
    NSString *fileName = [docPath stringByAppendingPathComponent:dataBaseName];
    //创建数据库
    db = [FMDatabase databaseWithPath:fileName];
    if([db open]){
        NSLog(@"打开数据库成功");
    }else{
        NSLog(@"打开数据库失败");
    }
}

- (FoodModel *)CheckFoodInfoWithName:(NSString *)device{
    
    [self OpenSqlDatabase:@"FOSA"];
    NSString *sql = [NSString stringWithFormat:@"select * from FoodStorageInfo where device = '%@';",device];
    NSLog(@"%@",sql);
    FoodModel *model = [FoodModel modelWithName:@"NO Record" DeviceID:device RemindDate:@"" ExpireDate:@""];
    FMResultSet *set = [db executeQuery:sql];
//    if (set.columnCount == 0) {
//        model = [FoodModel modelWithName:@"NO Record" DeviceID:device RemindDate:@"" ExpireDate:@""];
//    }else{
        if([set next]) {
            NSString *foodName   = [set stringForColumn:@"foodName"];
            NSString *fdevice    = [set stringForColumn:@"device"];
            NSString *remindDate = [set stringForColumn:@"remindDate"];
            NSString *expireDate = [set stringForColumn:@"expireDate"];
            NSLog(@"%@----%@----%@----%@",foodName,fdevice,remindDate,expireDate);
            model.foodName = foodName;
            model.remindDate = remindDate;
            model.expireDate = expireDate;
        }
    //}
    return model;
}

/**隐藏底部横条，点击屏幕可显示*/
- (BOOL)prefersHomeIndicatorAutoHidden{
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    stopAnimation = YES;
    [self.captureSession stopRunning];
    [self unShowFocus];
    [db close];
}

@end
