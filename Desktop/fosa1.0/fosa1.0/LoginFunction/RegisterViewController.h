//
//  RegisterViewController.h
//  fosa1.0
//
//  Created by hs on 2019/10/28.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RegisterViewController : UIViewController

@property (nonatomic,strong) UIView *userNameView,*passwordView,*verifiCationCodeView;
@property (nonatomic,strong) UIImageView *userImage,*passwordImage,*logo;
@property (nonatomic,strong) UITextField *userNameInput,*passwordInput,*verificatinCodeInput;
@property (nonatomic,strong) UIButton *regist,*checkPassword;
@property (nonatomic,strong) UISwitch *remember;
@property (nonatomic,strong) UILabel *memory,*verification;
@property (nonatomic,assign) CGFloat mainWidth,mainHeight,navHeight;

@end

NS_ASSUME_NONNULL_END
