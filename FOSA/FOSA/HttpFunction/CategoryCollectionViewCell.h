//
//  CategoryCollectionViewCell.h
//  FOSA
//
//  Created by hs on 2019/12/2.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CategoryModel;
NS_ASSUME_NONNULL_BEGIN

@interface CategoryCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) CategoryModel *model;

@property (nonatomic,strong) UIImageView *categoryIcon;
@property (nonatomic,strong) UILabel *categoryLabel;

@end

NS_ASSUME_NONNULL_END
