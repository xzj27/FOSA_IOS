//
//  FosaAlertView.h
//  fosa1.0
//
//  Created by hs on 2019/10/16.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AlertModel;
@interface FosaAlertView : UIView

@property (nonatomic,strong)AlertModel *model;
@property (nonatomic,weak) UIButton *edited;
@end
