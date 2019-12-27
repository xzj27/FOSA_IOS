//
//  FoodCollectionViewCell.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FoodCollectionViewCell.h"
#import "CellModel.h"
@implementation FoodCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat cellWidth = self.frame.size.width;
        CGFloat cellHeight = self.frame.size.height;
        
        self.add = [[UIButton alloc]initWithFrame:self.bounds];
        [_add setImage:[UIImage imageNamed:@"icon_additem"] forState:UIControlStateNormal];
        _add.hidden = YES;
        //[self addSubview:_add];

        //文字添加阴影
        NSShadow *shadow = [[NSShadow alloc] init];

        shadow.shadowBlurRadius = 4;//阴影半径，默认值3

        shadow.shadowColor = [UIColor blackColor];//阴影颜色

        shadow.shadowOffset = CGSizeMake(1, 5);//阴影偏移量，x向右偏移，y向下偏移，默认是（0，-3）

        NSAttributedString * attributedText = [[NSAttributedString alloc] initWithString:@"" attributes:@{NSShadowAttributeName:shadow}];
        
        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.bounds.size.height*5/6-5, self.bounds.size.width, self.bounds.size.height/6)];
        self.nameLabel.textColor = [UIColor colorWithWhite:200.0 alpha:1];
        //self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font = [UIFont systemFontOfSize:16*([UIScreen mainScreen].bounds.size.width/414.0)];
        self.nameLabel.userInteractionEnabled = NO;
        self.nameLabel.attributedText = attributedText;
        [self insertSubview:_nameLabel atIndex:20];

        self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.bounds.size.width,self.bounds.size.height/6)];
        self.dateLabel.textColor = [UIColor colorWithWhite:250.0 alpha:1];
        //self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.font = [UIFont systemFontOfSize:10];
        self.dateLabel.userInteractionEnabled = NO;
        self.dateLabel.attributedText = attributedText;
        [self insertSubview:_dateLabel atIndex:20];
        
        self.foodImageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, cellWidth, cellHeight)];
        NSLog(@"#######################cellWidth = %f--------cellHeight = %f ",cellWidth,cellHeight);
        self.foodImageview.contentMode = UIViewContentModeScaleAspectFill;
        self.foodImageview.clipsToBounds = YES;
        [self.contentView addSubview:self.foodImageview];
    }
    return self;
}
- (void)setModel:(CellModel *)model
{
    NSArray<NSString *> *timeArray;
    _model = model;
    self.foodImageview.image = [self getImage:model.foodPhoto];
    self.nameLabel.text  = model.foodName;
    timeArray = [model.remindDate componentsSeparatedByString:@"/"];
    self.dateLabel.text = [NSString stringWithFormat:@"%@/%@",timeArray[2],timeArray[1]];
}
//取出保存在本地的图片
- (UIImage*)getImage:(NSString *)filepath{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photopath = [NSString stringWithFormat:@"%@.png",filepath];
    NSString *imagePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",photopath]];
    // 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    //NSLog(@"===%@", img);
    return img;
}
@end

