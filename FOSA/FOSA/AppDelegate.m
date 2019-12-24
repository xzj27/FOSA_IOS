//
//  AppDelegate.m
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "AppDelegate.h"

#import "CategoryModel.h"
#import "SqliteManager.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif

#import "RootTabBarViewController.h"

@interface AppDelegate ()<UNUserNotificationCenterDelegate>{
    NSMutableArray *arrayData;
    NSMutableArray *dict;
}

@property (nonatomic,assign) sqlite3 *database;
@property (nonatomic,assign) sqlite3_stmt *stmt;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    if (@available(iOS 13,*)) {
        [self UpdateCategoryDataFromServer];
        [NSThread sleepForTimeInterval:4];
        return YES;
       }else{
       //创建window
       self.window = [[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
       //添加根控制器
       self.window.rootViewController = [[RootTabBarViewController alloc]init];
       //显示window
       [self.window makeKeyAndVisible];
       //[self InitNutrientDataFromServer];
       [self UpdateCategoryDataFromServer];
       [NSThread sleepForTimeInterval:4];
       return YES;
       }
}
//禁止应用屏幕自动旋转
- (BOOL)shouldAutorotate{
    return NO;
}

#pragma mark - UISceneSession lifecycle
- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options  API_AVAILABLE(ios(13.0)){
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}
- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions  API_AVAILABLE(ios(13.0)){
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

//在启动的时候查询服务器数据
- (void)UpdateCategoryDataFromServer{
    NSLog(@"@@@@@@@@@@@@@@@");
    NSMutableArray<CategoryModel *> *DataArray = [[NSMutableArray alloc]init];
    //服务器地址
    NSString *serverAddr = @"http://192.168.3.109/fosa/HttpComunication.php";
   // NSString *serverAddr = @"http://192.168.43.21/fosa/HttpComunication.php";
    
    NSURL *url = [NSURL URLWithString:serverAddr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 2.0; //设置请求超时为4秒
    //4、创建get请求
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == NULL) {
            //解析JSon数据
                NSMutableArray *dict =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            for (int i = 0; i < [dict count]; i++) {
            CategoryModel *model = [CategoryModel modelWithName:(NSString *)dict[i][@"CategoryName"] categoryIcon:dict[i][@"CategoryIcon"]];
                [DataArray addObject:model];
                NSLog(@"%@",(NSString *)dict[i][@"CategoryName"]);
            }
            //在主线程更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self UpdateDataInSql:DataArray];
                //[self InitNutrientDataFromServer];
            });
        }else{
            NSLog(@"加载内容失败");
        }
        }];
        //5、执行请求
        [dataTask resume];
    NSLog(@"!!!!!!!!!!!!!");
}

- (void)InitNutrientDataFromServer{
    NSLog(@"@@@@@@@@@@@@@@@");
    //服务器地址
    NSString *serverAddr;
    serverAddr = [NSString stringWithFormat:@"http://192.168.3.109/fosa/GetAllNutrientDataFromServer.php"];
    //serverAddr = [NSString stringWithFormat:@"http://192.168.43.21/fosa/GetServerDataByCategory.php?category=%@",self.category];
    serverAddr = [serverAddr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"#%^{}\"[]|\\<> "].invertedSet];
    NSLog(@"%@",serverAddr);
    NSURL *url = [NSURL URLWithString:serverAddr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 2.0; //设置请求超时为4秒
    //4、创建get请求
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            //解析JSon数据
            self->dict =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                              //NSLog(@"%@",(NSString *)dict[0][@"CategoryName"]);
            //NSLog(@"%@",self->dict);
            for (NSInteger i = 0; i < self->dict.count; i++) {
                [self->arrayData addObject:self->dict[i]];
            }
            //在主线程更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                [self insertDataIntoNutrient];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self SystemAlert:@"请求数据失败，请刷新网络"];
            });
        }
        }];
        //5、执行请求
        [dataTask resume];
    NSLog(@"!!!!!!!!!!!!!");
}
//弹出系统提示
- (void)SystemAlert:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notification" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
}

- (void)UpdateDataInSql:(NSMutableArray<CategoryModel *> *)DataArray{
    //sqlite3_stmt *stmt;
    self.database = [SqliteManager InitSqliteWithName:@"Fosa.db"];
    //创建Nutrient数据库表
       NSString *creatCategorySql = @"create table if not exists Category(id integer ,CategoryName text,CategoryImg text,UNIQUE(CategoryName))";
       [SqliteManager InitTableWithName:creatCategorySql database:_database];//创建数据表
       for (NSInteger i = 0; i < DataArray.count; i++) {
           NSString *InsertCategory = [NSString stringWithFormat:@"replace into Category(CategoryName,CategoryImg)values('%@','%@')",DataArray[i].cagegoryName,DataArray[i].categoryImg];
           [SqliteManager InsertDataIntoTable:InsertCategory database:_database];
       }
}
//插入数据
- (void)insertDataIntoNutrient{
    NSString *creatNutrientTable = @"create table if not exists Nutrient(id integer primary key,foodName text,Category text,Calorie text,Protein text,Fat text,Carbohydrate text,DietaryFiber text,Cholesterin text,Ca text,Mg text,Fe text,Zn text,K text,VitaminC text,VitaminE text,VitaminA text,Carotene text)";
    [SqliteManager InitTableWithName:creatNutrientTable database:self.database];// 创建营养表
    for (NSInteger i = 0; i < arrayData.count; i++) {
         NSString *InsertData = [NSString stringWithFormat:@"Insert into Nutrient(foodName,Category,Calorie,Protein,Fat,Carbohydrate,DietaryFiber ,Cholesterin,Ca,Mg,Fe,Zn,K,VitaminC,VitaminE,VitaminA,Carotene)values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",arrayData[i][@"FoodName"],arrayData[i][@"Category"],arrayData[i][@"Calorie(Kcal)"],arrayData[i][@"Protein(g)"],arrayData[i][@"Fat(g)"],arrayData[i][@"Carbohydrate(g)"],arrayData[i][@"DietaryFiber(g)"],arrayData[i][@"Cholesterin(mg)"],arrayData[i][@"Ca(mg)"],arrayData[i][@"Mg(mg)"],arrayData[i][@"Fe(mg)"],arrayData[i][@"Zn(mg)"],arrayData[i][@"K(mg)"],arrayData[i][@"VitaminC(mg)"],arrayData[i][@"VitaminE(mg)"],arrayData[i][@"VitaminA(mcg)"],arrayData[i][@"Carotene(mcg)"]];
        [SqliteManager InsertDataIntoTable:InsertData database:self.database];
    }
}
@end
