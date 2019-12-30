//
//  productCollectionViewCell.m
//  FOSA
//
//  Created by hs on 2019/12/29.
//  Copyright © 2019 hs. All rights reserved.
//

#import "productCollectionViewCell.h"

@implementation productCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.productImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        self.productImageView.layer.cornerRadius = 15;
        self.productImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.productImageView.clipsToBounds = YES;
        [self addSubview:_productImageView];
    }
    return self;
}

@end
