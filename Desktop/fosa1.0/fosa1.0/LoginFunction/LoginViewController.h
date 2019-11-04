//
//  LoginViewController.h
//  fosa1.0
//
//  Created by hs on 2019/10/28.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#pragma mask -- 声明协议方法
@protocol PassValueDelegate <NSObject>
 -(void)passValue:(NSString *)content;
@end

@interface LoginViewController : UIViewController

@property (nonatomic,strong) UIView *userNameView,*passwordView;
@property (nonatomic,strong) UIImageView *userImage,*passwordImage,*logo;
@property (nonatomic,strong) UITextField *userNameInput,*passwordInput;
@property (nonatomic,strong) UIButton *login,*checkPassword,*registbtn;
@property (nonatomic,strong) UISwitch *remember;
@property (nonatomic,strong) UILabel *memory,*forgetpassword,*regist;
@property (nonatomic,assign) CGFloat mainWidth,mainHeight,navHeight;

@property (nonatomic,copy) NSString *content;
#pragma mask -- 声明代理人属性
@property (nonatomic,assign) id<PassValueDelegate> delegate;


@end

NS_ASSUME_NONNULL_END
