//
//  FosaUserViewController.h
//  FOSA
//
//  Created by hs on 2019/11/11.
//  Copyright © 2019 hs. All rights reserved.
//

#import "ViewController.h"
#import "UserItem.h"
NS_ASSUME_NONNULL_BEGIN

@interface FosaUserViewController : ViewController
@property (nonatomic,strong) UIScrollView *rootScrollview;
@property (nonatomic,strong) UIView *headerView;
@property (nonatomic,strong) UIImageView *userIcon;
@property (nonatomic,strong) UILabel *username,*FosaContentTitle,*AppsContentTitle;

@property (nonatomic,strong) UIView *itemView;

@property (nonatomic,strong) UserItem *Tutorial,*Location,*Setting,*Notification,*HelpCenter,*FosaContent,*AppsContent;

//常用的布局数据
@property (nonatomic,assign) CGFloat mainWidth,mainHeigh,navHeigh;
@property (nonatomic,assign) Boolean isFosaOpen,isAppsOpen;

@end

NS_ASSUME_NONNULL_END
