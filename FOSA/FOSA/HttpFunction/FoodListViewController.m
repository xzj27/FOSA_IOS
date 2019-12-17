//
//  FoodListViewController.m
//  FOSA
//
//  Created by hs on 2019/12/3.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FoodListViewController.h"
#import "NutrientViewController.h"
#import "SqliteManager.h"

@interface FoodListViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *arrayData;
    NSMutableArray<NSString *> *nameArray;
    NSMutableArray *dict;
    NSDictionary *nutrientData;
}
@property (nonatomic,assign) sqlite3 *database;
@property (nonatomic,assign) sqlite3_stmt *stmt;
@end

@implementation FoodListViewController

#define mainWidth [UIScreen mainScreen].bounds.size.width
#define mainHeight [UIScreen mainScreen].bounds.size.height
#define navheight  self.navigationController.navigationBar.frame.size.height
#define statusHeight [[UIApplication sharedApplication] statusBarFrame].size.height

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self InitFoodListView];
    [self SelectDataFromNutrient];
}

- (void)InitDataFromServer{
    NSLog(@"@@@@@@@@@@@@@@@");
    //服务器地址
    NSString *serverAddr;
    serverAddr = [NSString stringWithFormat:@"http://192.168.3.109/fosa/GetServerDataByCategory.php?category=%@",self.category];
    //serverAddr = [NSString stringWithFormat:@"http://192.168.43.21/fosa/GetServerDataByCategory.php?category=%@",self.category];
    serverAddr = [serverAddr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet characterSetWithCharactersInString:@"#%^{}\"[]|\\<> "].invertedSet];
    NSLog(@"%@",serverAddr);
    NSURL *url = [NSURL URLWithString:serverAddr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.timeoutInterval = 4.0; //设置请求超时为4秒
    //4、创建get请求
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error == nil) {
            //解析JSon数据
            self->dict =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                              //NSLog(@"%@",(NSString *)dict[0][@"CategoryName"]);
            NSLog(@"%@",self->dict);
            for (NSInteger i = 0; i < self->dict.count; i++) {
                [self->arrayData addObject:self->dict[i]];
                [self->nameArray addObject:self->dict[i][@"FoodName"]];
                //NSLog(@"<><><><><><><>%@",self->arrayData[i]);
            }
            
            //在主线程更新UI
            dispatch_async(dispatch_get_main_queue(), ^{
                 NSLog(@"&&&&&&&&&&&&");
                [self.foodList reloadData];
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

- (void)InitFoodListView{
    self.foodList = [[UITableView alloc]initWithFrame:CGRectMake(0, 2*navheight+statusHeight, mainWidth, mainHeight) style:UITableViewStylePlain];
    _foodList.delegate = self;
    _foodList.dataSource = self;
    //_foodList.hidden = YES;
    _foodList.showsVerticalScrollIndicator = NO;
    [_foodList setSeparatorColor:[UIColor grayColor]];
    [self.view addSubview:_foodList];
}
//行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
//每组多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return nameArray.count;
}
//多少组
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

//每行显示的内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cell";
    //初始化cell，并指定其类型
    UITableViewCell *cell = [tableView  dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        //创建cell
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    //cell.backgroundColor = [UIColor redColor];
    NSInteger row = indexPath.row;
    cell.textLabel.text = nameArray[row];
    //取消点击cell时显示的背景色
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //添加点击手势
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cellAction:)];
    recognizer.accessibilityValue = nameArray[row];
    [cell addGestureRecognizer:recognizer];
    //返回cell
    return cell;
}

- (void)cellAction:(UITapGestureRecognizer *)sender{
    NSLog(@"%@",sender.accessibilityValue);
    NutrientViewController *nutrient = [[NutrientViewController alloc]init];
    nutrient.food = sender.accessibilityValue;
    nutrient.foodkind = self.category;
    nutrient.foodicon = self.categoryicon;
    nutrient.current = self.current;
    [self.navigationController pushViewController:nutrient animated:YES];
    
   
}
//弹出系统提示
- (void)SystemAlert:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notification" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:true completion:nil];
}
//查找数据
- (void)SelectDataFromNutrient{
    //初始化数组
    arrayData = [[NSMutableArray alloc]init];
    nameArray = [[NSMutableArray alloc]init];
    
    self.database = [SqliteManager InitSqliteWithName:@"Fosa.db"]; //open database
    
    NSString *selectsql = [NSString stringWithFormat:@"select foodName from Nutrient where Category = '%@'",self.category];
    
    _stmt = [SqliteManager SelectDataFromTable:selectsql database:self.database];
     if (_stmt != NULL) {
            while (sqlite3_step(_stmt) == SQLITE_ROW) {
                NSLog(@"我从手机数据库查询到食物");
                const char *foodname = (const char *) sqlite3_column_text(_stmt, 0);
                NSLog(@"%@",[NSString stringWithUTF8String:foodname]);
                [nameArray addObject:[NSString stringWithUTF8String:foodname]];
            }
         [self.foodList reloadData];
        }
        
    if (nameArray.count == 0) {
            NSLog(@"本地数据库为空，要到服务器上面找");
            [self InitDataFromServer];
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
