//
//  DeviceCollectionViewCell.m
//  FOSAapp1.0
//
//  Created by hs on 2020/1/6.
//  Copyright © 2020 hs. All rights reserved.
//

#import "DeviceCollectionViewCell.h"

@implementation DeviceCollectionViewCell

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
