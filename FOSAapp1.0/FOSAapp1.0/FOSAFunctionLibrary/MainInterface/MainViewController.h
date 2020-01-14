//
//  MainViewController.h
//  FOSAapp1.0
//
//  Created by hs on 2019/12/30.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FOSAFlowLayout.h"
#import "FoodItemCollectionViewCell.h"
#import "FoodModel.h"
#import "QRCodeScanViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MainViewController : UIViewController

/**
 CategoryMenutable:种类菜单
 visualView:高斯模糊层
 menuDataSource:种类菜单数据源
 collectionDataSource:存储食物展示Item数据源
 cellDic
 FOSALayout
 foodItemCollection
 */

@property (strong,nonatomic) UITableView *CategoryMenuTable;
@property (strong,nonatomic) UIVisualEffectView *visualView;

@property (strong,nonatomic) NSMutableArray<NSString *> *menuDataSource;
@property (strong,nonatomic) NSMutableArray<FoodModel *> *collectionDataSource;
@property (nonatomic,strong) NSMutableArray<NSString *> *cellDic;
@property (nonatomic, strong) NSMutableDictionary *cellDictionary;
@property (nonatomic,strong) UIRefreshControl *refresh;

@property (strong,nonatomic) UIImageView *mainImageView;
@property (strong,nonatomic) FOSAFlowLayout *FOSALayout;
@property (strong,nonatomic) UICollectionView *foodItemCollection;
@property (strong,nonatomic) UIButton *addContentBtn;

@end

NS_ASSUME_NONNULL_END
