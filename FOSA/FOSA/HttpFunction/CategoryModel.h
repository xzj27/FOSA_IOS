//
//  CategoryModel.h
//  FOSA
//
//  Created by hs on 2019/12/2.
//  Copyright © 2019 hs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CategoryModel : NSObject

@property (nonatomic,strong) NSString *categoryImg,*cagegoryName;

+ (instancetype)modelWithName:(NSString *)categoryName categoryIcon:(NSString *)categoryImg ;
- (instancetype)initWithName:(NSString *)categoryName categoryIcon:(NSString *)categoryImg;

@end

NS_ASSUME_NONNULL_END
