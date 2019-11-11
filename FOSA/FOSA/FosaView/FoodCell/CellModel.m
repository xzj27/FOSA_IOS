//
//  CellModel.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "CellModel.h"

@implementation CellModel
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
@end
