//
//  FoodMoreInfoView.h
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FoodModel;
NS_ASSUME_NONNULL_BEGIN

@interface FoodMoreInfoView : UIView
@property (nonatomic,strong) FoodModel *model;
@property (nonatomic,strong) UIButton *close;
/*
 添加子控件属性
 */
@property (nonatomic,weak) UIImageView *iconImageView;
@property (nonatomic,weak) UILabel *nameLabel;
@property (nonatomic,weak) UITextField *foodName,*expireDate,*remindDate;

@end

NS_ASSUME_NONNULL_END
