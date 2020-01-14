//
//  FoodInfoView.m
//  FOSAapp1.0
//
//  Created by hs on 2020/1/13.
//  Copyright © 2020 hs. All rights reserved.
//

#import "FoodInfoView.h"
#import "FoodModel.h"
@interface FoodInfoView()
/*
 添加子控件属性
 */
@property (nonatomic,weak) UIImageView *iconImageView;
@property (nonatomic,weak) UILabel *deviceLabel,*nameLabel,*expireLabel,*remindLabel;

@end

@implementation FoodInfoView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat width = self.bounds.size.width;
        CGFloat height = self.bounds.size.height;
        self.close = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, height/4, height/4)];
        [self.close setBackgroundImage:[UIImage imageNamed:@"icon_closeAlert"] forState:UIControlStateNormal];
        [self addSubview:self.close];
        
        UILabel *deviceLable = [[UILabel alloc]initWithFrame:CGRectMake(height/4, 0, width-height/4, height/4)];
        self.deviceLabel = deviceLable;
        self.deviceLabel.textAlignment = NSTextAlignmentCenter;
        
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(width/8, height/4, height/2, height/2)];
        self.iconImageView = imgView;
        self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.width/2;
        [self addSubview:self.iconImageView];
        
        UILabel *nameLable = [[UILabel alloc]initWithFrame:CGRectMake(height/2+width/4, height/4, width*3/4-height/2, height/4)];
        self.nameLabel = nameLable;
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.backgroundColor = FOSAFoodBackgroundColor;
        self.nameLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        [self addSubview:self.nameLabel];
        
        UILabel *remindDate = [[UILabel alloc]initWithFrame:CGRectMake(height/2+width/4, height/2, width*3/4-height/2, height/4)];
        self.remindLabel = remindDate;
        self.remindLabel.textAlignment = NSTextAlignmentCenter;
        self.remindLabel.backgroundColor = FOSAFoodBackgroundColor;
        [self addSubview:self.remindLabel];
        
        UILabel *expireDate = [[UILabel alloc]initWithFrame:CGRectMake(height/2+width/4, height*3/4, width*3/4-height/2, height/4)];
        self.expireLabel = expireDate;
        self.expireLabel.textAlignment = NSTextAlignmentCenter;
        self.expireLabel.backgroundColor = FOSAFoodBackgroundColor;
        [self addSubview:expireDate];

    }
    return self;
}
- (void)setModel:(FoodModel *)model{
    _model = model;
    self.nameLabel.text = model.foodName;
    self.remindLabel.text = model.remindDate;
    self.expireLabel.text = model.expireDate;
}
@end
