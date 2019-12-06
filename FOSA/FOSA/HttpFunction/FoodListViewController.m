//
//  FoodListViewController.m
//  FOSA
//
//  Created by hs on 2019/12/3.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FoodListViewController.h"
#import "NutrientViewController.h"

@interface FoodListViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *arrayData;
    NSMutableArray *dict;
    NSDictionary *nutrientData;
}

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
    [self InitDataFromServer];
    [self InitFoodListView];
}

- (void)InitDataFromServer{
    NSLog(@"@@@@@@@@@@@@@@@");
    //self.foodType = @"";
    arrayData = [[NSMutableArray alloc]init];
    //服务器地址
    NSString *serverAddr;
    switch (self.foodType) {
        case 0:
            NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%ld",self.foodType);
            serverAddr = @"http://192.168.3.110/fosa/HttpSelectCereal.php";
            break;
        case 1:
            NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%ld",self.foodType);
            serverAddr = @"http://192.168.3.110/fosa/HttpSelectCereal.php";
            break;
        case 2:
            NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%ld",self.foodType);
            serverAddr = @"http://192.168.3.110/fosa/HttpSelectMeat.php";
            break;
        case 3:
            NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%ld",self.foodType);
            serverAddr = @"http://192.168.3.110/fosa/HttpSelectCereal.php";
            break;
        case 4:
            NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%ld",self.foodType);
            serverAddr = @"http://192.168.3.110/fosa/HttpSelectCereal.php";
            break;
        case 5:
            NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%ld",self.foodType);
            serverAddr = @"http://192.168.3.110/fosa/HttpSelectFruit.php";
            break;
        case 6:
            NSLog(@"!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!%ld",self.foodType);
            serverAddr = @"http://192.168.3.109/fosa/HttpSelectCereal.php";
            break;
        default:
            break;
    }
    NSURL *url = [NSURL URLWithString:serverAddr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //4、创建get请求
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            //解析JSon数据
        self->dict =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                    //NSLog(@"%@",(NSString *)dict[0][@"CategoryName"]);
        NSLog(@"%@",self->dict);
        
        for (NSInteger i = 0; i < self->dict.count; i++) {
            [self->arrayData addObject:self->dict[i]];
        }
        for (NSInteger j = 0; j < self->arrayData.count; j++) {
            NSLog(@"$$$$$$$$$$$%@",self->arrayData[j][@"protein"]);
        }
           
        //在主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.foodList reloadData];
        });
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
    NSLog(@"%ld",arrayData.count);
    return arrayData.count;
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
    cell.textLabel.text = arrayData[row][@"foodName"];
    
    //取消点击cell时显示的背景色
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //添加点击手势
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cellAction:)];
    recognizer.view.tag = row;
    [cell addGestureRecognizer:recognizer];
    //返回cell
    return cell;
}

- (void)cellAction:(UITapGestureRecognizer *)sender{
    NSLog(@"%@",arrayData[sender.view.tag][@"protein"]);
    NutrientViewController *nutrient = [[NutrientViewController alloc]init];
    nutrient.nutrientData = [[NSMutableArray alloc]init];
    nutrient.nutrientData = arrayData[sender.view.tag];
    NSLog(@"%@",nutrient.nutrientData);
    //[self.navigationController pushViewController:nutrient animated:YES];
    
}
@end
