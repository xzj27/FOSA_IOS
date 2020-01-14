//
//  FoodViewController.h
//  FOSAapp1.0
//
//  Created by hs on 2020/1/3.
//  Copyright © 2020 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FoodViewController : UIViewController

//区分添加信息与查看信息
@property (nonatomic,assign) Boolean isAdding;
/**导航栏*/
@property (nonatomic,strong) UIButton *finishAndEdit;
/**底部滚动视图*/
@property (nonatomic,strong) UIScrollView *rootScrollerView;
/**轮播器滚动控件*/
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIScrollView *pictureScrollerView;
@property (nonatomic,strong) UIPageControl *pageControl;
@property (nonatomic,strong) NSMutableArray<UIImage *> *food_image;
@property (nonatomic,strong) NSString *device;
/**食物信息模块*/
@property (nonatomic,strong) UIView *foodInfoView;
@property (nonatomic,strong) UITextField *foodNameInput;
@property (nonatomic,strong) UITextView  *aboutFoodInput;
@property (nonatomic,strong) UIButton *shareBtn,*likeBtn;
@property (nonatomic,strong) UILabel *numberLable;
/**日期模块*/
@property (nonatomic,strong) UIView *DateView;
@property (nonatomic,strong) UIButton *remindBtn,*expireBtn;
@property (nonatomic,strong) UILabel *remindLable,*expireLable,*remindDateLable,*expireDateLable;
/**卡路里与重量模块*/
@property (nonatomic,strong) UIView *storageView,*calorieView,*weightView;
@property (nonatomic,strong) UIButton *locationbtn,*weightBtn,*calorieBtn;
@property (nonatomic,strong) UITextField *locationField,*weightField,*calorieField;
@property (nonatomic,strong) UILabel *weightUnit,*calorieUnit,*locationLable,*weightLable,*calorieLable;
/**分类模块*/
//adding
@property (nonatomic,strong) UIView *categoryView;
@property (nonatomic,strong) UIButton *categoryBtn;
@property (nonatomic,strong) UICollectionView *categoryContent;
//info
@property (nonatomic,strong) UIView *showCategoryView;
@property (nonatomic,strong) UILabel *categoryTitleLable,*categoryLable;

//通过分享二维码打开本页面的食物信息和食物图片
@property (nonatomic,strong) NSArray<NSString *> *infoArray;
//@property (nonatomic,strong)

@end

NS_ASSUME_NONNULL_END
