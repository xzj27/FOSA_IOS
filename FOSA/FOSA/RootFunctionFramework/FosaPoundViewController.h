//
//  FosaPoundViewController.h
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FosaPoundViewController : ViewController


@property (nonatomic,strong) UIScrollView *rootView;
@property (nonatomic,strong) UIView *sealerView,*poundView,*InfoMenu;
@property (nonatomic,strong) UIImageView *sealerImage,*poundImage;
//sealer
@property (nonatomic,strong) UIImageView *indicator;
@property (nonatomic,strong) UIButton *scanBtn;
@property (nonatomic,strong) UITableView *foodTable;
//pound
@property (nonatomic,strong) UIView *weightView,*calorieView;
@property (nonatomic,strong) UITextView *weight,*calorie;
@property (nonatomic,strong) UILabel *units;

@property (nonatomic,assign) CGFloat mainWidth,mainHeight,navheight;
@property (nonatomic,strong) UIButton *connect,*select;

@end

NS_ASSUME_NONNULL_END
