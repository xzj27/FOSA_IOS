//
//  ProductViewController.m
//  FOSAapp1.0
//
//  Created by hs on 2019/12/30.
//  Copyright © 2019 hs. All rights reserved.
//
/**
 目前还存在数组越界问题
 */
#import "ProductViewController.h"
#import "device/DeviceCollectionViewCell.h"

@interface ProductViewController ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    NSArray *arrayData;
    NSArray *array1,*array2,*array3,*array4,*array5;
    NSMutableArray<NSString *> *fosaDataSource,*myDeviceSource;
    NSString *fosaDeviceID,*myDeviceID;
    NSInteger index;//当前滚动的位置
}
//@property (nonatomic,strong) NSArray *array1,*array2,*array3,*array4,*array5;
//@property (nonatomic,strong) NSMutableArray<NSString *> *fosaDataSource,*myDeviceSource;

@end

@implementation ProductViewController

#pragma mark - 延迟加载
- (UIView *)header{
    if (_header == nil) {
        _header = [[UIView alloc]init];
    }
    return _header;
}

- (UIView *)productCategoryView{
    if (_productCategoryView == nil) {
        _productCategoryView = [[UIView alloc]init];
    }
    return _productCategoryView;
}

- (UIView *)productView{
    if (_productView == nil) {
        _productView = [[UIView alloc]init];
    }
    return _productView;
}

- (UIView *)titleView{
    if (_titleView == nil) {
        _titleView = [[UIView alloc]init];
    }
    return _titleView;
}
- (UIButton *)fosa{
    if (_fosa == nil) {
        _fosa = [[UIButton alloc]init];
    }
    return _fosa;
}

- (UIButton *)myFosa{
    if (_myFosa == nil) {
        _myFosa = [[UIButton alloc]init];
    }
    return _myFosa;
}

- (UISearchBar *)searchBar{
    if (_searchBar == nil) {
        _searchBar = [[UISearchBar alloc]init];
    }
    return _searchBar;
}

- (UITableView *)productCategory{
    if (_productCategory == nil) {
        _productCategory = [[UITableView alloc]init];
    }
    return _productCategory;
}

- (UIScrollView *)mainScrollView{
    if (_mainScrollView == nil) {
        _mainScrollView = [[UIScrollView alloc]init];
    }
    return _mainScrollView;
}
//- (NSArray *)array1{
//    if (_array1 == nil) {
//
//    }
//    return _array1;
//}
//- (NSArray *)array2{
//    if (_array2 == nil) {
//
//    }
//    return _array2;
//}
//- (NSArray *)array3{
//    if (_array3 == nil) {
//
//    }
//    return _array3;
//}
//- (NSArray *)array4{
//    if (_array4 == nil) {
//
//    }
//    return _array4;
//}
//- (NSArray *)array5{
//    if (_array5 == nil) {
//
//    }
//    return _array5;
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     self.view.backgroundColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:200/255.0 alpha:1.0];;
    [self CreatHeader];
    [self CreatProductCategoryTable];
    [self CreatProductCollection];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
    [self initData];
}

- (void)initData{
    arrayData = @[@"Bottles",@"Fresh bag",@"Thaw board",@"Vacuum",@"Sealer"];
    array1 = @[@"img_FOSARound0001",@"img_FOSARound0002",@"img_FOSARound0003",@"img_FOSARound0004",@"img_FOSASquare0001",@"img_FOSASquare0002",@"img_FOSASquare0003",@"img_FOSASquare0004",@"img_FOSASquare0005",@"img_FOSASquare0006",@"img_FOSASquare0007",@"img_FOSAJuice001",@"img_FOSAJuice001"]; //圆罐
    array2 = @[@"img_FOSASealer001",@"img_FOSASealer002",@"img_FOSASealer003"];       //
    array3 = @[@"img_FOSA003"];
    array4 = @[@"img_FOSA002"];
    array5 = @[@"img_FOSA001"];  //真空机
    fosaDataSource = [[NSMutableArray alloc]init];//默认选中1
    [self addObjectByArray:array1 target:fosaDataSource];
    myDeviceSource = [[NSMutableArray alloc]init];
    [self addObjectByArray:array1 target:myDeviceSource];
    
    fosaDeviceID = @"fosaDeviceCell";
    myDeviceID   = @"myDeviceCell";
}

- (void)CreatHeader{
    self.header.frame = CGRectMake(0, StatusBarH, screen_width,NavigationBarHeight);
    self.header.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1.0];
    [self.view addSubview:self.header];
    self.searchBar.frame = CGRectMake(0, 0, screen_width, NavigationBarHeight);
    self.searchBar.placeholder = @"Search";
    self.searchBar.delegate = self;
    [self.header addSubview:self.searchBar];
}

- (void)CreatProductCategoryTable{
    NSLog(@"%f---%f",screen_width,screen_height);
    self.productCategoryView.frame = CGRectMake(0, NavigationBarHeight+StatusBarH, screen_width/4, screen_height-NavigationBarHeight-TabbarHeight);
    self.productCategoryView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.productCategoryView];
    self.productCategory.frame = CGRectMake(0, 0, self.productCategoryView.frame.size.width, self.productCategoryView.frame.size.height*2/3);
    self.productCategory.delegate = self;
    self.productCategory.dataSource = self;
    self.productCategory.bounces = NO;
    self.productCategory.showsVerticalScrollIndicator = NO;
    [self.productCategoryView addSubview:self.productCategory];
}

- (void)CreatProductCollection{
    fosaDeviceID = @"fosaDeviceCell";
    myDeviceID   = @"myDeviceCell";
    self.productView.frame = CGRectMake(screen_width/4+0.5, NavigationBarHeight+StatusBarH, screen_width*3/4-0.5, screen_height-NavigationBarHeight-TabbarHeight);
    self.productView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.productView];
    
    // 添加标题视图
    self.titleView.frame = CGRectMake(10, 10, self.productView.frame.size.width-20, 40);
    self.titleView.layer.borderWidth = 1;
    self.titleView.layer.cornerRadius = 10;
    self.titleView.backgroundColor = [UIColor whiteColor];
    [self.productView addSubview:self.titleView];
    // 添加标题按钮
    self.fosa.frame = CGRectMake(0, 0, self.productView.frame.size.width/2-10, 40);
    [self.fosa setTitle:@"FOSA" forState:UIControlStateNormal];
    [self.fosa setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [self.fosa setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self setCornerOnLeft:10 view:self.fosa];
    [self.fosa addTarget:self action:@selector(switchDevice:) forControlEvents:UIControlEventTouchUpInside];
    self.fosa.tag = 0;
    self.fosa.backgroundColor = FOSAgreen;  //默认选中；
    
    self.myFosa.frame = CGRectMake(self.productView.frame.size.width/2-10, 0, self.productView.frame.size.width/2-10, 40);
    [self.myFosa setTitle:@"My Device" forState:UIControlStateNormal];
    [self.myFosa setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.myFosa setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    self.myFosa.clipsToBounds = YES;
    [self setCornerOnRight:10 view: self.myFosa];
    [self.myFosa addTarget:self action:@selector(switchDevice:) forControlEvents:UIControlEventTouchUpInside];
    self.myFosa.tag = 1;
    self.myFosa.backgroundColor = [UIColor whiteColor];
    
    [self.titleView addSubview:self.fosa];
    [self.titleView addSubview:self.myFosa];
    
    self.mainScrollView.frame = CGRectMake(0,55, self.productView.frame.size.width, self.productView.frame.size.height-55);
    self.mainScrollView.delegate = self;
    self.mainScrollView.pagingEnabled = YES;
    self.mainScrollView.showsHorizontalScrollIndicator = NO;
    self.mainScrollView.showsVerticalScrollIndicator = NO;
    [self.productView addSubview:self.mainScrollView];
    
//    //layout
    CGFloat scrollerWidth = self.mainScrollView.frame.size.width;
    CGFloat scrollerHeight = self.mainScrollView.frame.size.height;
    
    UICollectionViewFlowLayout *fosaFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    fosaFlowLayout.minimumLineSpacing = 5;  //行间距
    fosaFlowLayout.minimumInteritemSpacing = 5; //列间距
    fosaFlowLayout.itemSize = CGSizeMake((scrollerWidth-20)/3, (scrollerWidth-20)/3); //固定的itemsize
    fosaFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;//滑动的方向 垂直
    
    UICollectionViewFlowLayout *myFlowLayout = [[UICollectionViewFlowLayout alloc] init];
    myFlowLayout.minimumLineSpacing = 5;  //行间距
    myFlowLayout.minimumInteritemSpacing = 5; //列间距
    myFlowLayout.itemSize = CGSizeMake((scrollerWidth-20)/3, (scrollerWidth-20)/3);; //固定的itemsize
    myFlowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;//滑动的方向 垂直

    //fosaDevice
    self.fosaProductCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, scrollerWidth, scrollerHeight) collectionViewLayout:fosaFlowLayout];
    self.fosaProductCollection.backgroundColor = [UIColor whiteColor];
    self.fosaProductCollection.delegate = self;
    self.fosaProductCollection.dataSource = self;
    self.fosaProductCollection.showsVerticalScrollIndicator = NO;
    self.fosaProductCollection.bounces = NO;
    [self.fosaProductCollection registerClass:[DeviceCollectionViewCell class] forCellWithReuseIdentifier:fosaDeviceID];   //注册cell
    [self.mainScrollView addSubview:self.fosaProductCollection];


    self.myProductCollection = [[UICollectionView alloc]initWithFrame:CGRectMake(scrollerWidth, 0, scrollerWidth, scrollerHeight) collectionViewLayout:myFlowLayout];
    self.myProductCollection.backgroundColor = [UIColor whiteColor];
    self.myProductCollection.delegate = self;
    self.myProductCollection.dataSource = self;
    self.myProductCollection.showsVerticalScrollIndicator = NO;
    self.myProductCollection.bounces = NO;
    [self.myProductCollection registerClass:[DeviceCollectionViewCell class] forCellWithReuseIdentifier:myDeviceID];   //注册cell
    [self.mainScrollView addSubview:self.myProductCollection];

    self.mainScrollView.contentSize = CGSizeMake(scrollerWidth*2, 0);
}
#pragma mark - UISearchBarDelegate
//将要开始编辑时的回调，返回为NO，则不能编辑
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    return YES;
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    self.searchBar.showsCancelButton = YES;
    NSLog(@"begin");
}
//已经结束编辑的回调
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    NSLog(@"end");
    [searchBar resignFirstResponder];
}
//点击搜索按钮的回调
- (void)searchBarSearchButtonClicked:(UISearchBar* )searchBar{
    NSLog(@"%@",searchBar.text);
    [searchBar resignFirstResponder];
    searchBar.showsCancelButton = NO;
}
//点击取消按钮的回调
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
     self.searchBar.showsCancelButton = NO;
    NSLog(@"cancel");
    [searchBar resignFirstResponder];
}
#pragma mark - UITableViewDelegate
//行高度
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return (self.productCategoryView.frame.size.height)/8;
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
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    //取消点击cell时显示的背景色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont systemFontOfSize:13*(([UIScreen mainScreen].bounds.size.width/414.0))];
    cell.textLabel.highlightedTextColor = FOSAgreen;
    cell.textLabel.text = arrayData[indexPath.row];
    
    //cell.textLabel.textAlignment = NSTextAlignmentCenter;
    //返回cell
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"当前点击第%ld行",(long)indexPath.row);
    [self.searchBar resignFirstResponder];
    self.searchBar.showsCancelButton = NO;
    switch (indexPath.row) {
        case 0:
            [self switchProductCategoryByArray:array1];
            break;
        case 1:
            [self switchProductCategoryByArray:array2];
            break;
        case 2:
            [self switchProductCategoryByArray:array3];
            break;
        case 3:
            [self switchProductCategoryByArray:array4];
            break;
        case 4:
            [self switchProductCategoryByArray:array5];
            break;
        default:
            break;
    }
    //获取点击的cell
     UITableViewCell * cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = FOSAgreen;
    NSLog(@"%@",cell.textLabel.text);
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.textColor = [UIColor blackColor];
}

- (void)switchProductCategoryByArray:(NSArray *)array{
    if (index == 0) {
        [self addObjectByArray:array target:fosaDataSource];
        NSLog(@"fosaProduct:%@",fosaDataSource);
        [self.fosaProductCollection reloadData];
    }else if(index == 1){
        [self addObjectByArray:array target:myDeviceSource];
        NSLog(@"myDevice:%@",myDeviceSource);
        [self.myProductCollection reloadData];
    }
}

- (void)addObjectByArray:(NSArray *)array target:(NSMutableArray<NSString *> *)tarray{
    [tarray removeAllObjects];
    for (int i = 0; i < array.count; i++) {
        [tarray addObject:array[i]];
    }
}
- (void)switchDevice:(id)sender{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag == 0) {
        [self.mainScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        self.fosa.backgroundColor = FOSAgreen;
        self.myFosa.backgroundColor = [UIColor whiteColor];
        index = 0;
    }else if(btn.tag == 1){
        index = 1;
        [self.mainScrollView setContentOffset:CGPointMake(self.mainScrollView.frame.size.width, 0) animated:YES];
        self.myFosa.backgroundColor = FOSAgreen;
        self.fosa.backgroundColor = [UIColor whiteColor];
    }
}
#pragma mark - UIScrollerViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat offset = scrollView.contentOffset.x;
    index = offset/self.mainScrollView.frame.size.width;
    NSLog(@"%ld",(long)index);
    if (index == 0) {
        self.fosa.backgroundColor = FOSAgreen;
        self.myFosa.backgroundColor = [UIColor whiteColor];
    }else if(index == 1){
        self.myFosa.backgroundColor = FOSAgreen;
        self.fosa.backgroundColor = [UIColor whiteColor];
    }
}
#pragma mark - UICollectionViewDataSource

//每个section有几个item
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([collectionView isEqual:self.fosaProductCollection]) {
        NSLog(@"===========%lu",(unsigned long)fosaDataSource.count);
        return fosaDataSource.count;
    }else if([collectionView isEqual:self.myProductCollection]){
        NSLog(@"<<<<<<<<<<<<%lu",(unsigned long)myDeviceSource.count);
        return myDeviceSource.count;
    }else{
        return 0;
    }
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
    if ([collectionView isEqual:self.fosaProductCollection]) {
        DeviceCollectionViewCell *cell = [self.fosaProductCollection dequeueReusableCellWithReuseIdentifier:fosaDeviceID forIndexPath:indexPath];
        NSInteger index = indexPath.row;
        NSLog(@"fosaProduct>>>>>>>>>>>>%ld----------fosaDataSource:%lu",(long)index,fosaDataSource.count);
        cell.productImageView.image = [UIImage imageNamed:fosaDataSource[index]];
        cell.layer.cornerRadius = 5;
        return cell;
    }else{
        DeviceCollectionViewCell *cell = [self.myProductCollection dequeueReusableCellWithReuseIdentifier:myDeviceID forIndexPath:indexPath];
        NSInteger index = indexPath.row;
        NSLog(@"myProduct<<<<<<<<<<<<<<<<%ld-----------MyProductDatasource:%lu",(long)index,myDeviceSource.count);
        cell.productImageView.image = [UIImage imageNamed:myDeviceSource[index]];
        cell.layer.cornerRadius = 5;
        return cell;
    }
}
//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //获取点击的cell
     [self.searchBar resignFirstResponder];
    self.searchBar.showsCancelButton = NO;
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

//点击效果
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    if (index == 0) {
        DeviceCollectionViewCell *cell = (DeviceCollectionViewCell *)[self.fosaProductCollection cellForItemAtIndexPath:indexPath];
        cell.backgroundColor = [UIColor lightGrayColor];
    }else if (index == 1){
        DeviceCollectionViewCell *cell = (DeviceCollectionViewCell *)[self.myProductCollection cellForItemAtIndexPath:indexPath];
        cell.backgroundColor = [UIColor lightGrayColor];
    }
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{

    if (index == 0) {
        DeviceCollectionViewCell *cell = (DeviceCollectionViewCell *)[self.fosaProductCollection cellForItemAtIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
    }else if (index == 1){
        DeviceCollectionViewCell *cell = (DeviceCollectionViewCell *)[self.myProductCollection cellForItemAtIndexPath:indexPath];
        cell.backgroundColor = [UIColor whiteColor];
    }
}
//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 0, 5);
}

//#pragma mark -设置圆角
///*设置顶部圆角*/
//- (void)setCornerOnTop:(CGFloat )cornerRadius {
//    UIBezierPath *maskPath;
//    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
//                                     byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
//                                           cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = self.bounds;
//    maskLayer.path = maskPath.CGPath;
//    self.layer.mask = maskLayer;
//}
///*设置底部圆角*/
//- (void)setCornerOnBottom:(CGFloat )cornerRadius {
//    UIBezierPath *maskPath;
//    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
//                                     byRoundingCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)
//                                           cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = self.bounds;
//    maskLayer.path = maskPath.CGPath;
//    self.layer.mask = maskLayer;
//}
/*设置左边圆角*/
- (void)setCornerOnLeft:(CGFloat )cornerRadius view:(UIButton *)button{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds
                                     byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerBottomLeft)
                                           cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = button.bounds;
    maskLayer.path = maskPath.CGPath;
    button.layer.mask = maskLayer;
}
/*设置右边圆角*/
- (void)setCornerOnRight:(CGFloat )cornerRadius view:(UIButton *)button{
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:button.bounds
                                     byRoundingCorners:(UIRectCornerTopRight | UIRectCornerBottomRight)
                                           cornerRadii:CGSizeMake(cornerRadius, cornerRadius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = button.bounds;
    maskLayer.path = maskPath.CGPath;
    button.layer.mask = maskLayer;
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.searchBar resignFirstResponder];
    self.searchBar.showsCancelButton = NO;
}
/**隐藏底部横条，点击屏幕可显示*/
- (BOOL)prefersHomeIndicatorAutoHidden{
    return YES;
}
@end
