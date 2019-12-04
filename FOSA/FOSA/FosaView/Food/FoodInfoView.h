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
/*
 添加子控件属性
 */
@property (nonatomic,weak) UIImageView *iconImageView;
@property (nonatomic,weak) UILabel *nameLabel,*foodLabel,*expireLabel,*remindLabel;
@property (nonatomic,weak) UITextField *foodName,*expireDate,*remindDate;
@end
