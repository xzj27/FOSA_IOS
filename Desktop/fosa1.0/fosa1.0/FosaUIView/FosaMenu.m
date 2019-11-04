//
//  FosaMenu.m
//  fosa1.0
//
//  Created by hs on 2019/10/31.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FosaMenu.h"
#import "MenuModel.h"

@interface FosaMenu()
    @property (nonatomic,weak) UILabel *label;
    @property (nonatomic,weak) UIImageView *show_category;
@end

@implementation FosaMenu
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UILabel *label = [[UILabel alloc]init];
        self.label = label;
        self.label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.label];
    }
    return self;
}
- (void)layoutSubviews{
    self.label.frame = CGRectMake(0, self.bounds.size.height/3, self.bounds.size.width, self.bounds.size.height/3);
    //self.show_category.frame = CGRectMake(<#CGFloat x#>, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)
}
-(void)setModel:(MenuModel *)model
{
    _model = model;
    self.label.text = model.categoryName;
}
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.alpha = 1;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    self.alpha = 0.5;
}
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
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
