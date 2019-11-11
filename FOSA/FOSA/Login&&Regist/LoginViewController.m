//
//  LoginViewController.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "FosaUserViewController.h"
#import <sqlite3.h>

@interface LoginViewController ()<UITextFieldDelegate>{
    Boolean isSecure;
}

@property(nonatomic,assign)sqlite3 *database;
//结果集定义
@property(nonatomic,assign)sqlite3_stmt *stmt;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1.0];
    // Do any additional setup after loading the view.
    [self InitView];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
-(void)InitView{
    self.mainWidth = [UIScreen mainScreen].bounds.size.width;
    self.mainHeight = [UIScreen mainScreen].bounds.size.height;
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    
    //返回按钮
    self.back = [[UIButton alloc]initWithFrame:CGRectMake(0,20,30,30)];
    [self.back setImage:[UIImage imageNamed:@"icon_back"] forState:UIControlStateNormal];
    [self.back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.back];
    
    //logo
    self.logo = [[UIImageView alloc]initWithFrame:CGRectMake(self.mainWidth/2-45,70, 90, 90)];
    _logo.layer.cornerRadius = 50;
    _logo.layer.masksToBounds = YES;
    _logo.image = [UIImage imageNamed:@"logo_green"];
    [self.view addSubview:_logo];
    
    self.userNameView = [[UIView alloc]initWithFrame:CGRectMake(5, 170, self.mainWidth-15, 50)];
    self.userNameView.layer.cornerRadius = 5;
    self.userNameView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_userNameView];
    //提示图
    self.userImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 30, 30)];
    _userImage.image = [UIImage imageNamed:@"icon_account"];
    [self.userNameView addSubview:_userImage];
    //账号输入框
    self.userNameInput = [[UITextField alloc]initWithFrame:CGRectMake(40,0, self.userNameView.frame.size.width, 50)];
    _userNameInput.placeholder = @"手机号/邮箱";
    _userNameInput.delegate = self;
    _userNameInput.returnKeyType = UIReturnKeyDone;
    [self.userNameView addSubview:_userNameInput];
    
    self.passwordView = [[UIView alloc]initWithFrame:CGRectMake(5, 230, self.mainWidth-15, 50)];
    self.passwordView.layer.cornerRadius = 5;
    self.passwordView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.passwordView];

    //密码提示图
    self.passwordImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 10, 30, 30)];
    _passwordImage.image = [UIImage imageNamed:@"icon_password"];
    [self.passwordView addSubview:_passwordImage];
    //输入密码框
    self.passwordInput = [[UITextField alloc]initWithFrame:CGRectMake(40,0, self.passwordView.frame.size.width-50, 50)];
    _passwordInput.placeholder = @"密码";
    _passwordInput.secureTextEntry = YES ; //隐藏密码
    isSecure = true;
    _passwordInput.delegate = self; //遵守代理
    _passwordInput.returnKeyType = UIReturnKeyDone;
    [self.self.passwordView addSubview:_passwordInput];
    
    self.checkPassword = [[UIButton alloc]initWithFrame:CGRectMake(self.passwordView.frame.size.width-50, 0, 50, 50)];
    [self.checkPassword setImage:[UIImage imageNamed:@"icon_checkPassword"] forState:UIControlStateNormal];
    [_checkPassword addTarget:self action:@selector(pwdtextSwitch) forControlEvents:UIControlEventTouchUpInside];
    //[self.checkPassword setImage:[UIImage imageNamed:@"icon_checkPasswordHL"] forState:UIControlStateHighlighted];
    [self.passwordView addSubview:self.checkPassword];
    
    //记住密码
    self.remember = [[UISwitch alloc]initWithFrame:CGRectMake(5,290, 60, 40)];
    [self.view addSubview:self.remember];
    self.memory = [[UILabel alloc]initWithFrame:CGRectMake(60, 290,120,40)];
    self.memory.text = @"记住账号密码";
    self.memory.font = [UIFont systemFontOfSize:15];
    self.remember.tintColor = [UIColor orangeColor];
    //self.remember.thumbTintColor =[UIColor blueColor];
    [self.view addSubview:self.memory];
    
    //忘记密码
    self.forgetpassword = [[UILabel alloc]initWithFrame:CGRectMake(self.mainWidth-80, 460, 120, 40)];
    self.forgetpassword.text = @"忘记密码";
    self.forgetpassword.textColor = [UIColor blackColor];
    self.forgetpassword.font = [UIFont systemFontOfSize:15];
    [self.view addSubview:self.forgetpassword];
    
    //登录按钮
    self.login = [[UIButton alloc]initWithFrame:CGRectMake(10, 330, self.mainWidth-20, 50)];
    _login.backgroundColor = [UIColor orangeColor];
    [_login setTitle:@"登录" forState:UIControlStateNormal];
    _login.layer.cornerRadius = 5;
    [self.view addSubview:_login];
    [self.login addTarget:self action:@selector(beginLogin) forControlEvents:UIControlEventTouchUpInside];
    
    //注册按钮
    self.registbtn = [[UIButton alloc]initWithFrame:CGRectMake(10, 400, self.mainWidth-20, 50)];
    _registbtn.backgroundColor = [UIColor orangeColor];
    [_registbtn setTitle:@"注册" forState:UIControlStateNormal];
    _login.layer.cornerRadius = 5;
    [self.view addSubview:_registbtn];
    [self.registbtn addTarget:self action:@selector(jumpToRegist) forControlEvents:UIControlEventTouchUpInside];
    
    //注册
    self.regist = [[UILabel alloc]initWithFrame:CGRectMake(10, 460, 120, 40)];
    self.regist.text = @"立即注册";
    self.regist.font = [UIFont systemFontOfSize:15];
    self.regist.textColor = [UIColor greenColor];
    self.regist.userInteractionEnabled = YES;           //打开交互
    [self.view addSubview:_regist];
    UIGestureRecognizer *registGestureRecognizer = [[UIGestureRecognizer alloc]initWithTarget:self action:@selector(jumpToRegist)];
    [self.regist addGestureRecognizer:registGestureRecognizer];
}
//返回主界面方法
-(void)goBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}
//密码的状态转换
-(void)pwdtextSwitch{
    if (isSecure) {
        NSString *pwd = self.passwordInput.text;
        isSecure = false;
        self.passwordInput.secureTextEntry = NO;
        [self.checkPassword setImage:[UIImage imageNamed:@"icon_checkPasswordHL"] forState:UIControlStateNormal];
        self.passwordInput.text = pwd;
    }else{
        NSString *pwd = self.passwordInput.text;
        isSecure = true;
        self.passwordInput.secureTextEntry = YES;
        [self.checkPassword setImage:[UIImage imageNamed:@"icon_checkPassword"] forState:UIControlStateNormal];
        self.passwordInput.text = pwd;
    }
}
//登录
-(void)beginLogin{
    [self creatOrOpensql];
}
//跳转到注册界面
-(void)jumpToRegist{
    NSLog(@"regist");
    RegisterViewController *regist = [[RegisterViewController alloc]init];
    regist.hidesBottomBarWhenPushed = YES;
    [self presentViewController:regist animated:YES completion:nil];
}
//弹出系统提示
-(void)SystemAlert:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:true completion:nil];
}

//数据库操作
//创建或打开数据库
-(void)creatOrOpensql
{
    if (self.userNameInput.text == NULL || self.passwordInput.text == NULL) {
        [self SystemAlert:@"账号或密码不能为空"];
        return;
    }
    NSString *path = [self getPath];
    char *erro = 0;
    int sqlStatus = sqlite3_open_v2([path UTF8String], &_database,SQLITE_OPEN_CREATE|SQLITE_OPEN_READWRITE,NULL);
    if (sqlStatus == SQLITE_OK) {
        NSLog(@"数据库打开成功");
    }
    //创建数据库表
    const char *sql = "create table if not exists Fosa_User(id integer primary key,userName text,password text)";
    int tabelStatus = sqlite3_exec(self.database, sql,NULL, NULL, &erro);//运行结果
    if (tabelStatus == SQLITE_OK)
    {
        NSLog(@"表创建成功");
    }
    //数据库操作
    [self SelectDataFromSqlite];
}
-(void) SelectDataFromSqlite{
    //查询数据库
    NSString *selectPassword = [NSString stringWithFormat:@"select userName,password from Fosa_User where userName = '%@'",self.userNameInput.text];
    const char *selsql = [selectPassword UTF8String];
    NSLog(@"%s",selsql);
    int selresult = sqlite3_prepare_v2(self.database, selsql, -1,&_stmt, NULL);
    if(selresult != SQLITE_OK){
        [self SystemAlert:@"账号或密码有误"];
    }else{
        while (sqlite3_step(_stmt) == SQLITE_ROW) {
            const char *userName   = (const char*)sqlite3_column_text(_stmt, 0);
            NSLog(@"查询到数据:%@",[NSString stringWithUTF8String:userName]);
            const char *password = (const char*)sqlite3_column_text(_stmt,1);
            NSLog(@"查询到数据:%@",[NSString stringWithUTF8String:password]);
            if ([[NSString stringWithUTF8String:userName] isEqualToString:self.userNameInput.text]&&[[NSString stringWithUTF8String:password] isEqualToString:self.passwordInput.text]) {
               
                [self.delegate passValue:self.userNameInput.text];
                
                [self dismissViewControllerAnimated:YES completion:nil];
            }else{
                [self SystemAlert:@"账号或密码不匹配"];
            }
        }
    }
}

//获取DB数据库所在的document路径
-(NSString *)getPath
{
    NSString *filename = @"Fosa.db";
    NSString *doc = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [doc stringByAppendingPathComponent:filename];
    NSLog(@"%@",filePath);
    return filePath;
}

//退出键盘
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.userNameInput endEditing:YES];
    [self.passwordInput endEditing:YES];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
