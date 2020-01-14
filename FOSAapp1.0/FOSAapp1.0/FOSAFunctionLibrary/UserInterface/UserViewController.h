//
//  UserViewController.h
//  FOSAapp1.0
//
//  Created by hs on 2019/12/30.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LoginViewController.h"
#import "RegisterViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface UserViewController : UIViewController
@property (nonatomic,strong) UIView *header;
@property (nonatomic,strong) UIImageView *userIcon,*headerBackgroundImgView;
@property (nonatomic,strong) UILabel *userName;
@property (nonatomic,strong) UITableView *userItemTable;

@end

NS_ASSUME_NONNULL_END
