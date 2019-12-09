//
//  NutrientModel.h
//  FOSA
//
//  Created by hs on 2019/12/9.
//  Copyright © 2019 hs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NutrientModel : NSObject

@property (nonatomic,copy) NSString *NutritionalIngredient,*content;

+ (instancetype)modelWithName:(NSString *)NutritionalIngredient cotent:(NSString *)content ;
- (instancetype)initWithName:(NSString *)NutritionalIngredient content:(NSString *)content;



@end

NS_ASSUME_NONNULL_END
