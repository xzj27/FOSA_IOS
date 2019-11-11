//
//  MenuModel.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "MenuModel.h"

@implementation MenuModel

+ (instancetype)modelWithName:(NSString *)category{
    return [[self alloc]initWithName:category];
}
- (instancetype)initWithName:(NSString *)category{
   if(self == [super init]){
      self.categoryName = category;
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
