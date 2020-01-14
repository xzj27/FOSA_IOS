//
//  MainPhotoViewController.m
//  FOSA
//
//  Created by hs on 2019/12/27.
//  Copyright © 2019 hs. All rights reserved.
//

#import "MainPhotoViewController.h"
#import "QRCodeScanViewController.h"
#import "PhotoViewController.h"
#import "PhotoViewController1.h"
#import "PhotoViewController2.h"
#import "productView.h"
#import "FoodViewController.h"

@interface MainPhotoViewController ()
@property (nonatomic,strong) productView *productContent;
@property (nonatomic, strong) NSMutableArray *controllersArr;/// 控制器数组
@property (nonatomic,strong) NSMutableArray<UIImage *> *imageArray;
@property (nonatomic,weak) PhotoViewController *mphoto0;
@property (nonatomic,weak) PhotoViewController1 *mphoto1;
@property (nonatomic,weak) PhotoViewController2 *mphoto2;
@end

@implementation MainPhotoViewController
- (void)viewWillLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.productContent.frame = CGRectMake(0, 0, screen_width, screen_height-30);
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
    _mphoto0 = photo0;
    _mphoto0.imageArray = self.imageArray;
    [contentM addObject:_mphoto0];
    
    PhotoViewController1 *photo1 = [[PhotoViewController1 alloc]init];
    _mphoto1 = photo1;
    _mphoto1.imageArray1 = self.imageArray;
    [contentM addObject:_mphoto1];
    
    PhotoViewController2 *photo2 = [[PhotoViewController2 alloc]init];
    _mphoto2 = photo2;
    _mphoto2.imageArray2 = self.imageArray;
    [contentM addObject:_mphoto2];
    
    [self.productContent configParam:contentM index:0 block:^(NSInteger index) {
        self.pageControl.currentPage = index;
    }];
}
- (void)PageControlInit{
    
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(screen_width/3, screen_height-30, screen_width/3, 30)];
    _pageControl.numberOfPages = 3;
    _pageControl.pageIndicatorTintColor = [UIColor redColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
    [self.view addSubview:self.pageControl];
    //[self.navigationController.navigationBar bringSubviewToFront:_pageControl];
    //self.navigationController.navigationBart
}
- (void)stopRunning{
    [_mphoto0.captureSession stopRunning];
    [_mphoto1.captureSession stopRunning];
    [_mphoto2.captureSession stopRunning];
}
#pragma mark - 进入扫码界面
-(void)ScanEvent{
//    NSLog(@"***************%@",_imageArray);
//    FoodViewController *food = [[FoodViewController alloc]init];
//    food.food_image = self.imageArray;
//    food.hidesBottomBarWhenPushed = YES;
    
    QRCodeScanViewController *scan = [[QRCodeScanViewController alloc]init];
    scan.food_photo = [[NSMutableArray alloc]init];
    scan.food_photo = self.imageArray;
    [self stopRunning];
    scan.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:scan animated:YES];
    [self.navigationController popoverPresentationController];
    
}

/**隐藏底部横条，点击屏幕可显示*/
- (BOOL)prefersHomeIndicatorAutoHidden{
    return YES;
}
@end
