//
//  PhotoViewController2.h
//  FOSA
//
//  Created by hs on 2019/12/27.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
NS_ASSUME_NONNULL_BEGIN

@interface PhotoViewController2 : UIViewController
@property (nonatomic,strong) UIImageView *pictureView2;
@property (nonatomic,strong) NSMutableArray<UIImage *> *imageArray2;

@property (nonatomic, strong) AVCaptureSession *captureSession;//负责输入和输出设备之间的数据传递
@property (nonatomic, strong) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据
@property (nonatomic, strong) AVCaptureStillImageOutput *captureStillImageOutput;//照片输出流
//@property (nonatomic,strong) AVCapturePhotoOutput *imageOutput; //图片输出流 （iOS10之后）
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层
@end

NS_ASSUME_NONNULL_END
