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

@property (nonatomic,strong) NSString *food,*foodkind,*foodicon;
@property (nonatomic,strong) UIView *Header;
@property (nonatomic,strong) UILabel *foodNameLabel,*tips;
@property (nonatomic,strong) UIImageView *categoryIcon;
@property (nonatomic,strong) UITableView *nutrientList;
@property (nonatomic,assign) NSInteger current;

@end

NS_ASSUME_NONNULL_END
