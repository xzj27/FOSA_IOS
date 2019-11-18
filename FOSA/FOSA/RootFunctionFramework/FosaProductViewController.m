//
//  FosaProductViewController.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FosaProductViewController.h"
#import "AddViewController.h"
#import "ScanOneCodeViewController.h"
#import "PhotoViewController.h"

#import "MyDeviceViewController.h"
#import "OtherViewController.h"
#import "ContentViewController.h"


@interface FosaProductViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>{
    // 记录当前页 当前标题位置
    NSInteger ld_currentIndex;
}
@property (nonatomic,strong) UIPageViewController *pageViewController;
@property (nonatomic,strong) NSMutableArray *pageContentArray;

@property(nonatomic,strong) UILabel *foodLabel;
@property(nonatomic,strong) UILabel *FosaProductLabel;


@end

@implementation FosaProductViewController

#pragma mark - 懒加载
- (NSArray *)pageContentArray {
    if (!_pageContentArray) {
        NSMutableArray *arrayM = [[NSMutableArray alloc] init];
//        for (int i = 1; i < 10; i++) {
//            NSString *contentString = [[NSString alloc] initWithFormat:@"This is the page %d of content displayed using UIPageViewController", i];
//            [arrayM addObject:contentString];
//        }
        [arrayM addObject:@"My Device"];
        [arrayM addObject:@"other"];
        _pageContentArray = [[NSMutableArray alloc] initWithArray:arrayM];
 
    }
    return _pageContentArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_add"] style:UIBarButtonItemStylePlain target:self action:@selector(addEvent)];
    [self addLabel];
    [self InitPageView];
}


-(void)addLabel{
    CGFloat ScreenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat NavHeight = self.navigationController.navigationBar.frame.size.height*2;
    _foodLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, NavHeight, ScreenWidth/2, 60)];
    _foodLabel.backgroundColor = [UIColor orangeColor];
    _foodLabel.text = @"My food";
    _foodLabel.textColor = [UIColor blackColor];
    _foodLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_foodLabel];
    UIButton *foodbtn = [[UIButton alloc]initWithFrame:CGRectMake(0, NavHeight, ScreenWidth/2, 60)];
    [foodbtn setBackgroundColor:[UIColor clearColor]];
    [foodbtn addTarget:self action:@selector(foodBtnclick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:foodbtn];

    _FosaProductLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth/2, NavHeight, ScreenWidth/2, 60)];
    _FosaProductLabel.text = @"My Fosa";
    _FosaProductLabel.textColor = [UIColor blackColor];
    _FosaProductLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:_FosaProductLabel];

    UIButton *FosaProductbtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth/2, NavHeight, ScreenWidth/2, 60)];
    [FosaProductbtn setBackgroundColor:[UIColor clearColor]];
    [FosaProductbtn addTarget:self action:@selector(FosaBtnclick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:FosaProductbtn];
}
-(void)foodBtnclick{
    _FosaProductLabel.backgroundColor = [UIColor whiteColor];
    _foodLabel.backgroundColor = [UIColor orangeColor];
}
-(void)FosaBtnclick{
    _foodLabel.backgroundColor = [UIColor whiteColor];
    _FosaProductLabel.backgroundColor = [UIColor orangeColor];
}

-(void)addEvent{
    
    AddViewController *add = [[AddViewController alloc]init];
    add.hidesBottomBarWhenPushed = YES;
    
    ScanOneCodeViewController *scan = [[ScanOneCodeViewController alloc]init];
    scan.hidesBottomBarWhenPushed = YES;
    
    PhotoViewController *photo = [[PhotoViewController alloc]init];
    photo.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:photo animated:YES];
}
- (void)InitPageView{
    self.mainWidth = [UIScreen mainScreen].bounds.size.width;
    self.mainHeight = [UIScreen mainScreen].bounds.size.height;
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    
   // 设置UIPageViewController的配置项
        NSDictionary *options = @{UIPageViewControllerOptionInterPageSpacingKey : @(20)};
    //    NSDictionary *options = @{UIPageViewControllerOptionSpineLocationKey : @(UIPageViewControllerSpineLocationMin)};
     
        // 根据给定的属性实例化UIPageViewController
        _pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
            navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                   options:options];
        // 设置UIPageViewController代理和数据源
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        
        // 设置UIPageViewController初始化数据, 将数据放在NSArray里面
        // 如果 options 设置了 UIPageViewControllerSpineLocationMid,注意viewControllers至少包含两个数据,且 doubleSided = YES
        
        ContentViewController *initialViewController = [self viewControllerAtIndex:0];// 得到第一页
        NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
        
        [_pageViewController setViewControllers:viewControllers
                                  direction:UIPageViewControllerNavigationDirectionReverse
                                   animated:NO
                                 completion:nil];
     
        // 设置UIPageViewController 尺寸
        _pageViewController.view.frame = CGRectMake(0, self.navHeight*2+60, self.mainWidth, self.mainHeight);
     
        // 在页面上，显示UIPageViewController对象的View
        [self addChildViewController:_pageViewController];
        [self.view addSubview:_pageViewController.view];
}
#pragma mark - UIPageViewControllerDataSource And UIPageViewControllerDelegate
 
#pragma mark 返回上一个ViewController对象
 
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    
    _FosaProductLabel.backgroundColor = [UIColor whiteColor];
    _foodLabel.backgroundColor = [UIColor orangeColor];
    
    NSUInteger index = [self indexOfViewController:(ContentViewController *)viewController];
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    // 返回的ViewController，将被添加到相应的UIPageViewController对象上。
    // UIPageViewController对象会根据UIPageViewControllerDataSource协议方法,自动来维护次序
    // 不用我们去操心每个ViewController的顺序问题
    return [self viewControllerAtIndex:index];
}
#pragma mark 返回下一个ViewController对象

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    
    _foodLabel.backgroundColor = [UIColor whiteColor];
    _FosaProductLabel.backgroundColor = [UIColor orangeColor];
    
    NSUInteger index = [self indexOfViewController:(ContentViewController *)viewController];
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [self.pageContentArray count]) {
        return nil;
    }
    return [self viewControllerAtIndex:index];
}
#pragma mark - 根据index得到对应的UIViewController
 
- (ContentViewController *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.pageContentArray count] == 0) || (index >= [self.pageContentArray count])) {
        return nil;
    }
    // 创建一个新的控制器类，并且分配给相应的数据
    ContentViewController *contentVC = [[ContentViewController alloc] init];
    contentVC.content = [self.pageContentArray objectAtIndex:index];
    return contentVC;
}
 
#pragma mark - 数组元素值，得到下标值
 
- (NSUInteger)indexOfViewController:(ContentViewController *)viewController {
    return [self.pageContentArray indexOfObject:viewController.content];
}

@end
