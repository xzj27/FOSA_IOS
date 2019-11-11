//
//  AlertModel.h
//  fosa1.0
//
//  Created by hs on 2019/10/16.
//  Copyright © 2019 hs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlertModel : NSObject
/*
 food name
 */
@property (nonatomic,copy) NSString *food_name;
/*
 device name
 */
@property (nonatomic,copy) NSString *device_name;
/*
 the picture of the food
 */
@property (nonatomic,copy) NSString *icon;
/*
 expiration date and reminder date
 */
@property (nonatomic,copy) NSString *expire_date;
@property (nonatomic,copy) NSString *remind_date;

/*
 function
 */
+ (instancetype)modelWithName:(NSString *) food_name device_name:(NSString *) device_name icon:(NSString *)icon expire_date:(NSString *) expire_date remind_date:(NSString *)remind_date;
- (instancetype)initWithName: (NSString *) food_name device_name:(NSString *) device_name icon:(NSString *)icon expire_date:(NSString *) expire_date remind_date:(NSString *)remind_date;
@end

NS_ASSUME_NONNULL_END
