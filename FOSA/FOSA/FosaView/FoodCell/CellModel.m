//
//  CellModel.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "CellModel.h"

@implementation CellModel
    + (instancetype)modelWithName:(NSString *)food_name foodIcon:(NSString *)foodPhoto remind_date:(NSString *)remindDate fdevice:(NSString *)device{
        return [[self alloc]initWithName:food_name foodIcon:foodPhoto remind_date:remindDate fdevice:device];
    }

    - (instancetype)initWithName:(NSString *)food_name foodIcon:(NSString *)foodPhoto remind_date:(NSString *)remindDate fdevice:(NSString *)device{
        if (self == [super init]) {
            self.foodName = food_name;
            self.foodPhoto = foodPhoto;
            self.remindDate = remindDate;
            self.device = device;
        }
        return self;
    }
@end
