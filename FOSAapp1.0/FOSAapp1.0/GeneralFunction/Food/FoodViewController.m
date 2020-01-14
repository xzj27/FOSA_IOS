//
//  FoodViewController.m
//  FOSAapp1.0
//
//  Created by hs on 2020/1/3.
//  Copyright © 2020 hs. All rights reserved.
//

#import "FoodViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "FosaDatePickerView.h"
#import "foodKindCollectionViewCell.h"
#import "FMDB.h"
#import "FoodModel.h"

@interface FoodViewController ()<UIScrollViewDelegate,UITextFieldDelegate,UITextViewDelegate,UNUserNotificationCenterDelegate,FosaDatePickerViewDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>{
    NSString *aboutFoodTips;
    NSMutableArray<NSString *> *categoryArray;
    NSString *kindID;
    Boolean isRemindOrExpire;
    NSString *docPath;
    NSString *selectedKind;
    CGFloat keyBoardHeight,keyBoardWidth;
    CGFloat editingViewHeight;
    CGPoint clickPoint;
    /**查看具体信息时的参数*/
    Boolean isEdit;
}
//日期选择器
@property (nonatomic,weak) FosaDatePickerView *fosaDatePicker;
@property (nonatomic,strong) FMDatabase *db;
// 当前获取焦点的UITextField
@property (strong, nonatomic) UITextField *currentResponderTextField;

@end

@implementation FoodViewController

#pragma mark -- 懒加载属性
- (UIButton *)finishAndEdit{
    if (_finishAndEdit == nil) {
        _finishAndEdit = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 40, 40)];
    }
    return _finishAndEdit;
}
- (UIScrollView *)rootScrollerView{
    if (_rootScrollerView == nil) {
        _rootScrollerView = [[UIScrollView alloc]init];
    }
    return _rootScrollerView;
}
- (UIView *)headerView{
    if (_headerView == nil) {
        _headerView = [[UIView alloc]init];
    }
    return _headerView;
}
- (UIScrollView *)pictureScrollerView{
    if (_pictureScrollerView == nil) {
        _pictureScrollerView = [[UIScrollView alloc]init];
    }
    return _pictureScrollerView;
}
- (UIPageControl *)pageControl{
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc]init];
    }
    return _pageControl;
}
/**foodInfo*/
- (UIView *)foodInfoView{
    if (_foodInfoView == nil) {
        _foodInfoView = [[UIView alloc]init];
    }
    return _foodInfoView;
}
- (UITextField *)foodNameInput{
    if (_foodNameInput == nil) {
        _foodNameInput = [[UITextField alloc]init];
    }
    return _foodNameInput;
}
- (UIButton *)shareBtn{
    if (_shareBtn == nil) {
        _shareBtn = [[UIButton alloc]init];
    }
    return _shareBtn;
}
- (UIButton *)likeBtn{
    if (_likeBtn == nil) {
        _likeBtn = [[UIButton alloc]init];
    }
    return _likeBtn;
}
- (UITextView *)aboutFoodInput{
    if (_aboutFoodInput == nil) {
        _aboutFoodInput = [[UITextView alloc]init];
    }
    return _aboutFoodInput;
}
- (UILabel *)numberLable{
    if (_numberLable == nil) {
        _numberLable = [[UILabel alloc]init];
    }
    return _numberLable;
}
/**Date*/
- (UIView *)DateView{
    if (_DateView == nil) {
        _DateView = [[UIView alloc]init];
    }
    return _DateView;
}

- (UIButton *)remindBtn{
    if (_remindBtn == nil) {
        _remindBtn = [[UIButton alloc]init];
    }
    return _remindBtn;
}
- (UIButton *)expireBtn{
    if (_expireBtn == nil) {
        _expireBtn = [[UIButton alloc]init];
    }
    return _expireBtn;
}
- (UILabel *)remindLable{
    if (_remindLable == nil) {
        _remindLable = [[UILabel alloc]init];
    }
    return _remindLable;
}
- (UILabel *)remindDateLable{
    if (_remindDateLable == nil) {
        _remindDateLable = [[UILabel alloc]init];
    }
    return _remindDateLable;
}
- (UILabel *)expireLable{
    if (_expireLable == nil) {
        _expireLable = [[UILabel alloc]init];
    }
    return _expireLable;
}
- (UILabel *)expireDateLable{
    if (_expireDateLable == nil) {
        _expireDateLable = [[UILabel alloc]init];
    }
    return _expireDateLable;
}
/**storageView*/
- (UIView *)storageView{
    if (_storageView == nil) {
        _storageView = [[UIView alloc]init];
    }
    return _storageView;
}

- (UIView *)weightView{
    if (_weightView == nil) {
        _weightView = [[UIView alloc]init];
    }
    return _weightView;
}

- (UIView *)calorieView{
    if (_calorieView == nil) {
        _calorieView = [[UIView alloc]init];
    }
    return _calorieView;
}
- (UIButton *)locationbtn{
    if (_locationbtn == nil) {
        _locationbtn = [[UIButton alloc]init];
    }
    return _locationbtn;
}
- (UIButton *)weightBtn{
    if (_weightBtn == nil) {
        _weightBtn = [[UIButton alloc]init];
    }
    return _weightBtn;
}
- (UIButton *)calorieBtn{
    if (_calorieBtn == nil) {
        _calorieBtn = [[UIButton alloc]init];
    }
    return _calorieBtn;
}
- (UITextField *)weightField{
    if (_weightField == nil) {
        _weightField = [[UITextField alloc]init];
    }
    return _weightField;
}
- (UITextField *)locationField{
    if (_locationField == nil) {
        _locationField = [[UITextField alloc]init];
    }
    return _locationField;
}
- (UITextField *)calorieField{
    if (_calorieField == nil) {
        _calorieField = [[UITextField alloc]init];
    }
    return _calorieField;
}
- (UILabel *)locationLable{
    if (_locationLable == nil) {
        _locationLable = [[UILabel alloc]init];
    }
    return _locationLable;
}
- (UILabel *)weightLable{
    if (_weightLable == nil) {
        _weightLable = [[UILabel alloc]init];
    }
    return _weightLable;
}
- (UILabel *)calorieLable{
    if (_calorieLable == nil) {
        _calorieLable = [[UILabel alloc]init];
    }
    return _calorieLable;
}
- (UILabel *)weightUnit{
    if (_weightUnit == nil) {
        _weightUnit = [[UILabel alloc]init];
    }
    return _weightUnit;
}
- (UILabel *)calorieUnit{
    if (_calorieUnit == nil) {
        _calorieUnit = [[UILabel alloc]init];
    }
    return _calorieUnit;
}
/**分类*/
//adding
- (UIView *)categoryView{
    if (_categoryView == nil) {
        _categoryView = [[UIView alloc]init];
    }
    return _categoryView;
}
- (UIButton *)categoryBtn{
    if (_categoryBtn == nil) {
        _categoryBtn = [[UIButton alloc]init];
    }
    return _categoryBtn;
}
//info
- (UIView *)showCategoryView{
    if (_showCategoryView == nil) {
        _showCategoryView = [[UIView alloc]init];
    }
    return _showCategoryView;
}
- (UILabel *)categoryTitleLable{
    if (_categoryTitleLable == nil) {
        _categoryTitleLable = [[UILabel alloc]init];
    }
    return _categoryTitleLable;
}
- (UILabel *)categoryLable{
    if (_categoryLable == nil) {
        _categoryLable = [[UILabel alloc]init];
    }
    return _categoryLable;
}



#pragma mark - 初始化日期选择器
-(void)InitialDatePicker{
    FosaDatePickerView *DatePicker = [[FosaDatePickerView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 300)];
    DatePicker.delegate = self;
    DatePicker.title = @"请选择时间";
    [self.view addSubview:DatePicker];
    self.fosaDatePicker = DatePicker;
    self.fosaDatePicker.hidden = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self CreatMainAddFoodView];
    [self InitialDatePicker];
}

- (void)viewWillAppear:(BOOL)animated{
    //添加键盘弹出与收回的事件
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)InitData{
    NSArray *array = @[@"Cereal",@"Fruit",@"Meat",@"Vegetable",@"Spice"];
    categoryArray = [[NSMutableArray alloc]initWithArray:array];
    kindID = @"kindCell";
    clickPoint = CGPointZero;
    //isRemindOrExpire
}

#pragma mark -- 主创建视图
- (void)CreatMainAddFoodView{
    [self InitData];
    aboutFoodTips = @"You can make some description about your food which will be storaged in the device of FOSA in this text area";
    
    UITapGestureRecognizer *tapGr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTappedToCloseKeyBoard:)];
    tapGr.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGr];
    self.view.backgroundColor = [UIColor whiteColor];
    
    //导航栏按钮
    self.finishAndEdit = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, NavigationBarHeight, NavigationBarHeight)];
    if (self.isAdding) {
        [self.finishAndEdit setImage:[UIImage imageNamed:@"icon_done"]forState:UIControlStateNormal];
        [self.finishAndEdit addTarget:self action:@selector(finishAdding) forControlEvents:UIControlEventTouchUpInside];
    }else{
        [self.finishAndEdit setImage:[UIImage imageNamed:@"icon_edit"]forState:UIControlStateNormal];
        [self.finishAndEdit addTarget:self action:@selector(editInfo) forControlEvents:UIControlEventTouchUpInside];
    }
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:self.finishAndEdit];
       self.navigationItem.rightBarButtonItem= rightItem;
    //底部滚动根视图
    self.rootScrollerView.frame = self.view.bounds;
    [self.view addSubview:self.rootScrollerView];
    //头部视图
    [self creatPicturePlayer];
    //食品信息视图
    [self CreatFoodInfoView];
    //日期
    [self CreatDateView];
    //存储
    [self CreatStorageView];
    //种类栏
    [self CreatCategoryView];
    
    [self prohibitEdit];
}
/**创建图片轮播器*/
- (void)creatPicturePlayer{
    //头部视图
    self.headerView.frame = CGRectMake(0, 0, screen_width, screen_height/3);
    int headerWidth = self.headerView.frame.size.width;
    int headerHeight = self.headerView.frame.size.height;
    NSLog(@"headerWidth:%d-------headerheight:%d",headerWidth,headerHeight);
    [self.rootScrollerView addSubview:self.headerView];
    //食物图片轮播器
    self.pictureScrollerView.frame = CGRectMake(0, 0, headerWidth, headerHeight);
    self.pictureScrollerView.pagingEnabled = YES;
    self.pictureScrollerView.delegate = self;
    self.pictureScrollerView.showsHorizontalScrollIndicator = NO;
    self.pictureScrollerView.bounces = NO;
    self.pictureScrollerView.contentSize = CGSizeMake(headerWidth*3, headerHeight);
    for (int i = 0; i < 3; i++) {
        CGRect frame = CGRectMake(i*headerWidth, 0, headerWidth, headerHeight);
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:frame];
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.clipsToBounds = YES;
        imgView.image = self.food_image[i];
        [self.pictureScrollerView addSubview:imgView];
    }
    [self.headerView addSubview:self.pictureScrollerView];
    //轮播页面指示器
    self.pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(headerWidth/3, headerHeight-30, headerWidth/3, 20)];
    self.pageControl.currentPage = 0;
    self.pageControl.numberOfPages = 3;
    self.pageControl.pageIndicatorTintColor = [UIColor redColor];
    self.pageControl.currentPageIndicatorTintColor = [UIColor greenColor];
    [self.headerView addSubview:self.pageControl];
}
/**食品信息*/
- (void)CreatFoodInfoView{
    //食物信息视图
    self.foodInfoView.frame = CGRectMake(screen_width/15, CGRectGetMaxY(self.headerView.frame), screen_width*13/15, screen_height/6);
    int foodInfoViewWidth = self.foodInfoView.frame.size.width;
    int foodinfoViewHeight = self.foodInfoView.frame.size.height;
    NSLog(@"headerWidth:%d-------headerheight:%d",foodInfoViewWidth,foodinfoViewHeight);
    //self.foodInfoView.backgroundColor = [UIColor whiteColor];
    [self.rootScrollerView addSubview:self.foodInfoView];
    //食物名称输入框
    self.foodNameInput.frame = CGRectMake(0, foodinfoViewHeight/15, foodInfoViewWidth*2/3, foodinfoViewHeight/3);
    self.foodNameInput.backgroundColor = FOSAFoodBackgroundColor;
    self.foodNameInput.layer.cornerRadius = 5;
    [self.foodNameInput setValue:[NSNumber numberWithInt:10] forKey:@"paddingLeft"];//设置输入文本的起始位置
    self.foodNameInput.font = [UIFont systemFontOfSize:15];
    
    self.foodNameInput.returnKeyType = UIReturnKeyDone;
    self.foodNameInput.delegate = self;
    
    
    NSMutableAttributedString *placeholder = [[NSMutableAttributedString alloc] initWithString:@"  FOSA"];
     //[placeholder addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0, @"  FOSA".length)];
     [placeholder addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:25] range:NSMakeRange(0, @"  FOSA".length)];
    self.foodNameInput.attributedPlaceholder = placeholder;
    
    [self.foodInfoView addSubview:self.foodNameInput];
    //分享按钮
    self.shareBtn.frame = CGRectMake(foodInfoViewWidth*2/3+foodinfoViewHeight/5, foodinfoViewHeight*2/15, foodinfoViewHeight/5, foodinfoViewHeight/5);
    [self.shareBtn setBackgroundImage:[UIImage imageNamed:@"icon_share"] forState:UIControlStateNormal];
    [self.foodInfoView addSubview:self.shareBtn];
    
    self.likeBtn.frame = CGRectMake(foodInfoViewWidth*2/3+foodinfoViewHeight/2, foodinfoViewHeight*2/15, foodinfoViewHeight/5, foodinfoViewHeight/5);
    [self.likeBtn setBackgroundImage:[UIImage imageNamed:@"icon_like"] forState:UIControlStateNormal];
    [self.foodInfoView addSubview:self.likeBtn];
    //食物描述框
    self.aboutFoodInput.frame = CGRectMake(0, foodinfoViewHeight*7/15, foodInfoViewWidth, foodinfoViewHeight/2);
    // 设置提醒内容的大小和颜色
    if (_isAdding) {
        self.aboutFoodInput.text = aboutFoodTips;
    }
    self.aboutFoodInput.textColor = [UIColor lightGrayColor];
    self.aboutFoodInput.font = [UIFont systemFontOfSize:14*(screen_width/414.0)];
    self.aboutFoodInput.layer.cornerRadius = 5;
    self.aboutFoodInput.delegate = self;
    self.aboutFoodInput.returnKeyType = UIReturnKeyNext;
    self.aboutFoodInput.backgroundColor = FOSAFoodBackgroundColor;
    self.aboutFoodInput.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [self.foodInfoView addSubview:self.aboutFoodInput];
    //输入字数限制与提醒
    int aboutFoodInputWidth = self.aboutFoodInput.frame.size.width;
    int aboutFoodInputHeight = self.aboutFoodInput.frame.size.height;
    self.numberLable.frame = CGRectMake(aboutFoodInputWidth*5/6, aboutFoodInputHeight*3/4, aboutFoodInputWidth/6, aboutFoodInputHeight/4);
    self.numberLable.font = [UIFont systemFontOfSize:14*(screen_width/414.0)];
    self.numberLable.text = [NSString stringWithFormat:@"%lu/80",(unsigned long)self.aboutFoodInput.text.length];
    self.numberLable.textColor = [UIColor grayColor];
    self.numberLable.textAlignment = 2;
    [self.aboutFoodInput addSubview:self.numberLable];
    
    UIView *diveLine = [[UIView alloc]initWithFrame:CGRectMake(0, foodinfoViewHeight-0.5, foodInfoViewWidth, 0.5)];
    diveLine.backgroundColor = [UIColor grayColor];
    [self.foodInfoView addSubview:diveLine];
}
/**日期 */
- (void)CreatDateView{
    self.DateView.frame = CGRectMake(screen_width/15, CGRectGetMaxY(self.foodInfoView.frame), screen_width*13/15, screen_height/7);
    int dateViewWidth = self.DateView.frame.size.width;
    int dateViewHeight = self.DateView.frame.size.height;
    [self.rootScrollerView addSubview:self.DateView];
    
    //提醒日期
    self.remindBtn.frame = CGRectMake(0, dateViewHeight*3/20, dateViewWidth*1/10, dateViewWidth*1/10);
    [self.remindBtn setBackgroundImage:[UIImage imageNamed:@"icon_remindDate"] forState:UIControlStateNormal];
    //添加点击事件
    //[self.remindBtn addTarget:self action:@selector(RemindDateSelect) forControlEvents:UIControlEventTouchUpInside];
    [self.DateView addSubview:self.remindBtn];
    
    self.remindLable.frame = CGRectMake(dateViewWidth*8/66, dateViewHeight*3/20, dateViewWidth/2-dateViewWidth*8/66, dateViewWidth*1/10);
    self.remindLable.font = [UIFont systemFontOfSize:15*(screen_width/414.0)];
    self.remindLable.text = @"Remind Date";
    self.remindLable.textColor = [UIColor blackColor];
    [self.DateView addSubview:self.remindLable];
    
    self.remindDateLable.frame = CGRectMake(dateViewWidth/2, dateViewHeight*3/20, dateViewWidth/2, dateViewWidth*1/10);
    self.remindDateLable.layer.cornerRadius = dateViewHeight*3/20;
    self.remindDateLable.layer.backgroundColor = FOSAFoodBackgroundColor.CGColor;
    self.remindDateLable.textAlignment = NSTextAlignmentCenter;
    
    self.remindDateLable.userInteractionEnabled = YES;
    UITapGestureRecognizer *clickToOpenRemindDatePicker = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(RemindDateSelect)];
    [self.remindDateLable addGestureRecognizer:clickToOpenRemindDatePicker];
    
    [self.DateView addSubview:self.remindDateLable];
    
    //过期日期
    self.expireBtn.frame = CGRectMake(0, dateViewHeight*11/20, dateViewWidth*1/10, dateViewWidth*1/10);
    [self.expireBtn setBackgroundImage:[UIImage imageNamed:@"icon_expireDate"] forState:UIControlStateNormal];
    [self.DateView addSubview:self.expireBtn];
    
    self.expireLable.frame = CGRectMake(dateViewWidth*8/66, dateViewHeight*11/20, dateViewWidth/2-dateViewWidth*8/66, dateViewWidth*1/10);
    self.expireLable.font = [UIFont systemFontOfSize:15*(screen_width/414.0)];
    self.expireLable.text = @"Expire Date";
    self.expireLable.textColor = [UIColor blackColor];
    [self.DateView addSubview:self.expireLable];
    
    self.expireDateLable.frame = CGRectMake(dateViewWidth/2, dateViewHeight*11/20, dateViewWidth/2, dateViewWidth*1/10);
    self.expireDateLable.layer.backgroundColor = FOSAFoodBackgroundColor.CGColor;
    self.expireDateLable.layer.cornerRadius = dateViewHeight*3/20;
    self.expireDateLable.textAlignment = NSTextAlignmentCenter;
    
    self.expireDateLable.userInteractionEnabled = YES;
    UITapGestureRecognizer *clickToOpenExpireDatePicker = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(ExpireDateSelect)];
    [self.expireDateLable addGestureRecognizer:clickToOpenExpireDatePicker];
    [self.DateView addSubview:self.expireDateLable];
    
    UIView *diveLine = [[UIView alloc]initWithFrame:CGRectMake(0, dateViewHeight-0.5, dateViewWidth, 0.5)];
    diveLine.backgroundColor = [UIColor grayColor];
    [self.DateView addSubview:diveLine];
}
/**存储*/
- (void)CreatStorageView{
    self.storageView.frame = CGRectMake(screen_width/15, CGRectGetMaxY(self.DateView.frame), screen_width*13/15, screen_height/6);
    [self.rootScrollerView addSubview:self.storageView];
    int storageViewWidth = self.storageView.frame.size.width;
    int storageViewHeight = self.storageView.frame.size.height;
    //location
    //self.remindBtn.frame = CGRectMake(0, dateViewHeight*3/20, dateViewHeight*3/10, dateViewHeight*3/10);
    self.locationbtn.frame = CGRectMake(0, storageViewHeight/20, storageViewWidth/10, storageViewWidth/10);
    [self.locationbtn setBackgroundImage:[UIImage imageNamed:@"icon_location"] forState:UIControlStateNormal];
    [self.storageView addSubview:self.locationbtn];
    
    self.locationLable.frame = CGRectMake(storageViewWidth*8/66, storageViewHeight/20, storageViewWidth/3-storageViewWidth*8/66, storageViewWidth/10);
    self.locationLable.font = [UIFont systemFontOfSize:15*(screen_width/414.0)];
    self.locationLable.text = @"Location";
    [self.storageView addSubview:self.locationLable];
    
    self.locationField.frame = CGRectMake(storageViewWidth/3, storageViewHeight/20, storageViewWidth*2/3, storageViewWidth/10);
    self.locationField.font = [UIFont systemFontOfSize:15*(screen_width/414.0)];
    self.locationField.layer.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0].CGColor;
    self.locationField.layer.cornerRadius = self.locationField.frame.size.height/4;
    self.locationField.returnKeyType = UIReturnKeyDone;
    self.locationField.delegate = self;
    [self.storageView addSubview:self.locationField];
    
    self.weightBtn.frame = CGRectMake(0, storageViewWidth/10+storageViewHeight/20, storageViewWidth/10, storageViewWidth/10);
    [self.weightBtn setImage:[UIImage imageNamed:@"icon_weight"] forState:UIControlStateNormal];
    [self.storageView addSubview:self.weightBtn];
    self.weightLable.frame = CGRectMake(storageViewWidth*8/66, storageViewWidth/10+storageViewHeight/20, storageViewWidth/3, storageViewWidth/10);
    self.weightLable.text = @"Weight";
    self.weightLable.font = [UIFont systemFontOfSize: 15*(screen_width/414.0)];
    [self.storageView addSubview:self.weightLable];
    
    self.calorieBtn.frame = CGRectMake(storageViewWidth*5/9, storageViewWidth/10+storageViewHeight/20, storageViewWidth/10, storageViewWidth/10);
    //self.calorieBtn.backgroundColor = FOSARed;
    [self.calorieBtn setImage:[UIImage imageNamed:@"icon_calorie"] forState:UIControlStateNormal];
    [self.storageView addSubview:self.calorieBtn];
    
    self.calorieLable.frame = CGRectMake(storageViewWidth*8/66+storageViewWidth*5/9, storageViewWidth/10+storageViewHeight/20, storageViewWidth/3, storageViewWidth/10);
    self.calorieLable.text = @"Calorie";
    self.calorieLable.font = [UIFont systemFontOfSize:15*(screen_width/414.0)];
    [self.storageView addSubview:self.calorieLable];
    
    self.weightView.frame = CGRectMake(0, storageViewWidth/5+storageViewHeight/20, storageViewWidth*5/11, storageViewWidth/10);
    self.weightView.backgroundColor = FOSAFoodBackgroundColor;
    self.weightView.layer.cornerRadius = self.weightView.frame.size.height/2;
    [self.storageView addSubview:self.weightView];
    int weightViewWidth = self.weightView.frame.size.width;
    int weightViewHeight = self.weightView.frame.size.height;
    
    self.weightField.frame = CGRectMake(weightViewWidth/7, 0, weightViewWidth*5/7, weightViewHeight);
    self.weightField.returnKeyType = UIReturnKeyDone;
    self.weightField.delegate = self;
    [self.weightView addSubview:self.weightField];
    
    self.weightUnit.frame = CGRectMake(weightViewWidth*6/7, 0, weightViewWidth/7, weightViewHeight);
    self.weightUnit.text = @"g";
    self.weightUnit.font = [UIFont systemFontOfSize:15*(screen_width/414.0)];
    [self.weightView addSubview:self.weightUnit];
    
    self.calorieView.frame = CGRectMake(storageViewWidth*6/11, storageViewWidth/5+storageViewHeight/20, storageViewWidth*5/11, storageViewWidth/10);
    self.calorieView.backgroundColor = FOSAFoodBackgroundColor;
    self.calorieView.layer.cornerRadius = self.calorieView.frame.size.height/2;
    [self.storageView addSubview:self.calorieView];
    
    self.calorieField.frame = CGRectMake(weightViewWidth/7, 0, weightViewWidth*4/7, weightViewHeight);
    self.calorieField.returnKeyType = UIReturnKeyDone;
    self.calorieField.delegate = self;
    [self.calorieView addSubview:self.calorieField];
    
    self.calorieUnit.frame = CGRectMake(weightViewWidth*5/7, 0, weightViewWidth*2/7, weightViewHeight);
    self.calorieUnit.text = @"Kcal";
    self.calorieUnit.font = [UIFont systemFontOfSize: 15*(screen_width/414.0)];
    [self.calorieView addSubview:self.calorieUnit];
    
    UIView *diveLine = [[UIView alloc]initWithFrame:CGRectMake(0, storageViewHeight-0.5, storageViewWidth, 0.5)];
    diveLine.backgroundColor = FOSAFoodBackgroundColor;
    [self.storageView addSubview:diveLine];
}

- (void)CreatCategoryView{
    int categoryViewWidth = screen_width*13/15;
    int categoryViewHeight = (screen_height-CGRectGetMaxY(self.storageView.frame))/2;

    //adding
    self.categoryView.frame = CGRectMake(screen_width/15, CGRectGetMaxY(self.storageView.frame), categoryViewWidth, categoryViewHeight);
    self.categoryView.backgroundColor = [UIColor whiteColor];
    [self.rootScrollerView addSubview:self.categoryView];

       //种类视图
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    self.categoryContent = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, categoryViewWidth, categoryViewHeight/2) collectionViewLayout:flowLayout];
    
    self.categoryContent.backgroundColor = [UIColor whiteColor];
    self.categoryContent.delegate = self;
    self.categoryContent.dataSource = self;
    self.categoryContent.showsHorizontalScrollIndicator = NO;
    self.categoryContent.bounces = NO;
    [self.categoryContent registerClass:[foodKindCollectionViewCell class] forCellWithReuseIdentifier:kindID];
    [self.categoryView addSubview:self.categoryContent];
    
    //info
    self.showCategoryView.frame   = CGRectMake(screen_width/15, CGRectGetMaxY(self.storageView.frame), categoryViewWidth, categoryViewHeight);
    self.showCategoryView.backgroundColor = [UIColor whiteColor];
    [self.rootScrollerView addSubview:self.showCategoryView];
    
    self.categoryTitleLable.frame = CGRectMake(0, 0, categoryViewWidth/3, categoryViewHeight/2);
    self.categoryTitleLable.text  = @"Category:";
    self.categoryTitleLable.textColor = [UIColor blackColor];
    self.categoryTitleLable.font  = [UIFont systemFontOfSize:15*(screen_width/414)];
    [self.showCategoryView addSubview:self.categoryTitleLable];
    
    self.categoryLable.frame      = CGRectMake(categoryViewWidth/3, 0, categoryViewWidth/2, categoryViewHeight/2);
    self.categoryLable.backgroundColor = [UIColor whiteColor];
    self.categoryLable.textColor  = [UIColor blackColor];
    self.categoryLable.font       = [UIFont systemFontOfSize:(int)15*(screen_width/414)];
    [self.showCategoryView addSubview:self.categoryLable];
    
    if (_isAdding) {
        self.showCategoryView.hidden = YES;
    }else{
        self.categoryView.hidden = YES;
    }
}
#pragma mark -- 主视图按钮事件
- (void)finishAdding{
    [self SavephotosInSanBox:self.food_image];
    [self OpenSqlDatabase:@"FOSA"];
    [self CreatDataTable];
}
- (void)editInfo{
    if (isEdit) {
        //当前正在编辑，则停止编辑，保存信息
        isEdit = false;
        [self.finishAndEdit setImage:[UIImage imageNamed:@"icon_edit"] forState:UIControlStateNormal];
        self.foodNameInput.userInteractionEnabled   = NO;
        self.aboutFoodInput.userInteractionEnabled  = NO;
        self.remindDateLable.userInteractionEnabled = NO;
        self.expireDateLable.userInteractionEnabled = NO;
        self.locationField.userInteractionEnabled   = NO;
        self.weightField.userInteractionEnabled     = NO;
        self.calorieField.userInteractionEnabled    = NO;
        self.showCategoryView.hidden = NO;
        self.categoryView.hidden = YES;
        self.categoryLable.text = selectedKind;
    }else{
        //当前锁编辑，则允许编辑，修改信息
        isEdit = true;
        [self.finishAndEdit setImage:[UIImage imageNamed:@"icon_done"] forState:UIControlStateNormal];
        self.foodNameInput.userInteractionEnabled   = YES;
        self.aboutFoodInput.userInteractionEnabled  = YES;
        self.remindDateLable.userInteractionEnabled = YES;
        self.expireDateLable.userInteractionEnabled = YES;
        self.locationField.userInteractionEnabled   = YES;
        self.weightField.userInteractionEnabled     = YES;
        self.calorieField.userInteractionEnabled    = YES;
        self.showCategoryView.hidden = YES;
        self.categoryView.hidden     = NO;
    }
}
//选择过期日期
-(void)ExpireDateSelect{
    [self.aboutFoodInput resignFirstResponder];
    [self.foodNameInput resignFirstResponder];
    [self.locationField resignFirstResponder];
    [self.weightField resignFirstResponder];
    [self.calorieField resignFirstResponder];
    NSLog(@"select expire date");
    isRemindOrExpire = false;
    self.fosaDatePicker.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.fosaDatePicker.frame = CGRectMake(0, self.view.frame.size.height - 300, self.view.frame.size.width, 300);
        [self.fosaDatePicker show];
    }];
}
-(void)RemindDateSelect{
    
    [self.aboutFoodInput resignFirstResponder];
    [self.foodNameInput resignFirstResponder];
    [self.locationField resignFirstResponder];
    [self.weightField resignFirstResponder];
    [self.calorieField resignFirstResponder];
    
    isRemindOrExpire = true;
    NSLog(@"select reminding date");
    self.fosaDatePicker.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.fosaDatePicker.frame = CGRectMake(0, self.view.frame.size.height - 300, self.view.frame.size.width, 300);
        [self.fosaDatePicker show];
    }];
}
//锁编辑
- (void)prohibitEdit{
    if (!self.isAdding) {
        self.foodNameInput.userInteractionEnabled = NO;
        self.aboutFoodInput.userInteractionEnabled = NO;
        self.remindDateLable.userInteractionEnabled = NO;
        self.expireDateLable.userInteractionEnabled = NO;
        self.locationField.userInteractionEnabled = NO;
        self.weightField.userInteractionEnabled = NO;
        self.calorieField.userInteractionEnabled = NO;
    }
    if (self.infoArray.count != 0) {
        if ([self CheckFoodInfoWithName:self.infoArray[1] fdevice:self.infoArray[2]]) {
            [self SystemAlert:@"Food record missing,added or not"];
        }
        self.foodNameInput.text     = self.infoArray[1];
        self.device                 = self.infoArray[2];
        self.aboutFoodInput.text    = self.infoArray[3];
        self.remindDateLable.text   = self.infoArray[4];
        self.expireDateLable.text   = self.infoArray[5];
        self.categoryLable.text     = self.infoArray[6];
    }
}
#pragma mark -- UIScrollerView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    CGFloat offset = scrollView.contentOffset.x;
    NSInteger index = offset/self.headerView.frame.size.width;
    self.pageControl.currentPage = index;
}
#pragma mark -- 键盘事件
//点击键盘以外的地方退出键盘
-(void)viewTappedToCloseKeyBoard:(UITapGestureRecognizer*)tapGr{
    [self.aboutFoodInput resignFirstResponder];
    [self.foodNameInput resignFirstResponder];
    [self.locationField resignFirstResponder];
    [self.weightField resignFirstResponder];
    [self.calorieField resignFirstResponder];
}
//
//-(void)keyboardWillShow:(NSNotification *)noti{
//    NSLog(@"键盘弹出来了");
//    //获取键盘的高度
//        NSDictionary *userInfo = [noti userInfo];
//        NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//        CGRect keyboardRect = [aValue CGRectValue];
//        keyBoardHeight = keyboardRect.size.height;   //height 就是键盘的高度
//        keyBoardWidth = keyboardRect.size.width;     //width  键盘宽度
//    NSLog(@"%f-----%f",screen_height - editingViewHeight,keyBoardHeight);
//    NSLog(@"%f --- %f",clickPoint.y,screen_height-keyBoardHeight);
//        [UIView animateWithDuration:0.5 animations:^{
//            self.view.center = CGPointMake(self.rootScrollerView.center.x, screen_height/2-self->keyBoardHeight);
//            //[self.rootScrollerView setContentOffset:CGPointMake(0, self->keyBoardHeight/2)];
//        }];
//}
//-(void)keyboardWillHide:(NSNotification *)noti{
//    NSLog(@"键盘被收起来了");
//     [UIView animateWithDuration:0.5 animations:^{
//               self.view.center = CGPointMake(self.rootScrollerView.center.x, screen_height/2);
//               //[self.rootScrollerView setContentOffset:CGPointMake(0, -NavigationBarHeight)];
//           }];
//}
- (void)keyboardWillShow:(NSNotification *)notification {
    if (!(self.currentResponderTextField && [self.currentResponderTextField isKindOfClass:[UITextField class]])) {
        // 如果没有响应者不进行操作
        return;
    }
    //获取currentResponderTextField相对于self.view的frame信息
    CGRect rect = [self.currentResponderTextField.superview convertRect:self.currentResponderTextField.frame toView:self.view];
    //获取弹出键盘的frame的value值
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    //获取键盘相对于self.view的frame信息 ，传window和传nil是一样的
    keyboardRect = [self.view convertRect:keyboardRect fromView:self.view.window];
    //弹出软键盘左上角点Y轴的值
    CGFloat keyboardTop = keyboardRect.origin.y;
    //获取键盘弹出动画时间值
    NSNumber * animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = [animationDurationValue doubleValue];
    if (keyboardTop < CGRectGetMaxY(rect)) {
        // true 键盘盖住了输入框
        // 计算整体界面需要往上移动的偏移量，CGRectGetMaxY(rect)表示，输入框Y轴最大值
        CGFloat gap = keyboardTop - CGRectGetMaxY(rect);
        // 存在多个TextField的情况下，可能整体界面可能以及往上移多次，导致self.view的Y轴值不再为0，而是负数
        gap = gap + self.view.frame.origin.y;
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:animationDuration animations:^{
            weakSelf.view.frame = CGRectMake(weakSelf.view.frame.origin.x, gap, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
        }];
    }
}
- (void)keyboardWillHide:(NSNotification *)notification {
    if (!(self.currentResponderTextField && [self.currentResponderTextField isKindOfClass:[UITextField class]])) {
        // 如果没有响应者不进行操作
        return;
    }
    //获取键盘隐藏动画时间值
    NSDictionary *userInfo = [notification userInfo];
    NSNumber * animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration = [animationDurationValue doubleValue];
    if (self.view.frame.origin.y < 0) {
        //true 证明已经往上移动，软键盘消失时，整个界面要恢复原样
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:animationDuration animations:^{
            weakSelf.view.frame = CGRectMake(weakSelf.view.frame.origin.x, 0, weakSelf.view.frame.size.width, weakSelf.view.frame.size.height);
        }];
    }
}
#pragma mark -- FosaDatePickerViewDelegate
/**
 保存按钮代理方法

 @param timer 选择的数据
 */
- (void)datePickerViewSaveBtnClickDelegate:(NSString *)timer {
    NSLog(@"保存点击");
    if (isRemindOrExpire) {
        self.remindDateLable.text = timer;
    }else{
        self.expireDateLable.text  = timer;
    }
    [UIView animateWithDuration:0.3 animations:^{
       self.fosaDatePicker.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 300);
   }];
}
/**
 取消按钮代理方法
 */
- (void)datePickerViewCancelBtnClickDelegate {
    NSLog(@"取消点击");
    [UIView animateWithDuration:0.3 animations:^{
        self.fosaDatePicker.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 300);
    }];
}
#pragma mark - UItextViewDelegate and UItextFiled
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    editingViewHeight = CGRectGetMaxY(textView.frame);
    //NSLog(@"keyBoardWidth:%f------keyBoardHeight:%f",keyBoardWidth,keyBoardHeight);
    if ([textView.text isEqualToString:aboutFoodTips]) {
        textView.text=@"";
        self.aboutFoodInput.textColor = [UIColor blackColor];
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    //不支持系统表情的输入
        if ([[textView textInputMode]primaryLanguage]==nil||[[[textView textInputMode]primaryLanguage]isEqualToString:@"emoji"]) {
            return NO;
        }
    return YES;
}
- (void)textViewDidChange:(UITextView *)textView{
    self.numberLable.text = [NSString stringWithFormat:@"%lu/80",(unsigned long)textView.text.length];
    if (textView.text.length >= 80) {
        textView.text = [textView.text substringToIndex:80];
        self.numberLable.text = @"80/80";
    }
}
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.currentResponderTextField = textField;
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - UICollectionViewDataSource
//每个section有几个item
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //NSLog(@"------------------%lu",(unsigned long)categoryArray.count);
    return categoryArray.count;
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
    foodKindCollectionViewCell *cell = [self.categoryContent dequeueReusableCellWithReuseIdentifier:kindID forIndexPath:indexPath];
    cell.kind.text = categoryArray[indexPath.row];
    cell.layer.cornerRadius = 10;
    cell.layer.borderWidth = 1;
    return cell;
}
//点击item方法
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    foodKindCollectionViewCell *cell = (foodKindCollectionViewCell *)[self.categoryContent cellForItemAtIndexPath:indexPath];
    cell.backgroundColor = FOSAgreen;
    selectedKind = cell.kind.text;
    NSLog(@"Selectd:%@",selectedKind);
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    foodKindCollectionViewCell *cell = (foodKindCollectionViewCell *)[self.categoryContent cellForItemAtIndexPath:indexPath];
       cell.backgroundColor = [UIColor whiteColor];
}
//设置item的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize sizeForFirstLable = [categoryArray[indexPath.row] boundingRectWithSize:CGSizeMake(screen_width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    return CGSizeMake(sizeForFirstLable.width+43, 30);
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}
//点击效果
- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
}
- (void)collectionView:(UICollectionView *)collectionView didUnhighlightItemAtIndexPath:(NSIndexPath *)indexPath{
    
}
//设置每个item的UIEdgeInsets
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(5, 5, 0, 5);
}
#pragma mark -- 保存图片
- (void)SavephotosInSanBox:(NSMutableArray *)images{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    for (int i = 0; i < images.count; i++) {
        NSString *photoName = [NSString stringWithFormat:@"%@%d.png",self.foodNameInput.text,i+1];
        NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent: photoName];// 保存文件的路径
        NSLog(@"这个是照片的保存地址:%@",filePath);
        UIImage *img = [self fixOrientation:images[i]];
        BOOL result =[UIImagePNGRepresentation(img) writeToFile:filePath  atomically:YES];// 保存成功会返回YES
        if(result == YES) {
            NSLog(@"保存成功");
        }
    }
}
//- (void)SavephotoInSanBox:(UIImage *)image{
//     NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *photoName = [NSString stringWithFormat:@"%@%d.png",self.foodNameInput.text,1];
//           NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent: photoName];// 保存文件的路径
//           NSLog(@"这个是照片的保存地址:%@",filePath);
//           UIImage *img = [self fixOrientation:image];
//           BOOL result =[UIImagePNGRepresentation(img) writeToFile:filePath  atomically:YES];// 保存成功会返回YES
//           if(result == YES) {
//               NSLog(@"保存成功");
//           }
//}
//纠正图片的方向
- (UIImage *)fixOrientation:(UIImage *)aImage {
// No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
     switch (aImage.imageOrientation) {
         case UIImageOrientationDown:
         case UIImageOrientationDownMirrored:
             transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
             transform = CGAffineTransformRotate(transform, M_PI);
             break;
         case UIImageOrientationLeft:
         case UIImageOrientationLeftMirrored:
             transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
             transform = CGAffineTransformRotate(transform, M_PI_2);
             break;
         case UIImageOrientationRight:
         case UIImageOrientationRightMirrored:
             transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
             transform = CGAffineTransformRotate(transform, -M_PI_2);
             break;
         default:
             break;
     }
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
     CGContextRef ctx = CGBitmapContextCreate(NULL, aImage.size.width, aImage.size.height,CGImageGetBitsPerComponent(aImage.CGImage), 0,CGImageGetColorSpace(aImage.CGImage),CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.height,aImage.size.width), aImage.CGImage);
            break;
            default:
            CGContextDrawImage(ctx, CGRectMake(0,0,aImage.size.width,aImage.size.height), aImage.CGImage);
            break;
    }
// And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}
#pragma mark -- FMDB数据库操作

- (void)OpenSqlDatabase:(NSString *)dataBaseName{
    //获取数据库地址
    docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) lastObject];
    NSLog(@"%@",docPath);
    //设置数据库名
    NSString *fileName = [docPath stringByAppendingPathComponent:dataBaseName];
    //创建数据库
    self.db = [FMDatabase databaseWithPath:fileName];
    if([self.db open]){
        NSLog(@"打开数据库成功");
    }else{
        NSLog(@"打开数据库失败");
    }
}

- (void)CreatDataTable{
    NSString *Sql = @"CREATE TABLE IF NOT EXISTS FoodStorageInfo(id integer PRIMARY KEY AUTOINCREMENT, foodName text NOT NULL, device text NOT NULL, aboutFood text,remindDate text NOT NULL,expireDate text NOT NULL,foodImg text NOT NULL,category text NOT NULL);";
     
    BOOL categoryResult = [self.db executeUpdate:Sql];
    if(categoryResult)
    {
        NSLog(@"创建食物存储表成功");
        [self InsertDataIntoFoodTable];
    }else{
        NSLog(@"创建食物存储表失败");
    }
}

- (void)InsertDataIntoFoodTable{
    
    NSString *insertSql = @"insert into FoodStorageInfo(foodName,device,aboutFood,remindDate,expireDate,foodImg,category) values(?,?,?,?,?,?,?)";
    if ([self.foodNameInput.text isEqualToString:@""]) {
        [self SystemAlert:@"Please input the name of your food!"];
    }else{
        if ([self.db open]) {
            BOOL insertResult = [self.db executeUpdate:insertSql, self.foodNameInput.text,self.device,self.aboutFoodInput.text,self.remindDateLable.text,self.expireDateLable.text,self.foodNameInput.text,selectedKind];
            if (insertResult) {
                [self SystemAlert:@"Saving Data succeffully"];
            }else{
                [self SystemAlert:@"Error"];
            }
        }
    }
}
- (Boolean)CheckFoodInfoWithName:(NSString *)foodName fdevice:(NSString *)device{
    NSString *sql = [NSString stringWithFormat:@"select * from FoodStorageInfo where foodName = '%@' and device = '%@';",foodName,device];
    FMResultSet *result = [self.db executeQuery:sql];
    NSLog(@"查询到数据项:%d",result.columnCount);
    if (result.columnCount == 0) {
        return true;
    }else{
        return false;
    }
}
- (void)SaveShareinfo{
    [self OpenSqlDatabase:@"FOSA"];
    if (self.food_image.count != 0) {
        [self SavephotosInSanBox:self.food_image];
    }
    NSString *insertSql = @"insert into FoodStorageInfo(foodName,device,aboutFood,remindDate,expireDate,foodImg,category) values(?,?,?,?,?,?,?)";
    if ([self.db open]) {
        BOOL result = [self.db executeUpdate:insertSql,self.infoArray[1],self.infoArray[2],self.infoArray[3],self.infoArray[4],self.infoArray[5],self.infoArray[1], self.infoArray[6]];
        if (result) {
                       [self SystemAlert:@"Saving Data succeffully"];
                   }else{
                       [self SystemAlert:@"Error"];
                   }
    }
}
//弹出系统提示
-(void)SystemAlert:(NSString *)message{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert" message:message preferredStyle:UIAlertControllerStyleAlert];
    if ([message isEqualToString:@"Please input the name of your food!"]) {
         [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:true completion:nil];
    }else if([message isEqualToString:@"Error"]){
         [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:true completion:nil];
    }else if([message isEqualToString:@"Food record missing,added or not"]){
        [alert addAction:[UIAlertAction actionWithTitle:@"YES" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self SaveShareinfo];
        }]];
        [alert addAction:[UIAlertAction actionWithTitle:@"NO" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //不添加
        }]];
        [self presentViewController:alert animated:true completion:nil];
    }else{
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"保存成功");
            [self.navigationController popToRootViewControllerAnimated:YES];
        }]];
        [self presentViewController:alert animated:true completion:nil];
    }
}
/**隐藏底部横条，点击屏幕可显示*/
- (BOOL)prefersHomeIndicatorAutoHidden{
    return YES;
}

- (void)dealloc
{
    // 注册了通知，在ViewController消失到时候，要移除通知的监听
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}
@end
