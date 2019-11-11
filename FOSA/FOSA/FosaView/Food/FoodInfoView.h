//
//  FoodInfoView.h
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FoodModel;
@interface FoodInfoView : UIView

@property (nonatomic,strong)FoodModel *model;
@property (nonatomic,weak) UIButton *edited;
@end
