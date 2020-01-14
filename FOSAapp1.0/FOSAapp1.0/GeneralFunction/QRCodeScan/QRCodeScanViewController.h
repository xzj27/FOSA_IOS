//
//  QRCodeScanViewController.h
//  FOSAapp1.0
//
//  Created by hs on 2019/12/31.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Fosa_QRCode_Queue.h"
#import "Fosa_NSString_Queue.h"
#import "ResultViewController.h"
#import "FoodViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface QRCodeScanViewController : UIViewController
//扫码界面
@property (nonatomic,strong)  UIImageView *scanFrame;       //扫描框
@property (nonatomic,strong) UIImageView *scanLine;         //扫描线
@property (nonatomic,strong) UIView *scanMaskView;               //扫描面板
@property (nonatomic,strong) UIButton *flashBtn;             //闪光灯
@property (nonatomic,strong) UISlider *zoomSlider;           //用于放大缩小视图


@property (nonatomic, strong) AVCaptureDevice *captureDevice;
@property (nonatomic, strong) AVCaptureDeviceInput *captureInput;
@property (nonatomic, strong) AVCaptureMetadataOutput * captureOutput;//元数据输出流，需要指定他的输出类型及扫描范围
@property (nonatomic,strong) AVCaptureVideoDataOutput *VideoOutput;
@property (nonatomic, strong) AVCaptureSession * captureSession; //AVFoundation框架捕获类的中心枢纽，协调输入输出设备以获得数据
@property (nonatomic, strong) AVCaptureVideoPreviewLayer * previewLayer;//展示捕获图像的图层，是CALayer的子类
@property (nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;//照片输出流


@property (nonatomic,strong) UIImageView *focusCursor,*focusCursor1,*focusCursor2,*focusCursor3;       //标记二维码的位置
@property (nonatomic ,strong) UILabel *label,*myQrcode;      //提示信息，选取我的二维码
@property(nonatomic,assign) CGFloat scale;      //记录上一次放大的倍数；
@property(nonatomic,assign) int count;          //统计弹窗的个数
@property(nonatomic,assign) BOOL isGetResult;   //判断是否读取到二维码信息
//扫描结果
@property(nonatomic,strong)NSMutableArray<NSString *> *array;   //save the content of the qrcode
//存储二维码数据的队列
@property (nonatomic,strong) Fosa_QRCode_Queue *codeQueue;
@property (nonatomic,strong) Fosa_NSString_Queue *QRcode;
@property (nonatomic,assign) CGFloat centerPoint;
@property (nonatomic,assign) int flag;

@property (nonatomic,weak) UIImage *QRimage;
@property (nonatomic,strong) NSMutableArray<UIImage *> *food_photo;// 食物图片数组

//自定义内容弹框
////每次扫描多个
//@property (nonatomic,strong) FoodInfoView *contentAlertView;

// 用于禁止与用户交互的view
@property (nonatomic,weak) UIView *forbidview;
//每次扫描一个
//@property (nonatomic,strong) FoodInfoView *fosaAlertView;
@property(nonatomic,assign) int ScanModel;      //determine the current scanning model:0 for which Scan QRCode for everytime,1 for which scan three or four QrCode for every time
@end

NS_ASSUME_NONNULL_END
