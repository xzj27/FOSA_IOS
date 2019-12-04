//
//  CategoryModel.m
//  FOSA
//
//  Created by hs on 2019/12/2.
//  Copyright © 2019 hs. All rights reserved.
//

#import "CategoryModel.h"

@implementation CategoryModel

+ (instancetype)modelWithName:(NSString *)categoryName categoryIcon:(NSString *)categoryImg{
    return [[self alloc] initWithName:categoryName categoryIcon:categoryImg];
}

- (instancetype) initWithName:(NSString *)categoryName categoryIcon:(NSString *)categoryImg{
    if(self == [super init]){
        self.cagegoryName = categoryName;
        self.categoryImg = categoryImg;
    }
    return self;
}
@end
