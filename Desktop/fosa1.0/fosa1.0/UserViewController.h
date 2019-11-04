//
//  UserViewController.h
//  fosa1.0
//
//  Created by hs on 2019/10/16.
//  Copyright © 2019 hs. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserViewController : UIViewController

@property (nonatomic,strong) UIScrollView *rootScrollview;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIImageView *userIcon;
@property (nonatomic,strong) UILabel *username,*FosaContentTitle,*AppsContentTitle;

@property (nonatomic,strong) UIView *FosaContent,*AppsContent;
@property (nonatomic,strong) UITextField *aboutFosa,*aboutApps;
@property (nonatomic,strong) UIImageView *showContent,*showApps;


//常用的布局数据
@property (nonatomic,assign) CGFloat mainWidth,mainHeigh,navHeigh;
@property (nonatomic,assign) Boolean isFosaOpen,isAppsOpen;
@end

NS_ASSUME_NONNULL_END
