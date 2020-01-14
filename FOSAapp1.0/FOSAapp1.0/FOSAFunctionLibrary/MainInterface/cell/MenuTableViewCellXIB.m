//
//  MenuTableViewCellXIB.m
//  FOSAapp1.0
//
//  Created by hs on 2020/1/9.
//  Copyright © 2020 hs. All rights reserved.
//

#import "MenuTableViewCellXIB.h"

@implementation MenuTableViewCellXIB
- (void)configCell:(NSString *)title{
    self.categoryTitle.text = title;
    self.categoryIcon.image = [UIImage imageNamed:title];
}
@end
