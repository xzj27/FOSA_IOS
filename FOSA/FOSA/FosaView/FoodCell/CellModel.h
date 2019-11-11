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

@property (nonatomic,copy) NSString *foodName,*expiredDate,*foodPhoto,*device;

+ (instancetype)modelWithName:(NSString *) food_name foodIcon:(NSString *)foodPhoto expire_date:(NSString *) expiredDate fdevice:(NSString *)device;
- (instancetype)initWithName: (NSString *) food_name foodIcon:(NSString *)foodPhoto expire_date:(NSString *) expiredDate fdevice:(NSString *)device;

@end

NS_ASSUME_NONNULL_END
