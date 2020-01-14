//
//  foodKindCollectionViewCell.m
//  FOSAapp1.0
//
//  Created by hs on 2020/1/9.
//  Copyright © 2020 hs. All rights reserved.
//

#import "foodKindCollectionViewCell.h"

@implementation foodKindCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.kind = [[UILabel alloc]initWithFrame:self.bounds];
        self.kind.textAlignment = NSTextAlignmentCenter;
        self.kind.textColor = [UIColor blackColor];
        self.kind.layer.cornerRadius = 10;
        [self addSubview:self.kind];
    }
    return self;
}
//
//- (void)setSelected:(BOOL)selected{
//    [super setSelected:selected];
//    if(selected) {
//        self.kind.backgroundColor = FOSAgreen;
//    }else{
//        self.kind.backgroundColor = [UIColor whiteColor];
//    }
//
//}
@end
