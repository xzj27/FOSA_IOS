//
//  MenuModel.h
//  fosa1.0
//
//  Created by hs on 2019/10/31.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MenuModel : UIView

@property (nonatomic,copy) NSString *color,*categoryName;

+ (instancetype)modelWithName:(NSString *) category;
- (instancetype)initWithName:(NSString *) category;

@end

NS_ASSUME_NONNULL_END
