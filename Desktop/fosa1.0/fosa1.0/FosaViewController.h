//
//  FosaViewController.h
//  fosa1.0
//
//  Created by hs on 2019/10/16.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FosaViewController : UIViewController
@property (nonatomic,strong) UIScrollView *rootScrollview;
@property (nonatomic,strong) UIScrollView *CategoryScrollview;
//@property (nonatomic,strong) UIView

@property (nonatomic,assign) CGFloat mainWidth,mainHeight,navHeight;
@end

NS_ASSUME_NONNULL_END
