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

#import "SqliteManager.h"

#import "FoodListViewController.h"
@interface CategoryViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>{
    NSMutableArray<CategoryModel *> *DataArray;
    NSString *ID;
}
@property (nonatomic,assign) sqlite3 *database;
@property (nonatomic,assign) sqlite3_stmt *stmt;
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
    [self SelectCategoryTableOrUpdate];
    //[self InitDataFromServer];
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
    
    self.CategoryView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 1.5*navheight+statusHeight, mainWidth, 4*mainWidth/3) collectionViewLayout:layout];
    self.CategoryView.contentSize = CGSizeMake(mainWidth, 2*mainHeight);
    _CategoryView.alwaysBounceVertical = YES;
    _CategoryView.showsVerticalScrollIndicator = NO;
    //regist the user-defined collctioncell
    [_CategoryView registerClass:[CategoryCollectionViewCell class] forCellWithReuseIdentifier:ID];
    self.CategoryView.backgroundColor = [UIColor whiteColor];
    self.CategoryView.delegate =  self;
    self.CategoryView.dataSource = self;
    [self.view addSubview:self.CategoryView];
}
//
//- (void)InitDataFromServer{
//    NSLog(@"@@@@@@@@@@@@@@@");
//    //服务器地址
//    //NSString *serverAddr = @"http://192.168.3.110/fosa/HttpComunication.php";
//    NSString *serverAddr = @"http://192.168.43.21/fosa/HttpComunication.php";
//
//    NSURL *url = [NSURL URLWithString:serverAddr];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    //4、创建get请求
//    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//            //解析JSon数据
//            NSMutableArray *dict =  [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
//                    NSLog(@"%@",(NSString *)dict[0][@"CategoryName"]);
//            for (int i = 0; i < [dict count]; i++) {
//                CategoryModel *model = [CategoryModel modelWithName:(NSString *)dict[i][@"CategoryName"] categoryIcon:dict[i][@"CategoryIcon"]];
//                    [self->DataArray addObject:model];
//                }
//            for (int i = 0; i < [self->DataArray count]; i++) {
//                NSLog(@"%@----%@",self->DataArray[i].cagegoryName,self->DataArray[i].categoryImg);
//            }
//        //在主线程更新UI
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self.CategoryView reloadData];
//            [self CreatNutrientDataBase];
//        });
//        }];
//        //5、执行请求
//        [dataTask resume];
//    NSLog(@"!!!!!!!!!!!!!");
//}
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
    foodlist.category = cell.categoryLabel.text;
    foodlist.categoryicon = DataArray[cell.tag].categoryImg;
    foodlist.foodType = cell.tag;
    foodlist.current = self.current;
    [self.navigationController pushViewController:foodlist animated:YES];
    
}
#pragma mark - 本地数据库
//- (void)CreatNutrientDataBase{
//    //创建Nutrient数据库表
//    NSString *creatCategorySql = @"create table if not exists Category(id integer primary key,CategoryName text,CategoryImg text)";
//    [SqliteManager InitTableWithName:creatCategorySql database:_database];//创建数据表
//    for (NSInteger i = 0; i < DataArray.count; i++) {
//        NSString *InsertCategory = [NSString stringWithFormat:@"insert into Category(CategoryName,CategoryImg)values('%@','%@')",DataArray[i].cagegoryName,DataArray[i].categoryImg];
//        [SqliteManager InsertDataIntoTable:InsertCategory database:self.database];
//    }
//}
- (void)SelectCategoryTableOrUpdate{
    DataArray = [[NSMutableArray alloc]init];
    // 打开数据库
    self.database = [SqliteManager InitSqliteWithName:@"Fosa.db"];
    
    NSString *selectCategory = [NSString stringWithFormat:@"Select CategoryName,CategoryImg from Category"];
    //int result = [SqliteManager SelectFromTable:selectNutrient database:_database stmt:_stmt];
    _stmt = [SqliteManager SelectDataFromTable:selectCategory database:self.database];
    if (_stmt != NULL) {
        while (sqlite3_step(_stmt) == SQLITE_ROW) {
            NSLog(@"我从数据库查询食物种类！！！！");
            const char * categoryname = (const char *)sqlite3_column_text(_stmt, 0);
            const char * categoryImg = (const char *)sqlite3_column_text(_stmt, 1);
            CategoryModel *model = [[CategoryModel alloc]initWithName:[NSString stringWithUTF8String:categoryname] categoryIcon:[NSString stringWithUTF8String:categoryImg]];
            NSLog(@">>>>>>>>%@<<<<<<<<<<<<%@",[NSString stringWithUTF8String:categoryname],[NSString stringWithUTF8String:categoryImg]);
            [DataArray addObject:model];
            
        }
        [self.CategoryView reloadData];
    }else{
        NSLog(@"本地数据库为空，要到服务器上面找");
//        [self InitDataFromServer];
    }
}
@end
