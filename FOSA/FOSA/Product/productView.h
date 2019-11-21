//
//  productView.h
//  FOSA
//
//  Created by hs on 2019/11/20.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TabSwitchBlcok)(NSInteger index);
@interface productView : UIView

@property (nonatomic,strong)TabSwitchBlcok tabSwitch;

-(void)configParam:(NSMutableArray<UIViewController*>*)controllers index:(NSInteger)index block:(TabSwitchBlcok)tabSwitch;
/**
 更新滚动到index页面
 */
-(void)updateTab:(NSInteger)index;
@end

NS_ASSUME_NONNULL_END
