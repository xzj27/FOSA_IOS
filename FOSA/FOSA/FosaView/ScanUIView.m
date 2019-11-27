//
//  ScanUIView.m
//  FOSA
//
//  Created by hs on 2019/11/27.
//  Copyright © 2019 hs. All rights reserved.
//

#import "ScanUIView.h"
#import <AVFoundation/AVFoundation.h>
@interface ScanUIView()<AVCaptureMetadataOutputObjectsDelegate>
@end


@implementation ScanUIView


#pragma mark - 懒加载属性
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
        CGFloat ScreenWidth = self.bounds.size.width;
        //设置扫描作用域范围(中间透明的扫描框)
        CGRect intertRect = [self.previewLayer metadataOutputRectOfInterestForRect:CGRectMake(ScreenWidth*0.15, ScreenWidth*0.15+64, ScreenWidth*0.7, ScreenWidth*0.7)];
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


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self CreatScaningView];
    }
    return self;
}

- (void)CreatScaningView
{
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
       dispatch_queue_t queue = dispatch_queue_create("myqueue", NULL);
       [self.output setMetadataObjectsDelegate:self queue:queue];
       //视频流输出
        [self.VideoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
       //添加预览图层
       self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
       self.previewLayer.frame = self.bounds;
       [self.layer addSublayer:self.previewLayer];
       //开始捕获
       [self.session startRunning];
       
       //设置device的功能
       [self.input.device lockForConfiguration:nil];
       
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
}
@end
