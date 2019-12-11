//
//  SealerCell.m
//  FOSA
//
//  Created by hs on 2019/11/28.
//  Copyright © 2019 hs. All rights reserved.
//

#import "SealerCell.h"

@implementation SealerCell
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
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat width = screen_width-10;
        CGFloat height = 100;
        self.backgroundColor = [UIColor colorWithRed:208/255.0 green:208/255.0 blue:208/255.0 alpha:1.0];
        self.foodImgView = [[UIImageView alloc]initWithFrame:CGRectMake(5, height/4, height/2, height/2)];
        [self addSubview:self.foodImgView];
        
        self.foodNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(height/2, height/4, width/4, height/2)];
        self.foodNameLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_foodNameLabel];
        
        self.storageLabel = [[UILabel alloc]initWithFrame:CGRectMake(height/2+width/4, 0, (width*3/4-height/2), height/2)];
        [self addSubview:_storageLabel];

         self.expireLabel = [[UILabel alloc]initWithFrame:CGRectMake(height/2+width/4, height/2, (width*3/4-height/2), height/2)];
        [self addSubview:_expireLabel];
//        self.checkBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width-self.bounds.size.height, self.bounds.size.height/6, self.bounds.size.height*2/3, self.bounds.size.height*2/3)];
//        [_checkBtn setImage:[UIImage imageNamed:@"icon_detail"] forState:UIControlStateNormal];
//        [self addSubview:_checkBtn];
    }
    return self;
}

@end
