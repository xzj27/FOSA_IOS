//
//  CategoryViewController.h
//  FOSA
//
//  Created by hs on 2019/12/2.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CategoryViewController : UIViewController

@property (nonatomic,strong) UICollectionView *CategoryView;

@property (nonatomic,assign) NSInteger current;//当前的cell
@end

NS_ASSUME_NONNULL_END
