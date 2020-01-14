//
//  MyDeviceViewController.m
//  FOSA
//
//  Created by hs on 2019/11/15.
//  Copyright © 2019 hs. All rights reserved.
//

#import "MyDeviceViewController.h"
#import "productCollectionViewCell.h"

@interface MyDeviceViewController ()<UITableViewDelegate,UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    NSArray *arrayData;
    NSArray *array1,*array2,*array3,*array4,*array5,*DataSource;
    NSString *ID;
}

@end
#define RandomColor ([UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0])
@implementation MyDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
    [self InitDeviceView];
}
- (void)initData{
    arrayData = @[@"保鲜袋",@"圆罐",@"方罐",@"果汁罐",@"真空机"];
    array1 = @[@"Img_sealer001",@"Img_sealer002",@"Img_sealer003"]; //保鲜袋
    array2 = @[@"Img_FOSA001",@"Img_FOSA002",@"Img_FOSA003"];       //圆罐
    array3 = @[@"Img_FOSA004",@"Img_FOSA005",@"Img_FOSA006",@"Img_FOSA007",@"Img_FOSA008",@"Img_FOSA009"];//方罐
    array4 = @[@"Img_FOSA010",@"Img_FOSA011",@"Img_FOSA012"];//果汁罐
    array5 = @[@"Img_FOSA013",@"Img_FOSA014",@"Img_FOSA015",@"Img_FOSA016",@"Img_FOSA017",@"Img_FOSA018"];  //真空机
    DataSource = array1;    //默认选中1
    ID = @"ProductCell";
}
- (void)InitDeviceView{
    self.mainWidth = [UIScreen mainScreen].bounds.size.width;
    self.mainHeight = [UIScreen mainScreen].bounds.size.height;
    self.navheight = self.navigationController.navigationBar.frame.size.height;
    
    //device menu
    self.deviceTable = [[UITableView alloc]initWithFrame:CGRectMake(0,_navheight, _mainWidth/5, _mainHeight-_navheight-5) style:UITableViewStylePlain];
    self.deviceTable.delegate = self;
    self.deviceTable.dataSource = self;
    self.deviceTable.showsVerticalScrollIndicator = NO;
    [self.deviceTable setSeparatorColor:[UIColor grayColor]];
    [self.view addSubview:self.deviceTable];
    //content
    CGFloat contentWidth = self.mainWidth*3/4;
    CGFloat contentHeight = self.mainHeight-_navheight-5;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 5;  //行间距
    flowLayout.minimumInteritemSpacing = 5; //列间距
    //flowLayout.estimatedItemSize = CGSizeMake((contentWidth-15)/2, (contentWidth-15)/2);  //预定的itemsize
    flowLayout.itemSize = CGSizeMake((contentWidth-20)/2, (contentWidth-15)/2);; //固定的itemsize
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;//滑动的方向 垂直
    //self.contentView = [[UICollectionView alloc]initWithFrame:CGRectMake(self.mainWidth/4,0, self.mainWidth*3/4, self.mainHeight-_navheight-5)];
    self.contentView = [[UICollectionView alloc]initWithFrame:CGRectMake(self.mainWidth/4,0, contentWidth, contentHeight) collectionViewLayout:flowLayout];
    self.contentView.delegate = self;
    self.contentView.dataSource = self;
    self.contentView.showsVerticalScrollIndicator = NO;
    self.contentView.backgroundColor = [UIColor whiteColor];
    [self.contentView registerClass:[productCollectionViewCell class] forCellWithReuseIdentifier:ID];   //注册cell
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
    cell.textLabel.font = [UIFont systemFontOfSize:14*(([UIScreen mainScreen].bounds.size.width/414.0))];
    cell.textLabel.text = arrayData[indexPath.row];
    //返回cell
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"当前点击第%ld行",(long)indexPath.row);
    switch (indexPath.row) {
        case 0:
            DataSource = array1;
            break;
        case 1:
            DataSource = array2;
            break;
        case 2:
            DataSource = array3;
            break;
        case 3:
            DataSource = array4;
            break;
        case 4:
            DataSource = array5;
            break;
        default:
            break;
    }
    //获取点击的cell
     UITableViewCell * cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    NSLog(@"%@",cell.textLabel.text);
    //self.contentView.backgroundColor = RandomColor;
    [self.contentView reloadData];
}

#pragma mark - UICollectionViewDataSource

//每个section有几个item
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return DataSource.count;
}
//collectionView有几个section
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
//返回这个UICollectionViewCell是否可以被选择
- ( BOOL )collectionView:( UICollectionView *)collectionView shouldSelectItemAtIndexPath:( NSIndexPath *)indexPath{
    return YES ;
}
//每个cell的具体内容
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:( NSIndexPath *)indexPath {
    productCollectionViewCell *cell = [self.contentView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    NSInteger index = indexPath.row;
    cell.productImageView.image = [UIImage imageNamed:DataSource[index]];
    cell.layer.cornerRadius = 5;
        return cell;
}
//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //获取点击的cell
    
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//点击效果
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    productCollectionViewCell *cell = (productCollectionViewCell *)[_contentView cellForItemAtIndexPath:indexPath];
       cell.backgroundColor = [UIColor lightGrayColor];
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    productCollectionViewCell *cell = (productCollectionViewCell *)[_contentView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
}
//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 0, 5);
}
@end
