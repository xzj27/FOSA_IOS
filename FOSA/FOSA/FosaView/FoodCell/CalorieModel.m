//
//  CalorieModel.m
//  FOSA
//
//  Created by hs on 2019/12/6.
//  Copyright © 2019 hs. All rights reserved.
//

#import "CalorieModel.h"

@implementation CalorieModel

+ (instancetype)modelWithTextValue:(NSString *)weight calorie:(NSString *)calorie{
    return [[self alloc]initwithTextValue:weight calorie:calorie];
}
- (instancetype)initwithTextValue:(NSString *)weight calorie:(NSString *)calorie{
    if (self == [self init]) {
        self.weight = weight;
        self.calorie = calorie;
    }
    return self;
}

@end
