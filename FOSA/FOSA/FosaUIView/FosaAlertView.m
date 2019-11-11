//
//  FosaAlertView.m
//  fosa1.0
//
//  Created by hs on 2019/10/16.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FosaAlertView.h"
#import "AlertModel.h"
@interface FosaAlertView()<UITextFieldDelegate>
/*
 添加子控件属性
 */
@property (nonatomic,weak) UIImageView *iconImageView;
@property (nonatomic,weak) UILabel *nameLabel,*foodLabel,*expireLabel,*remindLabel;
@property (nonatomic,weak) UITextField *foodName,*expireDate,*remindDate;

@property (nonatomic,assign) BOOL isEditOK;

@end

@implementation FosaAlertView

/*
 添加子控件
 */
-(instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        //initialize
        self.isEditOK = false;
        self.backgroundColor = [UIColor whiteColor];
        UIImageView *iconImageView = [[UIImageView alloc]init];
        self.iconImageView = iconImageView;
            self.iconImageView.transform = CGAffineTransformMakeRotation(M_PI_2);//顺时针旋转90度
        [self addSubview:iconImageView];
        
        UILabel *nameLabel = [[UILabel alloc]init];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        nameLabel.font = [UIFont systemFontOfSize:20];
        //nameLabel.backgroundColor = [UIColor colorWithRed:200/255 green:200/255 blue:200/255 alpha:1.0];
        nameLabel.textColor = [UIColor blackColor];
        self.nameLabel = nameLabel;
        [self addSubview:self.nameLabel];
        
        
        UITextField *food = [[UITextField alloc]init];
        food.textAlignment = NSTextAlignmentCenter;
        food.font = [UIFont systemFontOfSize:10];
        //food.backgroundColor = [UIColor colorWithRed:200/255 green:200/255 blue:200/255 alpha:1.0];
        food.layer.borderWidth = 1;
        
        //forbidding editting
        food.userInteractionEnabled = NO;
        food.enabled = NO;
        
        food.returnKeyType = UIReturnKeyDone;
        self.foodName = food;
        [self addSubview:self.foodName];
        
        UITextField *expire = [[UITextField alloc]init];
        expire.textAlignment = NSTextAlignmentCenter;
        expire.font = [UIFont systemFontOfSize:10];
        //expire.backgroundColor = [UIColor colorWithRed:200/255 green:200/255 blue:200/255 alpha:1.0];
        
        expire.userInteractionEnabled = NO;
        expire.enabled = NO;
        
        expire.returnKeyType = UIReturnKeyDone;
        expire.layer.borderWidth = 1;
        self.expireDate = expire;
        [self addSubview:self.expireDate];
        
        UITextField *remind = [[UITextField alloc]init];
        remind.textAlignment = NSTextAlignmentCenter;
        remind.font = [UIFont systemFontOfSize:10];
        //remind.backgroundColor = [UIColor colorWithRed:200/255 green:200/255 blue:200/255 alpha:1.0];
        
        remind.userInteractionEnabled = NO;
        remind.enabled = NO;
        
        remind.returnKeyType = UIReturnKeyDone;
        remind.layer.borderWidth = 1;
        self.remindDate = remind;
        [self addSubview:self.remindDate];
        
        UIButton *edit = [[UIButton alloc]init];
        edit.backgroundColor = [UIColor greenColor];
        [edit setTitle:@"关闭" forState:UIControlStateNormal];
        self.edited = edit;
//        [self.edited addTarget:self action:@selector(SetEditedState) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.edited];

    }
    return self;
}

/*
 设置子控件的frame
 */
-(void)layoutSubviews{
    [super layoutSubviews];
    
    //food photo
    CGFloat iconImageViewX = 10;
    CGFloat iconImageViewY = 40;
    CGFloat iconImageViewW = self.bounds.size.width/3;
    CGFloat iconImageViewH = 120;
    self.iconImageView.frame = CGRectMake(iconImageViewX, iconImageViewY, iconImageViewW, iconImageViewH);
    //device name
    CGFloat nameLabelX = 0;
    CGFloat nameLabelY = 0;
    CGFloat nameLabelW = self.bounds.size.width;
    CGFloat nameLabelH = 40;
    self.nameLabel.frame = CGRectMake(nameLabelX, nameLabelY, nameLabelW, nameLabelH);
    
    //food name
    self.foodName.frame = CGRectMake(iconImageViewW+20,40,iconImageViewW*2-40,30);
    //expire date
    self.expireDate.frame = CGRectMake(iconImageViewW+20,80,iconImageViewW*2-40,30);
    //remind date
    self.remindDate.frame = CGRectMake(iconImageViewW+20,120,iconImageViewW*2-40,30);
    //edit button
    self.edited.frame = CGRectMake(0, self.bounds.size.height-60,self.bounds.size.width, 60);
}

//
//- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
//     [super touchesMoved:touches withEvent:event];
//       UITouch * touch = [touches anyObject];
//       //本次触摸点
//       CGPoint current = [touch locationInView:self];
//       //上次触摸点
//       CGPoint previous = [touch previousLocationInView:self];
//       //未移动的中心点
//       CGPoint center = self.center;
//       //移动之后的中心点(未移动的点+本次触摸点-上次触摸点)
//       center.x += current.x - previous.x;
//       center.y += current.y - previous.y;
//       //更新位置
//       self.center = center;
//}
/*
 取出模型属性
 */
-(void)setModel:(AlertModel *)model
{
 NSLog(@"%@-------%@------%@-------%@",model.device_name,model.food_name,model.expire_date,model.remind_date);
    _model = model;
    self.iconImageView.image = [self getImage:model.icon];
    self.nameLabel.text  = model.device_name;
    if (model.device_name == NULL) {
        self.nameLabel.text = @"该设备没有记录";
    }
    self.foodName.text   = model.food_name;
    self.expireDate.text = model.expire_date;
    self.remindDate.text = model.remind_date;
}
//取出保存在本地的图片
-(UIImage*)getImage:(NSString *)filepath{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photopath = [NSString stringWithFormat:@"%@.png",filepath];
    NSString *imagePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",photopath]];
    // 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    NSLog(@"=== %@", img);
    return img;
}
//退出键盘
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.foodName resignFirstResponder];
    [self.expireDate resignFirstResponder];
    return YES;
}
-(void)SetEditedState{
    if (self.isEditOK) {
        self.isEditOK = NO;
        self.expireDate.userInteractionEnabled = YES;
        self.expireDate.enabled = YES;
        self.remindDate.userInteractionEnabled = YES;
        self.remindDate.enabled = YES;
    }else{
        self.isEditOK = YES;
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (self.isEditOK) {
        return YES;
    }else{
        return NO;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
