//
//  FosaPoundViewController.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FosaPoundViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "SealerTableViewCell.h"
#import "ScanOneCodeViewController.h"

#import "SealerModel.h"
#import "SealerTable.h"
//图片宽高的最大值
#define KCompressibilityFactor 1280.00
@interface FosaPoundViewController ()<UNUserNotificationCenterDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>{
    //数据数组
    NSArray *arrayData;
    //标记当前是否展开
    Boolean isExpand;
}
@property (nonatomic,strong) UIButton *send;
@end

@implementation FosaPoundViewController

#pragma mark - 懒加载
- (UIScrollView *)rootView{
    if (_rootView == nil) {
        _rootView = [[UIScrollView alloc]init];
    }
    return _rootView;
}
- (UIView *)sealerView{
    if (_sealerView == nil) {
        _sealerView = [[UIView alloc]init];
    }
    return _sealerView;
}
- (UIImageView *)sealerImage{
    if (_sealerImage == nil) {
        _sealerImage = [[UIImageView alloc]init];
    }
    return _sealerImage;
}
- (UIButton *)scanBtn{
    if (_scanBtn == nil) {
        _scanBtn = [[UIButton alloc]init];
    }
    return _scanBtn;
}
- (UIView *)poundView{
    if (_poundView == nil) {
        _poundView = [[UIView alloc]init];
    }
    return _poundView;
}
- (UIImageView *)poundImage{
    if (_poundImage == nil) {
        _poundImage = [[UIImageView alloc]init];
    }
    return  _poundImage;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.mainHeight = [UIScreen mainScreen].bounds.size.height;
    self.mainWidth = [UIScreen mainScreen].bounds.size.width;
    self.navheight = self.navigationController.navigationBar.frame.size.height;
    [self InitView];
    [self InitData];
}

- (void)InitView{
    //rootView
    self.rootView.frame = CGRectMake(0, self.navheight, self.mainWidth, self.mainHeight);
    self.rootView.bounces = NO;
    self.rootView.showsVerticalScrollIndicator = NO;
    self.rootView.showsHorizontalScrollIndicator = NO;
    self.rootView.contentSize = CGSizeMake(self.mainWidth,self.mainHeight*2);
    [self.view addSubview:self.rootView];
    
    //SealerView
    self.sealerView.frame = CGRectMake(5,10,self.mainWidth-10,self.mainHeight/3);
    self.sealerView.backgroundColor = [UIColor colorWithRed:0/255.0 green:191/255.0 blue:227/255.0 alpha:1.0];
    [self.rootView addSubview:self.sealerView];
    //SealerView content
    self.sealerImage.frame = CGRectMake(5, 5, self.sealerView.frame.size.height/2, self.sealerView.frame.size.height/2);
    self.sealerImage.image = [UIImage imageNamed:@"fosa.jpg"];
    [self.sealerView addSubview:self.sealerImage];
    
    self.scanBtn.frame = CGRectMake(self.sealerView.frame.size.width-45, 5, 40, 40);
    [self.scanBtn setImage:[UIImage imageNamed:@"icon_scan"]  forState:UIControlStateNormal];
    [self.sealerView addSubview:self.scanBtn];
    
    //列表
    self.InfoMenu = [[UIView alloc]initWithFrame:CGRectMake(0, self.sealerView.frame.size.height*5/6, self.sealerView.frame.size.width,self.sealerView.frame.size.height/6)];
    _InfoMenu.backgroundColor = [UIColor colorWithRed:80/255.0 green:200/255.0 blue:240/255.0 alpha:1.0];
    self.indicator = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.InfoMenu.frame.size.height, self.InfoMenu.frame.size.height)];
    _indicator.image = [UIImage imageNamed:@"caret"];
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ExpandList:)];
    self.indicator.userInteractionEnabled = YES;
    [self.indicator addGestureRecognizer:recognizer];
    [self.InfoMenu addSubview:_indicator];
    [self.sealerView addSubview:self.InfoMenu];
   // [self setupView];
    [self InitFoodTable];
    
    //分割线
//    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, self.mainHeight/2, self.mainWidth, 2)];
//    line.backgroundColor = [UIColor grayColor];
//    [self.rootView addSubview:line];
    
    self.poundView.frame = CGRectMake(5, self.mainHeight/3+30, self.mainWidth-10, self.mainHeight/3);
    self.poundView.backgroundColor = [UIColor colorWithRed:254/255.0 green:0/255.0 blue:151/255.0 alpha:1.0];
    [self.rootView addSubview:self.poundView];
    self.poundImage.frame = CGRectMake(5, 5, self.poundView.frame.size.height/2, self.poundView.frame.size.height/2);
    self.poundImage.image = [UIImage imageNamed:@"img_pound.jpg"];
    [self.poundView addSubview:self.poundImage];
    //连接开关
    self.connect = [[UIButton alloc]initWithFrame:CGRectMake(self.poundView.frame.size.width-45, 5, 40, 40)];
    [self.connect setImage:[UIImage imageNamed:@"icon_disconnect"] forState:UIControlStateNormal];
    [self.poundView addSubview:self.connect];
    //重量与卡路里
    self.weightView = [[UIView alloc]initWithFrame:CGRectMake(5, self.poundView.frame.size.height/2+10, self.poundView.frame.size.width*3/4, (self.poundView.frame.size.height-40)/4)];
    self.weight = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.weightView.frame.size.width*2/3, self.weightView.frame.size.height)];
    self.weight.textAlignment = NSTextAlignmentCenter;
    self.weight.backgroundColor = [UIColor clearColor];
    self.weight.layer.borderWidth = 1;
    self.weight.text = @"weight";
    self.weight.userInteractionEnabled = NO;
    self.units = [[UILabel alloc]initWithFrame:CGRectMake(self.weightView.frame.size.width*2/3, 0, self.weightView.frame.size.width/3, self.weightView.frame.size.height)];
    _units.text = @"g";
    [self.poundView addSubview:self.weightView];
    [self.weightView addSubview:self.weight];
    [self.weightView addSubview:self.units];
    
    self.calorieView = [[UIView alloc]initWithFrame:CGRectMake(5, self.poundView.frame.size.height*3/4+5, self.poundView.frame.size.width*3/4, (self.poundView.frame.size.height-40)/4)];
    self.calorie = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, self.calorieView.frame.size.width*2/3, self.calorieView.frame.size.height)];
    self.calorie.textAlignment = NSTextAlignmentCenter;
    self.calorie.backgroundColor = [UIColor clearColor];
    self.calorie.layer.borderWidth = 1;
    self.calorie.text = @"calorie";
    self.calorie.userInteractionEnabled = NO;
    self.select = [[UIButton alloc]initWithFrame:CGRectMake(self.calorieView.frame.size.width*2/3, 0, self.calorieView.frame.size.width/3, self.calorieView.frame.size.height)];
    self.select.layer.cornerRadius = 5;
    [self.select setTitle:@"select" forState:UIControlStateNormal];
    self.select.backgroundColor = [UIColor colorWithRed:254/255.0 green:0/255.0 blue:200/255.0 alpha:1.0];
    [self.calorieView addSubview:self.select];
    [self.poundView addSubview:self.calorieView];
    [self.calorieView addSubview:self.calorie];
}
#pragma mark - 食物列表
- (void)ExpandList:(UITapGestureRecognizer *)sender{
    if (!isExpand) {
        self.indicator.image = [UIImage imageNamed:@"caret_open"];
        self.foodTable.hidden = NO;
        CGPoint center = CGPointZero;
        center.x = self.mainWidth/2;
        center.y = self.sealerView.frame.size.height+arrayData.count*40+self.poundView.frame.size.height/2+45;
        self.poundView.center = center;
        isExpand = true;
    }else{
        self.indicator.image = [UIImage imageNamed:@"caret"];
        CGPoint center = CGPointZero;
        center.x = self.mainWidth/2;
        center.y = self.mainHeight/2+30;
        self.poundView.center = center;
        self.foodTable.hidden = YES;
        isExpand = false;
    }
}
- (void)InitData{
    arrayData = @[@"猪肉",@"牛肉",@"三文鱼",@"鲍鱼"];
}

//food table
- (void)InitFoodTable{
    self.foodTable = [[UITableView alloc]initWithFrame:CGRectMake(5, self.sealerView.frame.size.height+10, self.sealerView.frame.size.width,self.sealerView.frame.size.height) style:UITableViewStylePlain];
    _foodTable.delegate = self;
    _foodTable.dataSource = self;
    _foodTable.hidden = YES;
    _foodTable.showsVerticalScrollIndicator = NO;
    
    [_foodTable setSeparatorColor:[UIColor grayColor]];

    [self.rootView insertSubview:_foodTable atIndex:10];
}
//行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}
//每组多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayData.count;
}
//多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    //初始化cell，并指定其类型
    UITableViewCell *cell = (SealerTableViewCell*)[tableView  dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        //创建cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    //取消点击cell时显示的背景色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.text = arrayData[indexPath.row];
    //返回cell
    return cell;
}

@end
