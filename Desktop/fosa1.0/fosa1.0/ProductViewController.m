//
//  ProductViewController.m
//  fosa1.0
//
//  Created by hs on 2019/10/16.
//  Copyright © 2019 hs. All rights reserved.
//

#import "ProductViewController.h"
#import "AddViewController.h"
#import "ScanViewController.h"
#import "PhotoViewController.h"
@interface ProductViewController ()

//@property(nonatomic,strong) UIScrollView *headerView;
//@property(nonatomic,strong) NSArray<NSString *> *titleArray;

@property(nonatomic,strong) UILabel *foodLabel;
@property(nonatomic,strong) UILabel *FosaProductLabel;

@end

@implementation ProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:nil action:nil];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_add"] style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem.target = self;
    self.navigationItem.rightBarButtonItem.action = @selector(addEvent);
    
    //_titleArray = @[@"My food",@"My Device"];
    //[self addScrollerHeader:_titleArray];
    [self addLabel];
}
-(void)addLabel{
    CGFloat ScreenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat NavHeight = self.navigationController.navigationBar.frame.size.height;
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
    
    ScanViewController *scan = [[ScanViewController alloc]init];
    scan.hidesBottomBarWhenPushed = YES;
    
    PhotoViewController *photo = [[PhotoViewController alloc]init];
    photo.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:photo animated:YES];
}

//-(void)addScrollerHeader:(NSArray *)array{
//
//    CGFloat ScreenWidth = [UIScreen mainScreen].bounds.size.width/2;
//    CGFloat NavHeight = self.navigationController.navigationBar.frame.size.height;
//
//    self.headerView = [[UIScrollView alloc]init];
//    self.headerView.frame = CGRectMake(0, self.navigationController.navigationBar.frame.size.height, [UIScreen mainScreen].bounds.size.width, 60);
//    //self.headerView.backgroundColor = [UIColor colorWithRed:200/255 green:200/255 blue:200/255 alpha:1.0];
//    self.headerView.backgroundColor = [UIColor blueColor];
//    self.headerView.contentSize = CGSizeMake(ScreenWidth*array.count,60);
//    [self.view addSubview:self.headerView];
//
//    for(NSInteger index = 0;index<array.count;index++){
//        NSLog(@"%@",array[index]);
//        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(ScreenWidth*index, NavHeight, ScreenWidth, 60)];
//        titleLabel.text = array[index];
//        titleLabel.textColor = [UIColor blackColor];
//        titleLabel.textAlignment = NSTextAlignmentCenter;
//        titleLabel.adjustsFontSizeToFitWidth = YES;
//        [self.headerView addSubview:titleLabel];
//
//        UIButton *segmentbtn = [[UIButton alloc]initWithFrame:CGRectMake(ScreenWidth*index, NavHeight, ScreenWidth, 60)];
//        segmentbtn.tag = index;
//        [segmentbtn setBackgroundColor:[UIColor clearColor]];
//        [segmentbtn addTarget:self action:@selector(btnclick:) forControlEvents:UIControlEventTouchUpInside];
//        [self.headerView addSubview:segmentbtn];
//    }
//
//    UIView *headerSelectedSuperView = [UIView alloc]initWithFrame:CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
//
//
//
//
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
