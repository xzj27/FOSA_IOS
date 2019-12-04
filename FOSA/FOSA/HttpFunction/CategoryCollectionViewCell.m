//
//  CategoryCollectionViewCell.m
//  FOSA
//
//  Created by hs on 2019/12/2.
//  Copyright © 2019 hs. All rights reserved.
//

#import "CategoryCollectionViewCell.h"
#import "CategoryModel.h"
@implementation CategoryCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.categoryIcon = [[UIImageView alloc]initWithFrame:CGRectMake(5, 5, self.bounds.size.width-10, self.bounds.size.height*2/3)];
        self.categoryIcon.contentMode   = UIViewContentModeScaleAspectFit;
        self.categoryIcon.clipsToBounds = YES;
        self.categoryIcon.layer.cornerRadius = 5;
        
        [self addSubview:self.categoryIcon];
        
        self.categoryLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,self.bounds.size.height*2/3, self.bounds.size.width, self.bounds.size.height/3)];
        self.categoryLabel.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:self.categoryLabel];
    }
    return self;
}

- (void)setModel:(CategoryModel *)model{
    _model = model;
    _categoryLabel.text = model.cagegoryName;
    _categoryIcon.image = [UIImage imageNamed:model.categoryImg];
}

@end
