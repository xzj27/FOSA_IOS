//
//  LoginViewController.h
//  FOSAapp1.0
//
//  Created by hs on 2020/1/3.
//  Copyright © 2020 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LoginViewController : UIViewController

@property (strong,nonatomic) UIView *logoContainer,*userContainer,*passwordContainer,*rememberContainer,*LoginContainer;
@property (strong,nonatomic) UIImageView *FOSALogo;
@property (strong,nonatomic) UITextField *userNameInput,*passwordInput;
@property (strong,nonatomic) UISwitch *remember;
@property (strong,nonatomic) UILabel *rememberLabel,*forgetPassword;
@property (strong,nonatomic) UIButton *login,*signUp,*checkPassword;
@end

NS_ASSUME_NONNULL_END
