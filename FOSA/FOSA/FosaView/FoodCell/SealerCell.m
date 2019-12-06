//
//  SealerCell.m
//  FOSA
//
//  Created by hs on 2019/11/28.
//  Copyright © 2019 hs. All rights reserved.
//

#import "SealerCell.h"

@implementation SealerCell

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
        NSLog(@"%f#################%f",self.bounds.size.width,self.bounds.size.height);
         self.expireLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width/2-15, self.bounds.size.height/2, self.bounds.size.width/2-self.bounds.size.height, self.bounds.size.height/2)];
            [self addSubview:_expireLabel];
        self.checkBtn = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width-self.bounds.size.height, self.bounds.size.height/6, self.bounds.size.height*2/3, self.bounds.size.height*2/3)];
        [_checkBtn setImage:[UIImage imageNamed:@"icon_detail"] forState:UIControlStateNormal];
        [self addSubview:_checkBtn];
    }
    return self;
}

@end
