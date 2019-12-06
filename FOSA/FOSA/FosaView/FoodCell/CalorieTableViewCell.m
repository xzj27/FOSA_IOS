//
//  CalorieTableViewCell.m
//  FOSA
//
//  Created by hs on 2019/12/4.
//  Copyright © 2019 hs. All rights reserved.
//

#import "CalorieTableViewCell.h"

@interface CalorieTableViewCell()
@property (nonatomic,assign) CGFloat cellHeight,cellWidth;
@end
@implementation CalorieTableViewCell
/** 屏幕宽度 */
#define screen_width [UIScreen mainScreen].bounds.size.width

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
    CGFloat height = 100;
    NSLog(@"%f,%f",width,height);
    if (self) {
        self.foodName = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, width/4-5, height/2-10)];
        _foodName.text = @"食物";
        _foodName.textAlignment = NSTextAlignmentCenter;
        _foodName.font = [UIFont systemFontOfSize:14];
        
        self.weight = [[UITextField alloc]initWithFrame:CGRectMake(width/4+10, 5, width/2-50, height/2-10)];
        _weight.backgroundColor = [UIColor colorWithRed:254/255.0 green:150/255.0 blue:151/255.0 alpha:1.0];
        _weight.layer.borderWidth = 0.5;
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
        
        [self addSubview:_foodName];
        [self addSubview:_weight];
        [self addSubview:_units];
        [self addSubview:_select];
        [self addSubview:_calorie];
        [self addSubview:_delete_cell];
        
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
