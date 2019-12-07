//
//  CalorieModel.h
//  FOSA
//
//  Created by hs on 2019/12/6.
//  Copyright © 2019 hs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CalorieModel : NSObject

@property (nonatomic,copy) NSString *weight,*calorie;


+ (instancetype)modelWithTextValue:(NSString *)weight calorie:(NSString *) calorie;
- (instancetype)initwithTextValue:(NSString *)weight calorie:(NSString *) calorie;


@end

NS_ASSUME_NONNULL_END
