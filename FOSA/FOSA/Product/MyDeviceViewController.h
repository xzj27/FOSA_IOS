//
//  MyDeviceViewController.h
//  FOSA
//
//  Created by hs on 2019/11/15.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyDeviceViewController : UIViewController

@property (nonatomic,strong) UITableView *deviceTable;
@property (nonatomic,strong) UICollectionView *contentView;

@property (nonatomic,assign) CGFloat mainWidth,mainHeight,navheight;
@end

NS_ASSUME_NONNULL_END
