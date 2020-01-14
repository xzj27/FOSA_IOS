//
//  MenuTableViewCellXIB.h
//  FOSAapp1.0
//
//  Created by hs on 2020/1/9.
//  Copyright © 2020 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MenuTableViewCellXIB : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *categoryIcon;
@property (weak, nonatomic) IBOutlet UILabel *categoryTitle;

- (void)configCell:(NSString *)title;
@end

NS_ASSUME_NONNULL_END
