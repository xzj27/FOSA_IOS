//
//  FoodModel.h
//  FOSAapp1.0
//
//  Created by hs on 2019/12/30.
//  Copyright © 2019 hs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FoodModel : NSObject
@property (nonatomic,copy) NSString *foodName,*aboutFood,*foodPhoto
                                    ,*remindDate,*device,*expireDate
                                    ,*storageDate,*calorie,*weight,*location,*category;

/**collectionViewCellModel*/
+ (instancetype)modelWithName:(NSString *) food_name foodIcon:(NSString *)foodPhoto remind_date:(NSString *) remindDate fdevice:(NSString *)device;
- (instancetype)initWithName: (NSString *) food_name foodIcon:(NSString *)foodPhoto remind_date:(NSString *) remindDate fdevice:(NSString *)device;

/**SealerTableViewCell*/
+ (instancetype)modelWithName:(NSString *)food_name expireDate:(NSString*)expireDate storageDate:(NSString *)storageDate fdevice:(NSString *)device photoPath:(NSString *)foodPhoto;
- (instancetype)initWithName:(NSString *)food_name expireDate:(NSString *)expireDate storageDate:(NSString *)storageDate fdevice:(NSString *)device photoPath:(NSString *)foodPhoto;

//add food
+ (instancetype)modelWithName:(NSString *) food_name DeviceID:(NSString *)device Description:(NSString *)aboutFood RemindDate:(NSString *)remindDate ExpireDate:(NSString *)expireDate  foodIcon:(NSString *)foodPhoto category:(NSString *)category;
- (instancetype)initWithName:(NSString *) food_name DeviceID:(NSString *)device Description:(NSString *)aboutFood RemindDate:(NSString *)remindDate ExpireDate:(NSString *)expireDate  foodIcon:(NSString *)foodPhoto category:(NSString *)category;

//show info
+ (instancetype)modelWithName:(NSString *) food_name DeviceID:(NSString *)device RemindDate:(NSString *)remindDate ExpireDate:(NSString *)expireDate;
- (instancetype)initWithName:(NSString *) food_name DeviceID:(NSString *)device RemindDate:(NSString *)remindDate ExpireDate:(NSString *)expireDate;

@end

NS_ASSUME_NONNULL_END
