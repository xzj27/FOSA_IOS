//
//  ScanInfoView.h
//  FOSAapp1.0
//
//  Created by hs on 2020/1/3.
//  Copyright © 2020 hs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FoodModel;
NS_ASSUME_NONNULL_BEGIN

@interface ScanInfoView : UIView

@property (nonatomic,weak) UILabel *deviceLabel;
@property (nonatomic,weak) UITextView *foodName,*remindDate,*expireDate;
@property (nonatomic,weak) UIImageView *foodIcon;
@property (nonatomic,weak) UIButton *close;
@property (nonatomic,strong) FoodModel *model;

@end

NS_ASSUME_NONNULL_END
