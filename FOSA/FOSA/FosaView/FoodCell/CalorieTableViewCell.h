//
//  CalorieTableViewCell.h
//  FOSA
//
//  Created by hs on 2019/12/4.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface CalorieTableViewCell : UITableViewCell

@property (nonatomic,strong) UIView *backView;
@property (nonatomic,strong) UIButton *delete_cell,*select,*units;
@property (nonatomic,strong) UILabel *foodName;
@property (nonatomic,strong) UITextField *weight;
@property (nonatomic,strong) UITextView *calorie;

@end

NS_ASSUME_NONNULL_END
