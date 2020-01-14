//
//  FoodModel.m
//  FOSAapp1.0
//
//  Created by hs on 2019/12/30.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FoodModel.h"
@implementation FoodModel

/**collectionViewCellModel*/
+ (instancetype)modelWithName:(NSString *)food_name foodIcon:(NSString *)foodPhoto remind_date:(NSString *)remindDate fdevice:(NSString *)device{
    return [[self alloc]initWithName:food_name foodIcon:foodPhoto remind_date:remindDate fdevice:device];
}
- (instancetype)initWithName:(NSString *)food_name foodIcon:(NSString *)foodPhoto remind_date:(NSString *)remindDate fdevice:(NSString *)device{
    if(self == [super init]){
        self.foodName = food_name;
        self.foodPhoto = foodPhoto;
        self.remindDate = remindDate;
        self.device = device;
    }
    return self;
}

/**SealerTableViewCell*/
+ (instancetype)modelWithName:(NSString *)food_name expireDate:(NSString *)expireDate storageDate:(NSString *)storageDate fdevice:(NSString *)device photoPath:(NSString *)foodPhoto{
    return [[self alloc]initWithName:food_name expireDate:expireDate storageDate:storageDate fdevice:device photoPath:foodPhoto];
}
- (instancetype)initWithName:(NSString *)food_name expireDate:(NSString *)expireDate storageDate:(NSString *)storageDate fdevice:(NSString *)device photoPath:(NSString *)foodPhoto{
    if(self == [super init]){
        self.foodName = food_name;
        self.expireDate = expireDate;
        self.storageDate = storageDate;
        self.device = device;
        self.foodPhoto = foodPhoto;
    }
    return self;
}

//add food
+ (instancetype)modelWithName:(NSString *)food_name DeviceID:(NSString *)device Description:(NSString *)aboutFood RemindDate:(NSString *)remindDate ExpireDate:(NSString *)expireDate foodIcon:(NSString *)foodPhoto category:(nonnull NSString *)category{
    return [[self alloc]initWithName:food_name DeviceID:device Description:aboutFood RemindDate:remindDate ExpireDate:expireDate foodIcon:foodPhoto category:category];
}
- (instancetype)initWithName:(NSString *)food_name DeviceID:(NSString *)device Description:(NSString *)aboutFood RemindDate:(NSString *)remindDate ExpireDate:(NSString *)expireDate foodIcon:(NSString *)foodPhoto category:(nonnull NSString *)category{
    if(self == [super init]){
        self.foodName = food_name;
        self.aboutFood = aboutFood;
        self.expireDate = expireDate;
        self.remindDate = remindDate;
        self.device = device;
        self.foodPhoto = foodPhoto;
        self.category = category;
    }
    return self;
}

//show info
+ (instancetype)modelWithName:(NSString *)food_name DeviceID:(NSString *)device RemindDate:(NSString *)remindDate ExpireDate:(NSString *)expireDate{
    return [[self alloc]initWithName:food_name DeviceID:device RemindDate:remindDate ExpireDate:expireDate];
}
- (instancetype)initWithName:(NSString *)food_name DeviceID:(NSString *)device RemindDate:(NSString *)remindDate ExpireDate:(NSString *)expireDate{
    if(self == [super init]){
        self.foodName = food_name;
        self.expireDate = expireDate;
        self.remindDate = remindDate;
        self.device = device;

    }
    return self;
}

@end
