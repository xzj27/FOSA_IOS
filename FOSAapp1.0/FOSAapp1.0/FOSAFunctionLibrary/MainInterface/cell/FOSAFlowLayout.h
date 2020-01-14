//
//  FOSAFlowLayout.h
//  FOSAapp1.0
//
//  Created by hs on 2019/12/31.
//  Copyright © 2019 hs. All rights reserved.
//
#import <UIKit/UIKit.h>

@protocol FOSAFlowLayoutDelegate;

@class FOSAFlowLayout;
@interface FOSAFlowLayout : UICollectionViewLayout
@property (assign,nonatomic)CGFloat columnMargin;//每一列item之间的间距
@property (assign,nonatomic)CGFloat rowMargin;   //每一行item之间的间距
@property (assign,nonatomic)UIEdgeInsets sectionInset;//设置于collectionView边缘的间距
@property (assign,nonatomic)NSInteger columnCount;//设置每一行排列的个数


@property (weak,nonatomic)id<FOSAFlowLayoutDelegate> delegate; //设置代理
@end


@protocol FOSAFlowLayoutDelegate
-(CGFloat)waterFlowLayout:(FOSAFlowLayout *) WaterFlowLayout heightForWidth:(CGFloat)width andIndexPath:(NSIndexPath *)indexPath;
@end
