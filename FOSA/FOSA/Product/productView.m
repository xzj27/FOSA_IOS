//
//  productView.m
//  FOSA
//
//  Created by hs on 2019/11/20.
//  Copyright © 2019 hs. All rights reserved.
//

#import "productView.h"

@interface productView()<UIPageViewControllerDelegate,
UIPageViewControllerDataSource>

@property (nonatomic, strong) UIPageViewController *pageController;
/** 内容页数组 */
@property (nonatomic, strong) NSArray<UIViewController*> *controllers;
/** 记录上一次的下标 */
@property (nonatomic, assign) NSInteger oriIndex;

@end
@implementation productView

- (instancetype)initWithFrame:(CGRect)frame {
    self =[super initWithFrame:frame];
    if(self){
        [self initView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.pageController.view.frame = self.bounds;
}

-(void)initView{
    // 配置UIPageViewController的基本信息
    self.pageController=[[UIPageViewController alloc]initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    self.pageController.delegate = self;
    self.pageController.dataSource = self;
    self.pageController.view.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.pageController.view];
}

-(void)configParam:(NSMutableArray<UIViewController *> *)controllers index:(NSInteger)index block:(TabSwitchBlcok)tabSwitch{
    if (controllers.count == 0) { return; }
    self.tabSwitch = tabSwitch;
    self.controllers = controllers;
    self.tabSwitch = tabSwitch;
    self.oriIndex = index;
    
    //默认展示的第index页面
    [self.pageController setViewControllers:[NSArray arrayWithObject:[self pageControllerAtIndex:index]] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

/**
 更新滚动到index页面
 */
-(void)updateTab:(NSInteger)index{
    // 处理左右滚动方向
    UIPageViewControllerNavigationDirection direction = index > self.oriIndex ? UIPageViewControllerNavigationDirectionForward : UIPageViewControllerNavigationDirectionReverse;
    [self.pageController setViewControllers:[NSArray arrayWithObject:[self pageControllerAtIndex:index]] direction:direction animated:YES completion:nil];
    self.oriIndex = index;
}

/** 返回下一个页面 */
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController{
    NSInteger index = [self.controllers indexOfObject:viewController];
    if(index == (self.controllers.count-1)){
        return nil;
    }
    index++;
    return [self pageControllerAtIndex:index];
}
/** 返回前一个页面 */
-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController{
    NSInteger index = [self.controllers indexOfObject:viewController];
    if(index==0){
        return nil;
    }
    index--;
    return [self pageControllerAtIndex:index];
    
}
/** 创建内容页面 */
-(UIViewController*)pageControllerAtIndex:(NSInteger)index {
    if (index > self.controllers.count-1) {
        index = self.controllers.count - 1;
    }
    return [self.controllers objectAtIndex:index];
    
}
/** 结束滑动的时候触发 */
-(void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed{
    NSInteger index = [self.controllers indexOfObject:pageViewController.viewControllers[0]];
    self.tabSwitch(index);
}
/** 开始滑动的时候触发 */
-(void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers{
    
}

@end
