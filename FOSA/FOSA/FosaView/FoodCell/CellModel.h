//
//  CellModel.h
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CellModel : NSObject

@property (nonatomic,copy) NSString *foodName,*remindDate,*foodPhoto,*device,*expireDate,*storageDate;

+ (instancetype)modelWithName:(NSString *) food_name foodIcon:(NSString *)foodPhoto remind_date:(NSString *) remindDate fdevice:(NSString *)device;
- (instancetype)initWithName: (NSString *) food_name foodIcon:(NSString *)foodPhoto remind_date:(NSString *) remindDate fdevice:(NSString *)device;

//sealer
+ (instancetype)modelWithName:(NSString *)food_name expireDate:(NSString*)expireDate storageDate:(NSString *)storageDate;
- (instancetype)initWithName:(NSString *)food_name expireDate:(NSString*)expireDate storageDate:(NSString *)storageDate;

@end

NS_ASSUME_NONNULL_END
