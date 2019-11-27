//
//  ScanUIView.h
//  FOSA
//
//  Created by hs on 2019/11/27.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScanUIView : UIView

@property (nonatomic, strong) AVCaptureDevice * device;
@property (nonatomic, strong) AVCaptureDeviceInput * input;
@property (nonatomic, strong) AVCaptureMetadataOutput * output;//元数据输出流，需要指定他的输出类型及扫描范围
@property (nonatomic,strong) AVCaptureVideoDataOutput *VideoOutput;
@property (nonatomic, strong) AVCaptureSession * session; //AVFoundation框架捕获类的中心枢纽，协调输入输出设备以获得数据
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * previewLayer;//展示捕获图像的图层，是CALayer的子类

@property (nonatomic, weak)  UIImageView *activeImage;       //扫描框
@property (nonatomic,strong) UIImageView *scanImage;         //扫描线
@property (nonatomic,strong) UIView *maskView;               //扫描面板

@end

NS_ASSUME_NONNULL_END
