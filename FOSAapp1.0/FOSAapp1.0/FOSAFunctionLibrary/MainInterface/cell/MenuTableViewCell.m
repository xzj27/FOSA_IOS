//
//  MenuTableViewCell.m
//  FOSAapp1.0
//
//  Created by hs on 2019/12/30.
//  Copyright © 2019 hs. All rights reserved.
//

#import "MenuTableViewCell.h"

@implementation MenuTableViewCell

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
    if (self) {
         NSLog(@"%f~~~~~~~~~~%f",self.bounds.size.width,self.bounds.size.height);
           NSLog(@"%f<><><><>%f",self.contentView.frame.size.width,self.contentView.frame.size.height);
        self.categoryIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.height*2/3, self.bounds.size.height*2/3)];
        [self.contentView addSubview:self.categoryIcon];
        
        self.categoryTitle = [[UILabel alloc]initWithFrame:CGRectMake(0, self.bounds.size.height*2/3, self.bounds.size.width, self.bounds.size.height/3)];
        self.categoryTitle.font = [UIFont systemFontOfSize:14*(screen_width/414.0)];
        [self.contentView addSubview:self.categoryTitle];
    }
    return self;
}

@end
