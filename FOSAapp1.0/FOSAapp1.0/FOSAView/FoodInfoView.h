//
//  FoodInfoView.h
//  FOSAapp1.0
//
//  Created by hs on 2020/1/13.
//  Copyright © 2020 hs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FoodModel;
NS_ASSUME_NONNULL_BEGIN

@interface FoodInfoView : UIView
@property (nonatomic,strong) FoodModel *model;
@property (nonatomic,strong) UIButton *close;
@end

NS_ASSUME_NONNULL_END
