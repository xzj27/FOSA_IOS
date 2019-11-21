//
//  FosaScrollview.m
//  FOSA
//
//  Created by hs on 2019/11/20.
//  Copyright © 2019 hs. All rights reserved.
//

#import "FosaScrollview.h"

@interface FosaScrollview()<
UIScrollViewDelegate
>
@property (nonatomic,strong) NSMutableArray *labelM;

@property (nonatomic,strong) NSArray<NSString*> *titles;
/** 记录位置下标 */
@property (nonatomic, assign) NSInteger tagIndex;
/** 点击回调 */
@property (nonatomic, copy) TabClickBlock clickBlock;
@end
CGFloat margin = 0;
#define RandomColor ([UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0])
@implementation FosaScrollview
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor blueColor];
    self.delegate = self;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
}

/**
 titles:所有标题数组
 index: 当前选中的下标
 clickBlock:点击回调
 */
-(void)configParameterFrame:(CGRect)frame titles:(NSArray<NSString*> *)titles index:(NSInteger)index block:(TabClickBlock) clickBlock {
    self.titles = titles;
    self.clickBlock = clickBlock;
    self.tagIndex = index;
    
    self.frame = frame;
    
    for (NSInteger i = 0; i < titles.count; i++) {
        UILabel *lbl = [[UILabel alloc]init];
        lbl.tag = i;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.backgroundColor = RandomColor;
        lbl.text = titles[i];
        lbl.textColor=[UIColor lightGrayColor];
        lbl.font = [UIFont systemFontOfSize:15];
        if (i == 0) {
            lbl.frame = CGRectMake(0, 0, frame.size.width/2, frame.size.height);
        }else {
            //UILabel *preLbl = self.labelM[i - 1];
            lbl.frame = CGRectMake(frame.size.width/2, 0, frame.size.width/2, frame.size.height);
        }
        [self addSubview:lbl];
        [self.labelM addObject:lbl];
        // 添加点击事件
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuAction:)];
        lbl.userInteractionEnabled=YES;
        [lbl addGestureRecognizer:tap];
    }
    //UILabel *lastLbl = [self.labelM lastObject];
   // CGFloat maxWidth = CGRectGetMaxX(lastLbl.frame) + margin;
    // 设置内容宽度
    //self.contentSize = CGSizeMake(maxWidth, 0);
    // 默认滚到对应的下标
    [self tabOffset:index];
}

-(void)menuAction:(id)sender{
    UITapGestureRecognizer *tap = (UITapGestureRecognizer*)sender;
    UILabel *lbl = (UILabel*)tap.view;
    NSUInteger index = lbl.tag;   //获取上面view设置的tag
    
    [self tabOffset:index];
    
    if (self.clickBlock){
        self.clickBlock(index);
    }
}

/** 点击滚动到指定index */
-(void)tabOffset:(NSInteger)index{
    if (self.labelM.count == 0) { return; }
    if (index > self.titles.count-1) {
        index = self.titles.count-1;
    }
    
    for (NSInteger i = 0; i < self.labelM.count; i++) {
        UILabel *lbl = self.labelM[i];
        if (index == i) {
            lbl.textColor=[UIColor whiteColor];
            lbl.font = [UIFont boldSystemFontOfSize:14];
        }else {
            lbl.textColor=[UIColor lightGrayColor];
            lbl.font = [UIFont systemFontOfSize:15];
        }
    }
    
    // 获取scrollview宽度
    NSInteger selfW = self.frame.size.width;
    
    UILabel *lbl = self.labelM[index];
    NSInteger lblW = lbl.frame.size.width;
    
    // 获取当前点击的tab所处的位置大小
    CGFloat lblMinX = CGRectGetMinX(lbl.frame);
    // 判断tab是否处于大于屏幕一半的位置,并计算出偏移量
    CGFloat offsetX_halfSelfW = lblMinX - selfW/2;
    //当tab偏移量不足tab宽度时,计算出最小的偏移量
    CGFloat itemOffset = offsetX_halfSelfW + lblW/2;
    NSInteger contentW = self.contentSize.width;
    
    //当偏移量>0的时候,
    if(offsetX_halfSelfW > 0){
        //假如偏移量小于一个tab的宽度,说明还没有到最初始位置,可以执行偏移
        if(offsetX_halfSelfW < lblW){
            if (contentW < selfW) { return; } // 内容不足以超出屏幕
//            NSLog(@"setContentOffset 1");
            [self setContentOffset:CGPointMake(itemOffset, 0) animated:YES];
            return;
        }
        //获取偏移的页数,减1的作用是我们的偏移是从0开始的,所以需要减去一个屏幕长度
        NSInteger page = contentW/selfW - 1;
        //获取最后一页的偏移量
        NSInteger last_page_offsetX = contentW % selfW;
        //获取到最大偏移量
        NSInteger maxOffsetX = page * selfW + last_page_offsetX;
        //假如我们的计算的偏移量小于最大偏移,说明是可以偏移的
        if(itemOffset <= maxOffsetX){
            //假如偏移量大于一个tab的宽度,判断
            if(itemOffset <= lblW){  //当点击的偏移量小于tab的宽度的时候,归零偏移量
//                NSLog(@"setContentOffset 2");
                [self setContentOffset:CGPointMake(0, 0) animated:YES];
                return;
            }else{
//                NSLog(@"setContentOffset 3");
                [self setContentOffset:CGPointMake(itemOffset, 0) animated:YES];
            }
            
        }else{
            if (maxOffsetX < 0) {
                return;
            }
//            NSLog(@"setContentOffset 4");
            [self setContentOffset:CGPointMake(maxOffsetX, 0) animated:YES];
        }
    }else if(offsetX_halfSelfW < 0){
        //判断往后滚的偏移量小于0但是却和半个tab宽度之和要大于0的时候,说明还可以进行微调滚动,
        if(itemOffset>0){
//            NSLog(@"setContentOffset 5");
            [self setContentOffset:CGPointMake(itemOffset, 0) animated:YES];
            return;
        }
//        NSLog(@"setContentOffset 6");
        //最小偏移小于0,说明往前滚,将偏移重置为初始位置
        [self setContentOffset:CGPointMake(0, 0) animated:YES];
    }else{
//        NSLog(@"setContentOffset 7");
        [self setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
    self.tagIndex=index;
}

#pragma mark - Property

- (NSMutableArray *)labelM {
    if (_labelM == nil) {
        _labelM = [NSMutableArray array];
    }
    return _labelM;
}

@end
