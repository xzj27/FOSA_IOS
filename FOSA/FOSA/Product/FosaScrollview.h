//
//  FosaScrollview.h
//  FOSA
//
//  Created by hs on 2019/11/20.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TabClickBlock)(NSInteger index);
@interface FosaScrollview : UIScrollView

/**
 titles:所有标题数组
 index: 当前选中的下标
 clickBlock:点击回调
 */
-(void)configParameterFrame:(CGRect)frame titles:(NSArray<NSString*> *)titles index:(NSInteger)index block:(TabClickBlock) clickBlock;

/** 点击滚动到指定index */
-(void)tabOffset:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
