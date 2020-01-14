//
//  RegisterViewController.m
//  FOSAapp1.0
//
//  Created by hs on 2020/1/3.
//  Copyright © 2020 hs. All rights reserved.
//

#import "RegisterViewController.h"
#import "FMDB.h"

@interface RegisterViewController ()<UITextFieldDelegate>{
    FMDatabase *db;
    NSString *docPath;
}
// 当前获取焦点的UITextField
@property (strong, nonatomic) UITextField *currentResponderTextField;
@end
@implementation RegisterViewController

- (UIView *)logoContainer{
    if (_logoContainer == nil) {
        _logoContainer = [[UIView alloc]initWithFrame:CGRectMake(0, screen_width*5/12, screen_width, screen_width/2)];
    }
    return _logoContainer;
}
- (UIView *)userContainer{
    if (_userContainer == nil) {
        _userContainer = [[UIView alloc]initWithFrame:CGRectMake(screen_width/12, screen_width, screen_width*5/6, screen_height/12)];
    }
    return _userContainer;
}

- (UIView *)verificationView{
    if (_verificationView == nil) {
        _verificationView = [[UIView alloc]initWithFrame:CGRectMake(screen_width/12, screen_height/12+screen_width, screen_width*5/6, screen_height/12)];
    }
    return _verificationView;
}

- (UIView *)passwordContainer{
    if (_passwordContainer == nil) {
        _passwordContainer = [[UIView alloc]initWithFrame:CGRectMake(screen_width/12, screen_height/6+screen_width, screen_width*5/6, screen_height/12)];
    }
    return _passwordContainer;
}

- (UIView *)LoginContainer{
    if (_LoginContainer == nil) {
        _LoginContainer = [[UIView alloc]initWithFrame:CGRectMake(screen_width/12, screen_height/4+screen_width+40, screen_width*5/6, screen_height/15)];
    }
    return _LoginContainer;
}
- (UIImageView *)FOSALogo{
    if (_FOSALogo == nil) {
        _FOSALogo = [[UIImageView alloc]init];
    }
    return _FOSALogo;
}
- (UITextField *)userNameInput{
    if (_userNameInput == nil) {
        _userNameInput = [[UITextField alloc]init];
    }
    return _userNameInput;
}

- (UITextField *)verificatonInput{
    if (_verificatonInput == nil) {
        _verificatonInput = [[UITextField alloc]init];
    }
    return _verificatonInput;
}

- (UITextField *)passwordInput{
    if (_passwordInput == nil) {
        _passwordInput = [[UITextField alloc]init];
    }
    return _passwordInput;
}
- (UISwitch *)remember{
    if (_remember == nil) {
        _remember = [[UISwitch alloc]init];
    }
    return _remember;
}

- (UILabel *)rememberLabel{
    if (_rememberLabel == nil) {
        _rememberLabel = [[UILabel alloc]init];
    }
    return _rememberLabel;
}

- (UILabel *)verificationLabel{
    if (_verificationLabel == nil) {
        _verificationLabel = [[UILabel alloc]init];
    }
    return _verificationLabel;
}

- (UIButton *)signUp{
    if (_signUp == nil) {
        _signUp = [[UIButton alloc]init];
    }
    return _signUp;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 在ViewController加载到时候注册通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                                   selector:@selector(keyboardWillShow:)     // 软键盘出现的时候，回调到方法
                                                       name:UIKeyboardWillShowNotification
                                                     object:nil];
   [[NSNotificationCenter defaultCenter] addObserver:self
                                                   selector:@selector(keyboardWillHide:)     // 软键盘消失的时候，回调到方法
                                                       name:UIKeyboardWillHideNotification
                                                     object:nil];
    [self CreatSignUpView];
}

- (void)CreatSignUpView{
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.logoContainer];
    [self.view addSubview:self.userContainer];
    [self.view addSubview:self.passwordContainer];
    [self.view addSubview:self.verificationView];
    [self.view addSubview:self.LoginContainer];

    CGFloat logoW = self.logoContainer.frame.size.width;
    CGFloat logoH = self.logoContainer.frame.size.height;
    CGFloat logoX = (logoW - logoH)/2;
    self.FOSALogo.frame = CGRectMake(logoX, 0, logoH, logoH);
    self.FOSALogo.image = [UIImage imageNamed:@"icon_logoHL"];
    [self.logoContainer addSubview:self.FOSALogo];
    
    self.userNameInput.frame = CGRectMake(0, 5, screen_width*5/6, screen_height/12-10);
    self.userNameInput.placeholder = @"    Phone Number/E-Mail";
    self.userNameInput.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    self.userNameInput.returnKeyType = UIReturnKeyDone;
    self.userNameInput.delegate = self;
    self.userNameInput.layer.cornerRadius = self.userNameInput.frame.size.height/3;
    [self.userContainer addSubview:self.userNameInput];
    
    self.verificatonInput.frame = CGRectMake(0, 5, self.verificationView.frame.size.width/2, screen_height/12-10);
    self.verificatonInput.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    self.verificatonInput.returnKeyType = UIReturnKeyDone;
    self.verificatonInput.delegate = self;
    self.verificatonInput.layer.cornerRadius = self.verificatonInput.frame.size.height/3;
    self.verificatonInput.returnKeyType = UIReturnKeyDone;;
    [self.verificationView addSubview:self.verificatonInput];
    self.verificationLabel.frame = CGRectMake(self.verificationView.frame.size.width*3/5, 0, self.verificationView.frame.size.width*2/5, screen_height/12);
    self.verificationLabel.userInteractionEnabled = YES;
    self.verificationLabel.font = [UIFont systemFontOfSize:14*(screen_width/414)];
    //文字添加下划线
    NSDictionary * underAttribtDic  = @{NSUnderlineStyleAttributeName:[NSNumber numberWithInteger:NSUnderlineStyleSingle],NSForegroundColorAttributeName:[UIColor blackColor]};
    NSMutableAttributedString * underAttr = [[NSMutableAttributedString alloc] initWithString:@"Get Veritigication" attributes:underAttribtDic];
    
    self.verificationLabel.attributedText = underAttr;
    [self.verificationView addSubview:self.verificationLabel];
    
    self.passwordInput.frame = CGRectMake(0, 5, screen_width*5/6, screen_height/12-10);
    self.passwordInput.placeholder = @"    Password";
    self.passwordInput.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    self.passwordInput.returnKeyType = UIReturnKeyDone;
    self.passwordInput.delegate = self;
    self.passwordInput.layer.cornerRadius = self.passwordInput.frame.size.height/3;
    [self.passwordContainer addSubview:self.passwordInput];
    
        //创建渐变色
//        CAGradientLayer * gradientLayer = [CAGradientLayer layer];
//        gradientLayer.cornerRadius = self.login.frame.size.height/2;
//        gradientLayer.frame = self.login.bounds;
//        gradientLayer.colors = @[(__bridge id)FOSAgreen.CGColor,(__bridge id)FOSARed.CGColor];
//        gradientLayer.startPoint = CGPointMake(0, 0);
//        gradientLayer.endPoint = CGPointMake(1.0, 1.0);
//        gradientLayer.locations = @[@(1.0f), @(0.5f)];
//        [self.login.layer addSublayer:gradientLayer];
//
    self.remember.frame = CGRectMake(screen_width/12, screen_width+screen_height/4, 51.0, 40);
    [self.view addSubview:self.remember];
    self.rememberLabel.frame = CGRectMake(screen_width/12+60, screen_width+screen_height/4, screen_width/2, 40);
    [self.view addSubview:self.rememberLabel];
    
    self.signUp.frame = CGRectMake(self.LoginContainer.frame.size.width/4, 0, self.LoginContainer.bounds.size.width/2, self.LoginContainer.frame.size.height);
    [self.signUp setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.signUp setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.signUp.backgroundColor = FOSAgreen;
    self.signUp.layer.cornerRadius = self.signUp.frame.size.height/3;
    self.signUp.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.signUp.titleLabel.font = [UIFont systemFontOfSize:25];
    [self.signUp addTarget:self action:@selector(SignUpEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.LoginContainer addSubview:self.signUp];
    
}
//注册按钮事件
- (void)SignUpEvent{
    if ([self.userNameInput.text isEqualToString:@""] || [self.passwordInput.text isEqualToString:@""]) {
        [self SystemAlert:@"账号或密码不能为空"];
    }else{
        [self CreatSqlDatabase:@"FOSA"];
    }
}
//弹出系统提示
-(void)SystemAlert:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    if ([message isEqualToString:@"账号或密码不能为空"]) {
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:true completion:nil];
    }else{
        [alert addAction:[UIAlertAction actionWithTitle:@"返回登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            //点击回调
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:true completion:nil];
    }
}
#pragma mark - 数据库操作
- (void)CreatSqlDatabase:(NSString *)dataBaseName{
    //获取数据库地址
    docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
    NSLog(@"%@",docPath);
    //设置数据库名
    NSString *fileName = [docPath stringByAppendingPathComponent:dataBaseName];
    //创建数据库
    db = [FMDatabase databaseWithPath:fileName];
    if([db open]){
        NSLog(@"打开数据库成功");
        [self CreatUserTable];
    }else{
        NSLog(@"打开数据库失败");
    }
    [db close];
}

- (void)CreatUserTable{
    NSString *UserTableSql = @"create table if not exists Fosa_User(id integer primary key,userName text,password text)";
    BOOL result = [db executeUpdate:UserTableSql];
    if (result) {
        NSLog(@"打开用户表成功!");
        [self InsertDataIntoTable];
    }else{
        NSLog(@"打开用户表失败");
    }
}

- (void)InsertDataIntoTable{
    NSString *insertTableSql = @"insert into Fosa_User(userName,password) values(?,?)";
    if ([db open]) {
        BOOL result = [db executeUpdate:insertTableSql, self.userNameInput.text,self.passwordInput.text];
        if (result) {
            NSLog(@"Insert into table successfully");
            [self SystemAlert:@"注册成功"];
            [self SelectAllUser];
        }else{
            NSLog(@"Insert fail");
        }
    }else{
        NSLog(@"Open failed");
    }
}

- (void)SelectAllUser{
    NSString *sql = @"select * from Fosa_User";
    FMResultSet *set = [db executeQuery:sql];
    while ([set next]) {
        NSString *name = [set stringForColumn:@"userName"];
        NSString *password = [set stringForColumn:@"password"];
        NSLog(@"%@=============%@",name,password);
    }
}

//退出键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.currentResponderTextField = textField;
    return YES;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.userNameInput endEditing:YES];
    [self.passwordInput endEditing:YES];
    [self.verificatonInput endEditing:YES];
}
- (void)keyboardWillShow:(NSNotification *)notification {
    if (!(self.currentResponderTextField && [self.currentResponderTextField isKindOfClass:[UITextField class]])) {
        // 如果没有响应者不进行操作
        return;
    }
    //获取currentResponderTextField相对于self.view的frame信息
    CGRect rect = [self.currentResponderTextField.superview convertRect:self.currentResponderTextField.frame toView:self.view];
    //获取弹出键盘的frame的value值
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    //获取键盘相对于self.view的frame信息 ，传window和传nil是一样的
    keyboardRect = [self.view convertRect:keyboardRect fromView:self.view.window];
    //弹出软键盘左上角点Y轴的值
    CGFloat keyboardTop = keyboardRect.origin.y;
    //获取键盘弹出动画时间值
    NSNumber * animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = [animationDurationValue doubleValue];
    if (keyboardTop < CGRectGetMaxY(rect)) {
        // true 键盘盖住了输入框
        // 计算整体界面需要往上移动的偏移量，CGRectGetMaxY(rect)表示，输入框Y轴最大值
        CGFloat gap = keyboardTop - CGRectGetMaxY(rect);
        // 存在多个TextField的情况下，可能整体界面可能以及往上移多次，导致self.view的Y轴值不再为0，而是负数
        gap = gap + self.view.frame.origin.y;
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:animationDuration animations:^{
            weakSelf.view.frame = CGRectMake(weakSelf.view.frame.origin.x, gap, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
        }];
    }
}
- (void)keyboardWillHide:(NSNotification *)notification {
    if (!(self.currentResponderTextField && [self.currentResponderTextField isKindOfClass:[UITextField class]])) {
        // 如果没有响应者不进行操作
        return;
    }
    //获取键盘隐藏动画时间值
    NSDictionary *userInfo = [notification userInfo];
    NSNumber * animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = [animationDurationValue doubleValue];
    if (self.view.frame.origin.y < 0) {
        //true 证明已经往上移动，软键盘消失时，整个界面要恢复原样
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:animationDuration animations:^{
            weakSelf.view.frame = CGRectMake(weakSelf.view.frame.origin.x, 0, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
        }];
    }
}
- (void)dealloc
{
    // 注册了通知，在ViewController消失到时候，要移除通知的监听
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}
@end
