//
//  CalorieTableViewCell.m
//  FOSA
//
//  Created by hs on 2019/12/4.
//  Copyright © 2019 hs. All rights reserved.
//

#import "CalorieTableViewCell.h"
#import "CalorieModel.h"

@interface CalorieTableViewCell()<UITextFieldDelegate>
@property (nonatomic,assign) CGFloat cellHeight,cellWidth;
@end
@implementation CalorieTableViewCell

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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    CGFloat width = screen_width-10;
    CGFloat Vheight = 110;
    //NSLog(@"%f,%f",width,height);
    if (self) {
        self.backView = [[UIView alloc]initWithFrame:CGRectMake(0, 5, width, Vheight-5)];
        //self.backgroundView.layer.cornerRadius = 10;
        self.backView.backgroundColor = [UIColor colorWithRed:254/255.0 green:100/255.0 blue:151/255.0 alpha:1.0];
        [self addSubview:self.backView];
        CGFloat height = self.backView.frame.size.height;
        self.foodName = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, width/4-5, height/2-10)];
        _foodName.text = @"食物";
        _foodName.textAlignment = NSTextAlignmentCenter;
        _foodName.font = [UIFont systemFontOfSize:14];
        
        self.weight = [[UITextField alloc]initWithFrame:CGRectMake(width/4+10, 5, width/2-50, height/2-10)];
        self.weight.backgroundColor = [UIColor colorWithRed:254/255.0 green:150/255.0 blue:151/255.0 alpha:1.0];
        self.weight.layer.borderWidth = 0.5;
        self.weight.returnKeyType = UIReturnKeyDone;
        self.weight.keyboardType = UIKeyboardTypeDecimalPad;
        
        self.units = [[UIButton alloc]initWithFrame:CGRectMake(width*3/4-40, 5, 50, height/2-10)];
        _units.backgroundColor = [UIColor colorWithRed:254/255.0 green:150/255.0 blue:151/255.0 alpha:1.0];
        _units.layer.cornerRadius = 5;
        [_units setTitle:@"g" forState:UIControlStateNormal];
        
        self.select = [[UIButton alloc]initWithFrame:CGRectMake(5, height/2+5, width/4-10, height/2-10)];
        [_select setTitle:@"Select" forState:UIControlStateNormal];
        self.select.backgroundColor = [UIColor colorWithRed:254/255.0 green:0/255.0 blue:200/255.0 alpha:1.0];
        self.select.layer.cornerRadius = 5;
        
        self.calorie = [[UITextView alloc]initWithFrame:CGRectMake(width/4+10, height/2+5, width/2, height/2-10)];
        self.calorie.backgroundColor = [UIColor colorWithRed:254/255.0 green:150/255.0 blue:151/255.0 alpha:1.0];
        _calorie.userInteractionEnabled = NO;
        self.delete_cell = [[UIButton alloc]initWithFrame:CGRectMake(width-50, 25, 50, 50)];
        [_delete_cell setImage:[UIImage imageNamed:@"icon_deleteHL"] forState:UIControlStateNormal];
        [self.backView addSubview:_foodName];
        [self.backView addSubview:self.weight];
        [self.backView addSubview:_units];
        [self.backView addSubview:_select];
        [self.backView addSubview:_calorie];
        [self.backView addSubview:_delete_cell];
    }
    return self;
}

//- (void)setFrame:(CGRect)frame{
//
//    NSLog(@"%f^^^^^^^^^^^%f",frame.size.width,frame.size.height);
//    self.cellHeight = frame.size.height;
//    self.cellWidth = frame.size.width;
//    [super setFrame:frame];
//}
@end
