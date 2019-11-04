//
//  FoodView.m
//  fosa1.0
//
//  Created by hs on 2019/10/30.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FoodView.h"
#import "FoodModel.h"
@interface FoodView()

@property (nonatomic,weak) UILabel *nameLabel,*dateLabel;
@property (nonatomic,weak) UIImageView *foodImageview;

@end


@implementation FoodView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *name = [[UILabel alloc]init];
        self.nameLabel = name;
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.nameLabel];
        
        UILabel *date = [[UILabel alloc]init];
        self.dateLabel = date;
        self.dateLabel.textColor = [UIColor blackColor];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:self.dateLabel];
        
        UIImageView *photo = [[UIImageView alloc]init];
        self.foodImageview = photo;
        self.foodImageview.transform = CGAffineTransformMakeRotation(M_PI/2);
        [self addSubview:self.foodImageview];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.nameLabel.frame = CGRectMake(0, 5, self.bounds.size.width,self.bounds.size.height/6);
    self.dateLabel.frame = CGRectMake(0, self.bounds.size.height/6+5, self.bounds.size.width, self.bounds.size.height/6);
    self.foodImageview.frame = CGRectMake((self.bounds.size.width-self.bounds.size.height*2/3)/2, self.bounds.size.height*1/3+5, self.bounds.size.height*2/3-10, self.bounds.size.height*2/3-10);
}
-(void)setModel:(FoodModel *)model
{
    _model = model;
    self.foodImageview.image = [self getImage:model.foodPhoto];
    self.nameLabel.text  = model.foodName;
    self.dateLabel.text = model.expiredDate;
}
//取出保存在本地的图片
-(UIImage*)getImage:(NSString *)filepath{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photopath = [NSString stringWithFormat:@"%@.png",filepath];
    NSString *imagePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",photopath]];
    // 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    NSLog(@"===%@", img);
    return img;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.alpha = 0.5;
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.alpha = 1;
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.alpha = 1;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
