//
//  ProductViewController.h
//  FOSAapp1.0
//
//  Created by hs on 2019/12/30.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ProductViewController : UIViewController
@property (nonatomic,strong) UIView *header,*productCategoryView,*productView,*titleView;
@property (nonatomic,strong) UIButton *fosa,*myFosa;
@property (nonatomic,strong) UISearchBar *searchBar;
@property (nonatomic,strong) UITableView *productCategory;
@property (nonatomic,strong) UIScrollView *mainScrollView;
@property (nonatomic,strong) UICollectionView *fosaProductCollection,*myProductCollection;

@end

NS_ASSUME_NONNULL_END
