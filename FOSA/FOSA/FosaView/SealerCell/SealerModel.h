//
//  SealerModel.h
//  FOSA
//
//  Created by hs on 2019/11/20.
//  Copyright © 2019 hs. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SealerModel : NSObject

@property(nonatomic, assign) int classNo;
@property(nonatomic, strong) NSString *className;
@property(nonatomic, strong) NSString *title;

@end

NS_ASSUME_NONNULL_END
