//
//  FoodModel.h
//  fosa1.0
//
//  Created by hs on 2019/10/30.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FoodModel : UIView

@property (nonatomic,copy) NSString *foodName,*expiredDate,*foodPhoto,*device;

+ (instancetype)modelWithName:(NSString *) food_name foodIcon:(NSString *)foodPhoto expire_date:(NSString *) expiredDate fdevice:(NSString *)device;
- (instancetype)initWithName: (NSString *) food_name foodIcon:(NSString *)foodPhoto expire_date:(NSString *) expiredDate fdevice:(NSString *)device;

@end

NS_ASSUME_NONNULL_END
