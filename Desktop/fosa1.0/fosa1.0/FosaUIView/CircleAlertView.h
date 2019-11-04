//
//  CircleAlertView.h
//  fosa1.0
//
//  Created by hs on 2019/10/23.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AlertModel;
NS_ASSUME_NONNULL_BEGIN

@interface CircleAlertView : UIView
@property (nonatomic,strong) AlertModel *model;
@property (nonatomic,strong) UIButton *close;
@end

NS_ASSUME_NONNULL_END
