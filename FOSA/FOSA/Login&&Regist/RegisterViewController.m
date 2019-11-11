//
//  RegisterViewController.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "RegisterViewController.h"
#import "LoginViewController.h"
#import <sqlite3.h>

@interface RegisterViewController ()<UITextFieldDelegate>{
    Boolean isSecure;
}
@property(nonatomic,assign)sqlite3 *database;
//结果集定义
@property(nonatomic,assign)sqlite3_stmt *stmt;

@end
@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.view.backgroundColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1.0];
    [self InitView];
}

-(void)InitView{
    self.mainWidth = [UIScreen mainScreen].bounds.size.width;
    self.mainHeight = [UIScreen mainScreen].bounds.size.height;
    self.navHeight = self.navigationController.navigationBar.frame.size.height;
    //logo
    self.logo = [[UIImageView alloc]initWithFrame:CGRectMake(self.mainWidth/2-45, 20, 90, 90)];
    _logo.layer.cornerRadius = 50;
    _logo.layer.masksToBounds = YES;
    _logo.image = [UIImage imageNamed:@"logo_green"];
    [self.view addSubview:_logo];
    
    self.userNameView = [[UIView alloc]initWithFrame:CGRectMake(10, 120, self.mainWidth-20, 50)];
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
    
    //验证码
    self.verifiCationCodeView = [[UIView alloc]initWithFrame:CGRectMake(10, 180, (self.mainWidth-20),50)];
    self.verifiCationCodeView.backgroundColor = [UIColor colorWithRed:228/255.0 green:228/255.0 blue:228/255.0 alpha:1.0];;
    self.verifiCationCodeView.layer.cornerRadius = 5;
    [self.view addSubview:self.verifiCationCodeView];
    
    self.verification = [[UILabel alloc]initWithFrame:CGRectMake((self.verifiCationCodeView.frame.size.width)*2/3,0, self.userNameView.frame.size.width/3,50)];
    self.verification.text = @"获取验证码";
    self.verificatinCodeInput = [[UITextField alloc]initWithFrame:CGRectMake(0,0,(self.verifiCationCodeView.frame.size.width)*2/3, 50)];
    self.verificatinCodeInput.backgroundColor = [UIColor whiteColor];
    self.verificatinCodeInput.layer.cornerRadius = 5;
    self.verificatinCodeInput.returnKeyType = UIReturnKeyDone;
    [self.verifiCationCodeView addSubview:self.verificatinCodeInput];
    [self.verifiCationCodeView addSubview:self.verification];
    
    self.passwordView = [[UIView alloc]initWithFrame:CGRectMake(10, 240, self.mainWidth-20, 50)];
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
    self.remember = [[UISwitch alloc]initWithFrame:CGRectMake(5,300,60,40)];
    [self.view addSubview:self.remember];
    self.memory = [[UILabel alloc]initWithFrame:CGRectMake(60, 300,120,40)];
    self.memory.text = @"记住账号密码";
    self.memory.font = [UIFont systemFontOfSize:15];
    self.remember.tintColor = [UIColor blueColor];
    [self.view addSubview:self.memory];
    
    //注册按钮
    self.regist = [[UIButton alloc]initWithFrame:CGRectMake(10,350, self.mainWidth-20, 50)];
    _regist.backgroundColor = [UIColor orangeColor];
    [_regist setTitle:@"立即注册" forState:UIControlStateNormal];
    _regist.layer.cornerRadius = 15;
    [self.view addSubview:_regist];
    [self.regist addTarget:self action:@selector(creatOrOpensql) forControlEvents:UIControlEventTouchUpInside];

}

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
//弹出系统提示
-(void)SystemAlert:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"返回登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        //点击回调
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
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
    int tabelStatus = sqlite3_exec(self.database, sql,NULL,NULL,&erro);//运行结果
    if (tabelStatus == SQLITE_OK)
    {
        NSLog(@"表创建成功");
    }
    //数据库操作
    [self InsertDataIntoSqlite];
}
-(void) InsertDataIntoSqlite{
    char *erro = 0;
    //查询数据库
    NSString *insertSql =[NSString stringWithFormat:@"insert into Fosa_User(userName,password)values('%@','%@')",self.userNameInput.text,self.passwordInput.text];
        int insertResult = sqlite3_exec(self.database, insertSql.UTF8String,NULL, NULL,&erro);
        if(insertResult == SQLITE_OK){
            [self SystemAlert:@"注册成功"];
        }else{
            NSLog(@"插入数据失败");
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
    [self.verificatinCodeInput endEditing:YES];
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
