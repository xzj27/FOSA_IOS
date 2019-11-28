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
         self.expireLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width/2, self.bounds.size.height/4, self.bounds.size.width/2, self.bounds.size.height/2)];
            [self addSubview:_expireLabel];
    }
    return self;
}

@end
