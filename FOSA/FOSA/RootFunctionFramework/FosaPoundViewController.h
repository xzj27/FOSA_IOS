//
//  FosaPoundViewController.h
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CalorieModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FosaPoundViewController : ViewController


@property (nonatomic,strong) UIScrollView *rootView;
@property (nonatomic,strong) UIView *sealerView,*poundView,*InfoMenu,*scanView;
@property (nonatomic,strong) UIImageView *sealerImage,*poundImage;
//sealer
@property (nonatomic,strong) UIImageView *indicator;
@property (nonatomic,strong) UIButton *scanBtn;
@property (nonatomic,strong) UITableView *foodTable;
//pound
@property (nonatomic,strong) UIView *weightView,*calorieView;

@property (nonatomic,strong) UIButton *connect,*select,*units;

//clorieResult
@property (nonatomic,strong) UIView *calorieResultView;
@property (nonatomic,strong) UILabel *totalcalorieLabel;
@property (nonatomic,strong) UITextView *Allcalorie;
@property (nonatomic,strong) UIButton *addCalorie;
@property (nonatomic,strong) UITableView *calorieTable;
@property (nonatomic,strong) NSMutableArray<CalorieModel *> *calorieData;
///**扫码相关*/
@property (nonatomic,strong) UIView *rootScanView;
@end

NS_ASSUME_NONNULL_END
