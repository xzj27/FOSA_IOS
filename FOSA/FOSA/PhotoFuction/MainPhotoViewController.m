//
//  MainPhotoViewController.m
//  FOSA
//
//  Created by hs on 2019/12/27.
//  Copyright © 2019 hs. All rights reserved.
//

#import "MainPhotoViewController.h"
#import "ScanOneCodeViewController.h"
#import "PhotoViewController.h"
#import "PhotoViewController1.h"
#import "PhotoViewController2.h""
#import "productView.h"

@interface MainPhotoViewController ()
@property (nonatomic,strong) productView *productContent;
@property (nonatomic, strong) NSMutableArray *controllersArr;/// 控制器数组
@property (nonatomic,strong) NSMutableArray<UIImage *> *imageArray;
@end

@implementation MainPhotoViewController
/** 屏幕高度 */
#define screen_height [UIScreen mainScreen].bounds.size.height
/** 屏幕宽度 */
#define screen_width [UIScreen mainScreen].bounds.size.width
//判断是否是iPad
#define ISIPAD [[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPad
//判断手机型号为X
#define is_IPHONEX [[UIScreen mainScreen] bounds].size.width == 375.0f &&([[UIScreen mainScreen] bounds].size.height == 812.0f)
//获取状态栏的高度 iPhone X - 44pt 其他20pt
#define StatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
//获取导航栏的高度 - （不包含状态栏高度） 44pt
#define NavigationBarHeight self.navigationController.navigationBar.frame.size.height
//屏幕底部 tabBar高度49pt + 安全视图高度34pt(iPhone X)
#define TabbarHeight self.tabBarController.tabBar.frame.size.height
//屏幕顶部 导航栏高度（包含状态栏高度）
#define NavigationHeight (StatusBarHeight + NavigationBarHeight)
//屏幕底部安全视图高度 - 适配iPhone X底部
#define TOOLH (is_IPHONEX ? 34 : 0)
//屏幕底部 toolbar高度 + 安全视图高度34pt
#define ToolbarHeight self.navigationController.toolbar.frame.size.height
- (void)viewWillLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.productContent.frame = CGRectMake(0, 0, screen_width, screen_height - 40);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self InitArray];
    [self CreatNavigationBar];
    [self PageControlInit];
    [self InitContentView];
}
- (void)InitArray{
    UIImage *image = [UIImage imageNamed:@"icon_logoHL"];
    UIImage *image1 = [UIImage imageNamed:@"icon_logoHL"];
    UIImage *image2 = [UIImage imageNamed:@"icon_logoHL"];
    _imageArray = [[NSMutableArray alloc]init];
    [_imageArray addObject:image];
    [_imageArray addObject:image1];
    [_imageArray addObject:image2];
    
}
- (void)CreatNavigationBar{
    self.navigationItem.title = @"Photo";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_scan"] style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem.target = self;     self.navigationItem.rightBarButtonItem.action = @selector(ScanEvent);
}
- (void)InitContentView
{
    self.productContent = [[productView alloc] init];
    [self.view addSubview:self.productContent];
    NSMutableArray *contentM = [NSMutableArray array];
    PhotoViewController *photo0 = [[PhotoViewController alloc]init];
    photo0.imageArray = self.imageArray;
    [contentM addObject:photo0];
    PhotoViewController1 *photo1 = [[PhotoViewController1 alloc]init];
    photo1.imageArray1 = self.imageArray;
    [contentM addObject:photo1];
    PhotoViewController2 *photo2 = [[PhotoViewController2 alloc]init];
    photo2.imageArray2 = self.imageArray;
    [contentM addObject:photo2];
    
    [self.productContent configParam:contentM index:0 block:^(NSInteger index) {
        self.pageControl.currentPage = index;
    }];
}
- (void)PageControlInit{
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(screen_width/3, screen_height-30, screen_width/3, 20)];
    _pageControl.numberOfPages = 3;
    _pageControl.pageIndicatorTintColor = [UIColor redColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
    [self.view insertSubview:_pageControl atIndex:10];
}
#pragma mark - 进入扫码界面
-(void)ScanEvent{
    NSLog(@"***************%@",_imageArray);
    ScanOneCodeViewController *scan = [[ScanOneCodeViewController alloc]init];
    scan.food_photo = [[NSMutableArray alloc]init];
    scan.food_photo = self.imageArray;
    scan.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scan animated:YES];
    [self.navigationController popoverPresentationController];
    
}
@end
