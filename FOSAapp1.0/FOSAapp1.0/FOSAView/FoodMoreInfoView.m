//
//  FoodMoreInfoView.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FoodMoreInfoView.h"
#import "FoodModel.h"
@interface FoodMoreInfoView()<UITextFieldDelegate>

@end

@implementation FoodMoreInfoView

/*
 添加子控件
 */
-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        //initialize
        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *closebutton = [[UIButton alloc]init];
        self.close = closebutton;
        [self.close setBackgroundImage:[UIImage imageNamed:@"icon_closeAlert"] forState:UIControlStateNormal];
        [self addSubview:self.close];
     
        UIImageView *iconImageView = [[UIImageView alloc]init];
        self.iconImageView = iconImageView;
        self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.iconImageView.clipsToBounds = YES;
        [self addSubview:iconImageView];
        
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:10*(screen_width/414)];
        nameLabel.layer.cornerRadius = 10;
        nameLabel.textColor = [UIColor blackColor];
        self.nameLabel = nameLabel;
        [self addSubview:self.nameLabel];
        
        UITextField *food = [[UITextField alloc]init];
        food.textAlignment = NSTextAlignmentCenter;
        food.font = [UIFont systemFontOfSize:10*(screen_width/414)];
        
        //forbidding editting
        food.userInteractionEnabled = NO;
        food.enabled = NO;
        food.returnKeyType = UIReturnKeyDone;
        self.foodName = food;
        [self addSubview:self.foodName];
        food.layer.cornerRadius = 10;
        UITextField *expire = [[UITextField alloc]init];
        expire.textAlignment = NSTextAlignmentCenter;
        expire.font = [UIFont systemFontOfSize:10*(screen_width/414)];
        expire.userInteractionEnabled = NO;
        expire.layer.cornerRadius = 10;
        expire.enabled = NO;
        expire.returnKeyType = UIReturnKeyDone;
        self.expireDate = expire;
        [self addSubview:self.expireDate];
        
        UITextField *remind = [[UITextField alloc]init];
        remind.textAlignment = NSTextAlignmentCenter;
        remind.font = [UIFont systemFontOfSize:10*(screen_width/414)];
        remind.userInteractionEnabled = NO;
        remind.layer.cornerRadius = 10;
        remind.enabled = NO;
        remind.returnKeyType = UIReturnKeyDone;
        self.remindDate = remind;
        [self addSubview:self.remindDate];
    }
    return self;
}

/*
 设置子控件的frame
 */
-(void)layoutSubviews{
    [super layoutSubviews];
    //food photo
    int width = self.bounds.size.width;
    int height = self.bounds.size.height;
    self.iconImageView.frame = CGRectMake(5,height/3,height*2/3-5,height*2/3-5);
    self.iconImageView.layer.cornerRadius = self.iconImageView.frame.size.width/2;
    //close alert
    self.close.frame = CGRectMake(width-height/4,0, height/4, height/4);
    //device name
    self.nameLabel.frame = CGRectMake(0, height/6, width, height/6);
    //food name
    self.foodName.frame = CGRectMake( height*2/3-8, height/3, width-height*2/3,height/6);
    //expire date
    self.expireDate.frame = CGRectMake(height*2/3,height*5/9,width-height*2/3,height/6);
    //remind date
    self.remindDate.frame = CGRectMake(height*2/3-8,height*7/9,width-height*2/3,height/6);
    //edit button
}

/*
 取出模型属性
 */
-(void)setModel:(FoodModel *)model
{
    _model = model;
    self.iconImageView.image = [self getImage:model.foodName];
    self.nameLabel.text  = model.device;
    self.foodName.text   = model.foodName;
    self.expireDate.text = [NSString stringWithFormat:@"有效日期：%@",model.expireDate];
    self.remindDate.text = [NSString stringWithFormat:@"提醒日期：%@",model.remindDate];
}
//取出保存在本地的图片
-(UIImage*)getImage:(NSString *)filepath{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photopath = [NSString stringWithFormat:@"%@%d.png",filepath,1];
    NSString *imagePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",photopath]];
    // 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    //NSLog(@"=== %@", img);
    return img;
}
//退出键盘
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.foodName resignFirstResponder];
    [self.expireDate resignFirstResponder];
    return YES;
}
//-(void)SetEditedState{
//    if (self.isEditOK) {
//        self.isEditOK = NO;
//        self.expireDate.userInteractionEnabled = YES;
//        self.expireDate.enabled = YES;
//        self.remindDate.userInteractionEnabled = YES;
//        self.remindDate.enabled = YES;
//    }else{
//        self.isEditOK = YES;
//    }
//}
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
//    if (self.isEditOK) {
//        return YES;
//    }else{
//        return NO;
//    }
//}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

