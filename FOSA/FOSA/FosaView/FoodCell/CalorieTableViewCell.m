//
//  CalorieTableViewCell.m
//  FOSA
//
//  Created by hs on 2019/12/4.
//  Copyright © 2019 hs. All rights reserved.
//

#import "CalorieTableViewCell.h"

@implementation CalorieTableViewCell

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
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    NSLog(@"%f-----%f",width,height);
    if (self) {
        self.foodName = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width/4, height/2)];
        _foodName.text = @"食物";
        _foodName.font = [UIFont systemFontOfSize:12];
        
        self.weight = [[UITextView alloc]initWithFrame:CGRectMake(width/4, 0, width/3, height/2)];
        _weight.backgroundColor = [UIColor whiteColor];
        _weight.layer.borderWidth = 0.5;
        
        self.units = [[UIButton alloc]initWithFrame:CGRectMake(width*7/12, 0, width/6, height/2)];
        [_units setTitle:@"g" forState:UIControlStateNormal];
        
        self.select = [[UIButton alloc]initWithFrame:CGRectMake(0, height/2, width/4, height/2)];
        [_select setTitle:@"Select" forState:UIControlStateNormal];
        self.select.backgroundColor = [UIColor colorWithRed:254/255.0 green:0/255.0 blue:200/255.0 alpha:1.0];
        self.select.layer.cornerRadius = 5;
        
        self.calorie = [[UITextView alloc]initWithFrame:CGRectMake(width/4, 0, width/2, height/2)];
        _calorie.userInteractionEnabled = NO;
        
        self.delete_cell = [[UIButton alloc]initWithFrame:CGRectMake(width*3/4, 0, width/4, height)];
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
@end
