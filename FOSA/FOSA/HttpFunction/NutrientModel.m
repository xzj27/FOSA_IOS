//
//  NutrientModel.m
//  FOSA
//
//  Created by hs on 2019/12/9.
//  Copyright © 2019 hs. All rights reserved.
//

#import "NutrientModel.h"

@implementation NutrientModel

+ (instancetype)modelWithName:(NSString *)NutritionalIngredient cotent:(NSString *)content{
    return [[self alloc]initWithName:NutritionalIngredient content:content];
}
- (instancetype)initWithName:(NSString *)NutritionalIngredient content:(NSString *)content{
    if (self == [super init]) {
        self.NutritionalIngredient = NutritionalIngredient;
        self.content = content;
    }
    return self;
}

@end
