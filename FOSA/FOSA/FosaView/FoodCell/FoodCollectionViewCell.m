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
        self.add = [[UIButton alloc]initWithFrame:self.bounds];
        [_add setImage:[UIImage imageNamed:@"icon_additem"] forState:UIControlStateNormal];
        _add.hidden = YES;
        [self addSubview:_add];

        self.nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.bounds.size.width,self.bounds.size.height/6)];
        self.nameLabel.textColor = [UIColor blackColor];
        self.nameLabel.textAlignment = NSTextAlignmentCenter;
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        self.nameLabel.userInteractionEnabled = NO;
        [self addSubview:self.nameLabel];
       
        self.dateLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.bounds.size.height/6+5, self.bounds.size.width, self.bounds.size.height/6)];
        self.dateLabel.textColor = [UIColor blackColor];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.font = [UIFont systemFontOfSize:10];
        self.dateLabel.userInteractionEnabled = NO;
        [self addSubview:self.dateLabel];
        
        self.foodImageview = [[UIImageView alloc]initWithFrame:CGRectMake((self.bounds.size.width-self.bounds.size.height*2/3)/2, self.bounds.size.height*1/3+5, self.bounds.size.height*2/3-10, self.bounds.size.height*2/3-10)];
        //self.foodImageview.transform = CGAffineTransformMakeRotation(M_PI/2);
        self.foodImageview.userInteractionEnabled = NO;
        self.foodImageview.contentMode = UIViewContentModeScaleAspectFill;
        self.foodImageview.clipsToBounds = YES;
        [self addSubview:self.foodImageview];
        
        
        self.deleteIcon = [[UIImageView alloc]initWithFrame:CGRectMake(self.bounds.size.width-25, 0, 25, 25)];
        _deleteIcon.image = [UIImage imageNamed:@"icon_delete"];
        _deleteIcon.backgroundColor = [UIColor clearColor];
        _deleteIcon.hidden = YES;
        [self addSubview:self.deleteIcon];

        self.cancelIcon = [[UIImageView alloc]initWithFrame:CGRectMake(self.bounds.size.width/2, 0, self.bounds.size.width/2, self.bounds.size.height)];
        _cancelIcon.backgroundColor = [UIColor clearColor];
        _cancelIcon.hidden = YES;
        _cancelIcon.image = [UIImage imageNamed:@"icon_cancel"];
        [self addSubview:self.deleteIcon];
    
    }
    return self;
}
- (void)setModel:(CellModel *)model
{
    _model = model;
    self.foodImageview.image = [self getImage:model.foodPhoto];
    self.nameLabel.text  = model.foodName;
    if (model.foodName == NULL) {
        self.add.hidden = NO;
        self.nameLabel.hidden = YES;
        self.dateLabel.hidden = YES;
        self.foodImageview.hidden = YES;
    }else{
        self.add.hidden = YES;
        self.nameLabel.hidden = NO;
        self.dateLabel.hidden = NO;
        self.foodImageview.hidden = NO;
    }
    
    self.dateLabel.text = [NSString stringWithFormat:@"Remind:%@",model.remindDate ];
}
//取出保存在本地的图片
- (UIImage*)getImage:(NSString *)filepath{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photopath = [NSString stringWithFormat:@"%@.png",filepath];
    NSString *imagePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",photopath]];
    // 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    NSLog(@"===%@", img);
    return img;
}
@end

