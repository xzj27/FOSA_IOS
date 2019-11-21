//
//  SealerTableViewCell.m
//  FOSA
//
//  Created by hs on 2019/11/19.
//  Copyright © 2019 hs. All rights reserved.
//

#import "SealerTableViewCell.h"

@implementation SealerTableViewCell

//
//- (instancetype)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//        self.foodName = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100,self.bounds.size.height)];
//        [self addSubview:self.foodName];
//    }
//    return self;
//}
- (void)InitCellData:(NSString *)data{
    self.foodName.text = data;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
