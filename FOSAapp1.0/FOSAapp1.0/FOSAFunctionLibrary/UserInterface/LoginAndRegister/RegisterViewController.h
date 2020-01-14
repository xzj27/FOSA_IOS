//
//  RegisterViewController.h
//  FOSAapp1.0
//
//  Created by hs on 2020/1/3.
//  Copyright © 2020 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RegisterViewController : UIViewController

@property (strong,nonatomic) UIView *logoContainer,*userContainer,*verificationView,*passwordContainer,*LoginContainer;
@property (strong,nonatomic) UIImageView *FOSALogo;
@property (strong,nonatomic) UITextField *userNameInput,*passwordInput,*verificatonInput;
@property (strong,nonatomic) UISwitch *remember;
@property (strong,nonatomic) UILabel *rememberLabel,*verificationLabel;
@property (strong,nonatomic) UIButton *signUp;

@end

NS_ASSUME_NONNULL_END
