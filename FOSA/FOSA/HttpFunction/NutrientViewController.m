//
//  NutrientViewController.m
//  FOSA
//
//  Created by hs on 2019/12/5.
//  Copyright © 2019 hs. All rights reserved.
//

#import "NutrientViewController.h"

@interface NutrientViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation NutrientViewController
#define mainWidth [UIScreen mainScreen].bounds.size.width
#define mainHeight [UIScreen mainScreen].bounds.size.height
#define navheight  self.navigationController.navigationBar.frame.size.height
#define statusHeight [[UIApplication sharedApplication] statusBarFrame].size.height

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor yellowColor];
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>%@",self.nutrientData);
}

- (void)InitNutrientTable{
    self.nutrientList = [[UITableView alloc]initWithFrame:CGRectMake(0, 2*navheight+statusHeight, mainWidth, mainHeight) style:UITableViewStylePlain];
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
    //NSLog(@"%ld",arrayData.count);
    return self.nutrientData.count;
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
    //cell.textLabel.text = _nutrientData[@"calorie"];
    
    //取消点击cell时显示的背景色
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //添加点击手势
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cellAction:)];
    recognizer.view.tag = row;
    [cell addGestureRecognizer:recognizer];

    //返回cell
    return cell;
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
