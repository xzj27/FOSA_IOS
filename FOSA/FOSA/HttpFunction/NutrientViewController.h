//
//  NutrientViewController.h
//  FOSA
//
//  Created by hs on 2019/12/5.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NutrientViewController : UIViewController

@property (nonatomic,strong) NSMutableArray *nutrientData;
@property (nonatomic,strong) UITableView *nutrientList;
@end

NS_ASSUME_NONNULL_END
