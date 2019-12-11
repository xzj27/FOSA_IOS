//
//  UserItem.h
//  FOSA
//
//  Created by hs on 2019/12/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserItem : UIView
@property (nonatomic,weak) UILabel *itemLabel;
@property (nonatomic,weak) UIButton *showContent;
@property (nonatomic,weak) UIImageView *itemImgView;
@end

NS_ASSUME_NONNULL_END
