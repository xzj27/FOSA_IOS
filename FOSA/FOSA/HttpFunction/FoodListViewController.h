//
//  FoodListViewController.h
//  FOSA
//
//  Created by hs on 2019/12/3.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FoodListViewController : UIViewController

@property (nonatomic,assign) long int foodType;
@property (nonatomic,strong) UITableView *foodList;

@end

NS_ASSUME_NONNULL_END
