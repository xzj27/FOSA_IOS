//
//  CategoryViewController.m
//  FOSA
//
//  Created by hs on 2019/12/2.
//  Copyright © 2019 hs. All rights reserved.
//

#import "CategoryViewController.h"
#import "CategoryModel.h"
#import "CategoryCollectionViewCell.h"

#import "FoodListViewController.h"
@interface CategoryViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    NSMutableArray<CategoryModel *> *DataArray;
    NSString *ID;
}

@end

@implementation CategoryViewController
#define mainWidth [UIScreen mainScreen].bounds.size.width
#define mainHeight [UIScreen mainScreen].bounds.size.height
#define navheight  self.navigationController.navigationBar.frame.size.height
#define statusHeight [[UIApplication sharedApplication] statusBarFrame].size.height
/**随机颜色*/
#define RandomColor ([UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0])


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    
    [self InitDataFromServer];
    [self InitView];
}

- (void)InitView{
    ID = @"CategoryCell";
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self InitDataFromServer];
//    });
    NSLog(@"**********");
    NSLog(@"%f",navheight);
    
    //初始化Layout
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    [layout setScrollDirection:(UICollectionViewScrollDirectionVertical)];
    layout.itemSize = CGSizeMake((mainWidth-15)/2,mainWidth/3-5);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    layout.sectionInset = UIEdgeInsetsMake(5, 5, 0, 5);
    
    self.CategoryView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 1.5*navheight+statusHeight, mainWidth, mainHeight) collectionViewLayout:layout];
    _CategoryView.showsVerticalScrollIndicator = NO;
    //regist the user-defined collctioncell
    [_CategoryView registerClass:[CategoryCollectionViewCell class] forCellWithReuseIdentifier:ID];
    self.CategoryView.backgroundColor = [UIColor whiteColor];
    self.CategoryView.delegate =  self;
    self.CategoryView.dataSource = self;
    [self.view addSubview:self.CategoryView];
}

- (void)InitDataFromServer{
    NSLog(@"@@@@@@@@@@@@@@@");
    DataArray = [[NSMutableArray alloc]init];
    //服务器地址
    NSString *serverAddr = @"http://192.168.3.109/fosa/HttpComunication.php";
    
    NSURL *url = [NSURL URLWithString:serverAddr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //4、创建get请求
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            //解析JSon数据
            NSMutableArray *dict =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                    //NSLog(@"%@",(NSString *)dict[0][@"CategoryName"]);
            for (int i = 0; i < [dict count]; i++) {
                CategoryModel *model = [CategoryModel modelWithName:(NSString *)dict[i][@"CategoryName"] categoryIcon:dict[i][@"CategoryIcon"]];
                    [self->DataArray addObject:model];
                }
            for (int i = 0; i < [self->DataArray count]; i++) {
                NSLog(@"%@----%@",self->DataArray[i].cagegoryName,self->DataArray[i].categoryImg);
            }
        //在主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.CategoryView reloadData];
        });
        }];
        //5、执行请求
        [dataTask resume];
    NSLog(@"!!!!!!!!!!!!!");
}
#pragma mark - UICollectionViewDataSource
//每个section有几个item
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSLog(@"!!!!!!!!!!!!!!!!!!!%lu",(unsigned long)[DataArray count]);
    return [DataArray count];
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
    CategoryCollectionViewCell *cell = [self.CategoryView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    //给自定义cell的model传值
    long int index = indexPath.section*2+indexPath.row;
    [cell setModel:DataArray[index]];
    //cell.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0 blue:arc4random()%255/255.0 alpha:1];
    cell.backgroundColor = [UIColor colorWithRed:155/255.0 green:251/255.5 blue:241/255.0 alpha:1.0];
    cell.layer.cornerRadius = 10;
    cell.userInteractionEnabled = YES;
    cell.tag = index;
    return cell;
}
//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //获取点击的cell
    CategoryCollectionViewCell *cell = (CategoryCollectionViewCell *)[self collectionView:_CategoryView cellForItemAtIndexPath:indexPath];
    [self SelectFoodDetail:cell];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

//点击效果
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    CategoryCollectionViewCell *cell = (CategoryCollectionViewCell *)[_CategoryView cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = [UIColor lightGrayColor];
    NSLog(@"%@",cell.model.cagegoryName);
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    CategoryCollectionViewCell *cell = (CategoryCollectionViewCell *)[_CategoryView cellForItemAtIndexPath:indexPath];
      cell.backgroundColor = [UIColor colorWithRed:155/255.0 green:251/255.5 blue:241/255.0 alpha:1.0];
}

- (void)SelectFoodDetail:(CategoryCollectionViewCell *)cell{
    NSLog(@"%ld",(long)cell.tag);
    FoodListViewController *foodlist = [[FoodListViewController alloc]init];
    foodlist.foodType = cell.tag;
    [self.navigationController pushViewController:foodlist animated:YES];
}

@end
