//
//  NutrientViewController.m
//  FOSA
//
//  Created by hs on 2019/12/5.
//  Copyright © 2019 hs. All rights reserved.
//

#import "NutrientViewController.h"
#import "NutrientModel.h"

@interface NutrientViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray<NutrientModel *> *NutrientData;
    NSMutableArray *dict;
    NSArray *array;
}
@end

@implementation NutrientViewController
#define mainWidth [UIScreen mainScreen].bounds.size.width
#define mainHeight [UIScreen mainScreen].bounds.size.height
#define navheight  self.navigationController.navigationBar.frame.size.height
#define statusHeight [[UIApplication sharedApplication] statusBarFrame].size.height

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self InitData];
    [self InitNutrientDataFromServer];
    [self InitHeader];
    [self InitNutrientTable];
}
- (void)InitData{
    array = @[@"Calorie(Kcal)",@"Protein(g)",@"Fat(g)",@"Carbohydrate(g)",@"DietaryFiber(g)",@"Cholesterin(mg)",@"Ca(mg)",@"Mg(mg)",@"Fe(mg)",@"Zn(mg)",@"K(mg)",@"VitaminC(mg)",@"VitaminE(mg)",@"VitaminA(µg)",@"carotene(µg)"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_done"] style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.rightBarButtonItem.target = self; self.navigationItem.rightBarButtonItem.action = @selector(finish);
}
- (void)finish{
    NSLog(@"%ld",(long)self.current);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:NutrientData[0].content forKey:@"calorieValue"];
    [defaults synchronize];
    
    //返回根界面
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)InitNutrientDataFromServer{
    NSLog(@"@@@@@@@@@@@@@@@");
       NutrientData = [[NSMutableArray alloc]init];
       //服务器地址
       NSString *serverAddr;
       serverAddr = [NSString stringWithFormat:@"http://192.168.3.110/fosa/GetServerDataByFoodName.php?food=%@&foodkind=%@",self.food,self.foodkind];
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
               NSLog(@"%@",self->dict);
               NSString *temp;
               for (NSInteger i = 0; i < self->array.count; i++) {
                   temp = self->array[i];
                   NutrientModel *model = [[NutrientModel alloc]initWithName:temp content:self->dict[0][temp]];
                   [self->NutrientData addObject:model];
               }
               //在主线程更新UI
               dispatch_async(dispatch_get_main_queue(), ^{
                   [self.nutrientList reloadData];
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
- (void)InitHeader{
    self.Header = [[UIView alloc]initWithFrame:CGRectMake(0, navheight+statusHeight, mainWidth, 3*navheight)];
    _Header.backgroundColor = [UIColor colorWithRed:0/255.0 green:249/255.0 blue:116/255.0 alpha:1.0];
    [self.view addSubview:_Header];
    
    self.categoryIcon = [[UIImageView alloc]initWithFrame:CGRectMake(navheight, navheight/2, navheight, navheight)];
    self.categoryIcon.backgroundColor = [UIColor whiteColor];
    _categoryIcon.layer.cornerRadius = navheight/2;
    _categoryIcon.image = [UIImage imageNamed:self.foodicon];
    [self.Header addSubview:_categoryIcon];
    
    self.foodNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(navheight*2.5, navheight/2, navheight*1.5, navheight)];
    _foodNameLabel.text = self.food;
    _foodNameLabel.textAlignment = NSTextAlignmentCenter;
    [self.Header addSubview:_foodNameLabel];
    self.tips = [[UILabel alloc]initWithFrame:CGRectMake(0, navheight*2, mainWidth, navheight)];
    _tips.text = @"每100g所含营养成分参考值";
    [self.Header addSubview:_tips];
}
- (void)InitNutrientTable{
    self.nutrientList = [[UITableView alloc]initWithFrame:CGRectMake(0, 4*navheight+statusHeight, mainWidth, mainHeight) style:UITableViewStylePlain];
    _nutrientList.delegate = self;
    _nutrientList.dataSource = self;
    //_foodList.hidden = YES;
    _nutrientList.showsVerticalScrollIndicator = NO;
    [_nutrientList setSeparatorColor:[UIColor grayColor]];
    [self.view addSubview:_nutrientList];
}

//行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}
//每组多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NutrientData.count;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    //cell.backgroundColor = [UIColor redColor];
    NSInteger row = indexPath.row;
    cell.textLabel.text = NutrientData[row].NutritionalIngredient;
    cell.detailTextLabel.text = NutrientData[row].content;
    //取消点击cell时显示的背景色
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //返回cell
    return cell;
}
//弹出系统提示
- (void)SystemAlert:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notification" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }]];
    [self presentViewController:alert animated:true completion:nil];
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
