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

#import "SealerTable.h"
//图片宽高的最大值
#define KCompressibilityFactor 1280.00
@interface FosaPoundViewController ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,AVCaptureMetadataOutputObjectsDelegate>{
    //数据数组
    NSArray *arrayData;
    //标记当前是否展开
    Boolean isExpand;
    //table cell的内容
    NSString *foodname,*expireDate,*storageDate;
    
    //标记当前是否正在扫码
    Boolean isScan;
}
@property (nonatomic,strong) UIButton *send;
@end

@implementation FosaPoundViewController

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
    if (_device == nil) {
        _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        //检查相机是否有摄像头
        if(!_device){
            NSLog(@"该设备没有摄像头");
        }
    }
    return _device;
}
- (AVCaptureDeviceInput *)input{
    if (_input == nil) {
        //设备输入 初始化
        _input = [[AVCaptureDeviceInput alloc]initWithDevice:self.device error:nil];
    }
    return _input;
}
- (AVCaptureMetadataOutput *)output{
    if (_output == nil) {
        //设备输出
        _output = [[AVCaptureMetadataOutput alloc]init];
        CGFloat ScreenWidth = self.rootScanView.frame.size.width;
        //设置扫描作用域范围(中间透明的扫描框)
        CGRect intertRect = [self.previewLayer metadataOutputRectOfInterestForRect:CGRectMake(ScreenWidth*0.1, ScreenWidth*0.1, ScreenWidth*0.8, ScreenWidth*0.8)];
        _output.rectOfInterest = intertRect;
    }
    return _output;
}
- (AVCaptureVideoDataOutput *)VideoOutput{
    if (_VideoOutput == nil) {
        _VideoOutput = [[AVCaptureVideoDataOutput alloc]init];
    }
    return _VideoOutput;
}

- (AVCaptureSession *)session{
    if (_session == nil) {
        _session = [[AVCaptureSession alloc]init];
    }
    return _session;
}
- (AVCaptureVideoPreviewLayer *)previewLayer{
    if (_previewLayer == nil) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.session];
    }
    return _previewLayer;
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
            [_session addInput:self.input];
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
    dispatch_queue_t queue = dispatch_queue_create("Sealerqueue", NULL);
    [self.output setMetadataObjectsDelegate:self queue:queue];
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
    
    
    [self ScanOneByOne_ScanView];
    // 开始动画，扫描条上下移动
    [self performSelectorOnMainThread:@selector(timerFired) withObject:nil waitUntilDone:NO];
}

#pragma mark - 单个扫码模式
-(void)ScanOneByOne_ScanView{
    CGFloat imageX = self.rootScanView.frame.size.width*0.1;
    CGFloat imageY = self.rootScanView.frame.size.width*0.1;         // 扫描框中的四个边角的背景图
//         self.scanImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"saoyisao@3x"]];
//         _scanImage.frame = CGRectMake(imageX, imageY, self.view.frame.size.width*0.7, self.view.frame.size.width*0.7);
//         [self.view addSubview:_scanImage];

         // 上下移动的扫描条
         UIImageView *activeImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"saoyisao-3@3x"]];
         activeImage.frame = CGRectMake(imageX, imageY, self.rootScanView.frame.size.width*0.7, 4);
         [self.rootScanView addSubview:activeImage];
         self.activeImage = activeImage;

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
    CGRect intertRect = [_previewLayer metadataOutputRectOfInterestForRect:CGRectMake(imageX, imageY, self.view.frame.size.width*0.8, self.view.frame.size.width*0.8)];
    _output.rectOfInterest = intertRect;
    
//    //添加UISlider用于放大和缩小视图
//    _ZoomSlider = [[UISlider alloc] initWithFrame:CGRectMake(imageX,imageY+self.view.frame.size.width*0.7,self.view.frame.size.width*0.7,20)];
//    [self.view addSubview:_ZoomSlider];
//    _ZoomSlider.minimumValue = 0;
//    _ZoomSlider.maximumValue = 100;
//    [_ZoomSlider addTarget:self action:@selector(ZoomSliderValueChanged) forControlEvents:UIControlEventValueChanged];
}
#pragma mark - 加载扫描线动画
-(void)timerFired {
    [self.activeImage.layer addAnimation:[self moveY:2.5 Y:[NSNumber numberWithFloat:(self.rootScanView.frame.size.width-4)]] forKey:nil];
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
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.mainHeight = [UIScreen mainScreen].bounds.size.height;
    self.mainWidth = [UIScreen mainScreen].bounds.size.width;
    self.navheight = self.navigationController.navigationBar.frame.size.height;
    [self InitView];
    [self InitData];
}
- (void)InitView{
    isScan = false; //扫码标记初始化
    //rootView
    self.rootView.frame = CGRectMake(0, self.navheight, self.mainWidth, self.mainHeight);
    self.rootView.bounces = NO;
    self.rootView.showsVerticalScrollIndicator = NO;
    self.rootView.showsHorizontalScrollIndicator = NO;
    self.rootView.contentSize = CGSizeMake(self.mainWidth,self.mainHeight*2);
    [self.view addSubview:self.rootView];
    //SealerView
    self.sealerView.frame = CGRectMake(5,10,self.mainWidth-10,self.mainHeight/3);
    self.sealerView.backgroundColor = [UIColor colorWithRed:0/255.0 green:191/255.0 blue:227/255.0 alpha:1.0];
    [self.rootView addSubview:self.sealerView];
    //SealerView content
    self.sealerImage.frame = CGRectMake(5, 5, self.sealerView.frame.size.height/2, self.sealerView.frame.size.height/2);
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
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ExpandList:)];
    self.indicator.userInteractionEnabled = YES;
    [self.indicator addGestureRecognizer:recognizer];
    [self.InfoMenu addSubview:_indicator];
    [self.sealerView addSubview:self.InfoMenu];
   // [self setupView];
    [self InitFoodTable];
    
    //分割线
//    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.mainHeight/2, self.mainWidth, 2)];
//    line.backgroundColor = [UIColor grayColor];
//    [self.rootView addSubview:line];
    
    self.poundView.frame = CGRectMake(5, self.mainHeight/3+30, self.mainWidth-10, self.mainHeight/3);
    self.poundView.backgroundColor = [UIColor colorWithRed:254/255.0 green:0/255.0 blue:151/255.0 alpha:1.0];
    [self.rootView addSubview:self.poundView];
    self.poundImage.frame = CGRectMake(5, 5, self.poundView.frame.size.height/2, self.poundView.frame.size.height/2);
    self.poundImage.image = [UIImage imageNamed:@"img_pound.jpg"];
    [self.poundView addSubview:self.poundImage];
    //连接开关
    self.connect = [[UIButton alloc]initWithFrame:CGRectMake(self.poundView.frame.size.width-45, 5, 40, 40)];
    [self.connect setImage:[UIImage imageNamed:@"icon_disconnect"] forState:UIControlStateNormal];
    [self.poundView addSubview:self.connect];
    //重量与卡路里
    self.weightView = [[UIView alloc]initWithFrame:CGRectMake(5, self.poundView.frame.size.height/2+10, self.poundView.frame.size.width*3/4, (self.poundView.frame.size.height-40)/4)];
    self.weight = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.weightView.frame.size.width*2/3, self.weightView.frame.size.height)];
    self.weight.textAlignment = NSTextAlignmentCenter;
    self.weight.backgroundColor = [UIColor clearColor];
    self.weight.layer.borderWidth = 1;
    self.weight.text = @"weight";
    self.weight.userInteractionEnabled = NO;
    self.units = [[UILabel alloc]initWithFrame:CGRectMake(self.weightView.frame.size.width*2/3, 0, self.weightView.frame.size.width/3, self.weightView.frame.size.height)];
    _units.text = @"g";
    _units.font = [UIFont systemFontOfSize:30];
    [self.poundView addSubview:self.weightView];
    [self.weightView addSubview:self.weight];
    [self.weightView addSubview:self.units];
    
    self.calorieView = [[UIView alloc]initWithFrame:CGRectMake(5, self.poundView.frame.size.height*3/4+5, self.poundView.frame.size.width*3/4, (self.poundView.frame.size.height-40)/4)];
    self.calorie = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.calorieView.frame.size.width*2/3, self.calorieView.frame.size.height)];
    self.calorie.textAlignment = NSTextAlignmentCenter;
    self.calorie.backgroundColor = [UIColor clearColor];
    self.calorie.layer.borderWidth = 0.5;
    self.calorie.text = @"calorie";
    self.calorie.userInteractionEnabled = NO;
    self.select = [[UIButton alloc]initWithFrame:CGRectMake(self.calorieView.frame.size.width*2/3, 0, self.calorieView.frame.size.width/3, self.calorieView.frame.size.height)];
    self.select.layer.cornerRadius = 5;
    [self.select setTitle:@"select" forState:UIControlStateNormal];
    self.select.backgroundColor = [UIColor colorWithRed:254/255.0 green:0/255.0 blue:200/255.0 alpha:1.0];
    [self.calorieView addSubview:self.select];
    [self.poundView addSubview:self.calorieView];
    [self.calorieView addSubview:self.calorie];
}
#pragma mark - 食物列表
- (void)ExpandList:(UITapGestureRecognizer *)sender{
    if (!isExpand) {
        self.indicator.image = [UIImage imageNamed:@"caret_open"];
        self.foodTable.hidden = NO;
        CGPoint center = CGPointZero;
        center.x = self.mainWidth/2;
        center.y = self.sealerView.frame.size.height+arrayData.count*40+self.poundView.frame.size.height/2+45;
        self.poundView.center = center;
        isExpand = true;
    }else{
        self.indicator.image = [UIImage imageNamed:@"caret"];
        CGPoint center = CGPointZero;
        center.x = self.mainWidth/2;
        center.y = self.mainHeight/2+30;
        self.poundView.center = center;
        self.foodTable.hidden = YES;
        isExpand = false;
    }
}
- (void)InitData{
    arrayData = @[@"猪肉",@"牛肉",@"三文鱼",@"鲍鱼"];
}

//food table
- (void)InitFoodTable{
    self.foodTable = [[UITableView alloc]initWithFrame:CGRectMake(5, self.sealerView.frame.size.height+10, self.sealerView.frame.size.width,self.sealerView.frame.size.height) style:UITableViewStylePlain];
    _foodTable.delegate = self;
    _foodTable.dataSource = self;
    _foodTable.hidden = YES;
    _foodTable.showsVerticalScrollIndicator = NO;
    
    [_foodTable setSeparatorColor:[UIColor grayColor]];

    [self.rootView insertSubview:_foodTable atIndex:10];
}
//行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
//每组多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayData.count;
}
//多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    //初始化cell，并指定其类型
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        //创建cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    //取消点击cell时显示的背景色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = arrayData[indexPath.row];
    cell.detailTextLabel.text = @"2019/11/20";
    
    //返回cell
    return cell;
}

- (void)ScanAction{
    if (!isScan) {
        [self startScan];
        [self.scanBtn setImage:[UIImage imageNamed:@"icon_finish"] forState:UIControlStateNormal];
        isScan = true;
    }else{
        [self.rootScanView removeFromSuperview];
        [self.scanBtn setImage:[UIImage imageNamed:@"icon_scan"] forState:UIControlStateNormal];
        isScan = false;
    }
}

#pragma mark - 扫码结果
- (void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    AVMetadataMachineReadableCodeObject *object = metadataObjects.firstObject;
    NSString *result = object.stringValue;
    NSLog(@"%@",result);
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.rootScanView removeFromSuperview];
}
@end
