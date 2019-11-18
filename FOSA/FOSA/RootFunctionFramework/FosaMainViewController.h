//
//  FosaMainViewController.h
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FosaMainViewController : ViewController
@property (nonatomic,strong) UIScrollView *CategoryScrollview;
@property (nonatomic,strong) UICollectionView *StorageItemView;
@property (nonatomic,strong) UIButton *QRscan,*Remindbtn;
@property (nonatomic,assign) CGFloat mainWidth,mainHeight,navHeight;
@end

NS_ASSUME_NONNULL_END
