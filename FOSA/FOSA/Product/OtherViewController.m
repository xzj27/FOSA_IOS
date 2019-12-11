//
//  OtherViewController.m
//  FOSA
//
//  Created by hs on 2019/11/15.
//  Copyright © 2019 hs. All rights reserved.
//

#import "OtherViewController.h"

@interface OtherViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSArray *arrayData;
}
@end
#define RandomColor ([UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0])
@implementation OtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self InitDeviceView];
}

- (void)initData{
    arrayData = @[@"FOSA1",@"FOSA2",@"FOSA3",@"FOSA4",@"FOSA5"];
}
- (void)InitDeviceView{
    self.mainWidth = [UIScreen mainScreen].bounds.size.width;
    self.mainHeight = [UIScreen mainScreen].bounds.size.height;
    self.navheight = self.navigationController.navigationBar.frame.size.height;
    
    //device menu
    self.deviceTable = [[UITableView alloc]initWithFrame:CGRectMake(0,_navheight, _mainWidth/4, _mainHeight-_navheight-5) style:UITableViewStylePlain];
    self.deviceTable.delegate = self;
    self.deviceTable.dataSource = self;
    self.deviceTable.showsVerticalScrollIndicator = NO;
    [self.deviceTable setSeparatorColor:[UIColor grayColor]];
    [self.view addSubview:self.deviceTable];

    //content
    self.contentView = [[UIView alloc]initWithFrame:CGRectMake(self.mainWidth/4,0, self.mainWidth*3/4, self.mainHeight-_navheight-5)];
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.contentView];
}

//行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.deviceTable.frame.size.height)/7;
}
//每组多少行
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    //取消点击cell时显示的背景色
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.text = arrayData[indexPath.row];
    //返回cell
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //获取点击的cell
     UITableViewCell * cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%@",cell.textLabel.text);
    self.contentView.backgroundColor = RandomColor;
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
