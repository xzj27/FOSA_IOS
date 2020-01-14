//
//  PortraitScanView.h
//  FOSAapp1.0
//
//  Created by hs on 2019/12/31.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PortraitScanView : UIView

@property (nonatomic, weak)  UIImageView *activeImage;       //扫描框
@property (nonatomic,strong) UIImageView *scanImage;         //扫描线
@property (nonatomic,strong) UIView *maskView;               //扫描面板

@property (nonatomic,strong) UIButton *flashBtn;             //闪光灯
@property (nonatomic,strong) UISlider *ZoomSlider;           //用于放大缩小视图

@end

NS_ASSUME_NONNULL_END
