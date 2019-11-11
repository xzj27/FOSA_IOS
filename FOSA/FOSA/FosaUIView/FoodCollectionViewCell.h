//
//  FoodCollectionViewCell.h
//  fosa1.0
//
//  Created by hs on 2019/11/6.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FoodModel;
NS_ASSUME_NONNULL_BEGIN

@interface FoodCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong)  FoodModel *model;

@property (nonatomic,strong) UILabel *nameLabel,*dateLabel;
@property (nonatomic,strong) UIImageView *foodImageview,*deleteIcon,*cancelIcon;
@end

NS_ASSUME_NONNULL_END
