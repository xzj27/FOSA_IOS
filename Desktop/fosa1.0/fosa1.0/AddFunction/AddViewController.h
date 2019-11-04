//
//  AddViewController.h
//  fosa1.0
//
//  Created by hs on 2019/10/17.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AddViewController : UIViewController

//底层视图
@property (nonatomic,strong) UIScrollView *rootScrollview;

//顶部控件
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIImageView *imageView1,*imageView2,*imageView3,*imageView4;
@property (nonatomic,strong) UIImage *food_image;
@property (nonatomic,strong) UIButton *share,*like;
@property (nonatomic,strong) UITextView *deviceName;

//
@property (nonatomic,strong) UIView *foodNameView,*expireView,*remindView,*locationView,*weightView,*calorieView;
@property (nonatomic,strong) UITextField *foodName,*aboutFood;
@property (nonatomic,strong) UITextView *expireDate,*remindDate,*location,*weight,*calorie;
@property (nonatomic,strong) UIButton *expireBtn,*remindBtn,*locationBtn,*weightBtn,*calBtn;

//屏幕尺度
@property (nonatomic,assign) CGFloat mainWidth,mainheight,navHeight;
@end

NS_ASSUME_NONNULL_END
