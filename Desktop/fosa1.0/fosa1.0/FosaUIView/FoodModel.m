//
//  FoodModel.m
//  fosa1.0
//
//  Created by hs on 2019/10/30.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FoodModel.h"

@implementation FoodModel

+ (instancetype)modelWithName:(NSString *)food_name foodIcon:(NSString *)foodPhoto expire_date:(NSString *)expiredDate fdevice:(NSString *)device{
    return [[self alloc]initWithName:food_name foodIcon:foodPhoto expire_date:expiredDate fdevice:device];
}

- (instancetype)initWithName:(NSString *)food_name foodIcon:(NSString *)foodPhoto expire_date:(NSString *)expiredDate fdevice:(NSString *)device{
    if (self == [super init]) {
        self.foodName = food_name;
        self.foodPhoto = foodPhoto;
        self.expiredDate = expiredDate;
        self.device = device;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
