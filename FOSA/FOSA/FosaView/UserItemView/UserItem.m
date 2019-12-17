//
//  UserItem.m
//  FOSA
//
//  Created by hs on 2019/12/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "UserItem.h"

@interface  UserItem(){
    Boolean *isOpen;
}
@end

@implementation UserItem

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *img = [[UIImageView alloc]initWithFrame:CGRectMake(5, self.bounds.size.height/4, self.bounds.size.height/2, self.bounds.size.height/2)];
        self.itemImgView = img;
        [self addSubview:self.itemImgView];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.height, 0, self.bounds.size.width-self.bounds.size.height, self.bounds.size.height)];
        self.itemLabel = label;
        self.itemLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_itemLabel];
        
        UIButton *button = [[UIButton alloc]initWithFrame:CGRectMake(self.bounds.size.width*5/6, 0, self.bounds.size.height, self.bounds.size.height)];
        self.showContent = button;
        
        [_showContent setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
        isOpen = false;
        //[_showContent addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_showContent];
    }
    return self;
}
//
//- (void)click{
//    if (!isOpen) {
//        [self.showContent setImage:[UIImage imageNamed:@"icon_open"] forState:UIControlStateNormal];
//        isOpen = true;
//    }else{
//        [self.showContent setImage:[UIImage imageNamed:@"icon_close"] forState:UIControlStateNormal];
//        isOpen = false;
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
