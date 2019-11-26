//
//  FoodInfoViewController.h
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FoodInfoViewController : UIViewController

//底层视图
@property (nonatomic,strong) UIScrollView *rootScrollview;

//顶部控件
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIImageView *imageView1,*imageView2,*imageView3,*imageView4;

@property (nonatomic,strong) UIButton *share,*like,*takePhoto,*edit;
@property (nonatomic,strong) UITextView *deviceName;

//
@property (nonatomic,strong) UIView *foodNameView,*aboutFoodView,*expireView,*remindView,*locationView,*weightView,*calorieView;
@property (nonatomic,strong) UITextField *foodName,*aboutFood;
@property (nonatomic,strong) UITextView *expireDate,*remindDate,*location,*weight,*calorie;
@property (nonatomic,strong) UIButton *expireBtn,*remindBtn,*locationBtn,*weightBtn,*calBtn;

//记录编辑之前的内容
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) UIImage *food_image;
//屏幕尺度
@property (nonatomic,assign) CGFloat mainWidth,mainheight,navHeight;

//记录当前展示物品所在的Fosa盒子id
@property (nonatomic,strong) NSString *deviceID;
//通过分享二维码打开本页面的食物信息和食物图片
@property (nonatomic,strong) NSArray<NSString *> *infoArray;
@end

NS_ASSUME_NONNULL_END
