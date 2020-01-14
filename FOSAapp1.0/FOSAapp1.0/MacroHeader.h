//
//  MacroHeader.h
//  FOSAapp1.0
//
//  Created by hs on 2019/12/30.
//  Copyright © 2019 hs. All rights reserved.
//

#ifndef MacroHeader_h
#define MacroHeader_h

//plist文件常量 ——>路径
#define DocumentsDirectory [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]

//历史搜索记录
#define HISTORYSEARCHFILE [DocumentsDirectory stringByAppendingPathComponent:@"historySearch.plist"]

//获取appDelegates类
#define ApplicationDelegate ((AppDelegate *)[UIApplication sharedApplication].delegate)

// 1.判断是否为iOS8
#define iOS8 ([[UIDevice currentDevice].systemVersion doubleValue] >= 8.0)
// 2.判断是否为iOS9
#define iOS9 ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0)
// 3.判断是否为iOS10
#define iOS10 ([[UIDevice currentDevice].systemVersion doubleValue] >= 10.0)
// 4.判断是否为iOS11
#define iOS11 ([[UIDevice currentDevice].systemVersion doubleValue] >= 11.0)
// 5.判断是否为iOS12
#define iOS12 ([[UIDevice currentDevice].systemVersion doubleValue] >= 12.0)
// 6.判断是否为iOS13
#define iOS13 ([[UIDevice currentDevice].systemVersion doubleValue] >= 13.0)

//手机型号和平板
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define IS_IPHONE_4 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)480) < DBL_EPSILON)
#define IS_IPHONE_5 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE_6 (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)667) < DBL_EPSILON)
#define IS_IPHONE_6P (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)736) < DBL_EPSILON)
#define IS_IPHONE_X (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)812) < DBL_EPSILON) || (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)896) < DBL_EPSILON)

// 1.获得RGB颜色
#define YTHColor(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define YTHColorAlpha(r, g, b ,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]

// 2.用代码形式代码
#define UIColorFromRGBValue(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
// 3.屏幕宽高
#define ScreenHp [[UIScreen mainScreen] bounds].size.height*1.0 // 屏幕高度
#define ScreenWp [[UIScreen mainScreen] bounds].size.width*1.0 // 屏幕宽度

#define ScreenH MAX(ScreenHp,ScreenWp) // 屏幕高度
#define ScreenW MIN(ScreenHp,ScreenWp)// 屏幕宽度

// 4.导航栏/工具栏/状态栏高度
#define NavigationBarH 44
#define StatusBarH [[UIApplication sharedApplication] statusBarFrame].size.height//顶部状态栏高度
#define ToolBarH (IS_IPHONE_X ? 83 : 49)//底部工具栏高度
#define NoToolBarX (IS_IPHONE_X ? 34 : 0)//底部iPhoneX的适配高度
#define NavgationH (IS_IPHONE_X ? 88 : 64)//顶部导航栏高度

// 5.屏幕适配
#define Width(R) (R)*(ScreenW)/375.0
#define Height(R) Width(R)

// 6.字体适配
#define font(R) (R)*(ScreenW)/375.0

// 7.全局颜色
#define XYRMainColor YTHColor(254,48,131)//主色调
#define FOSAgreen [UIColor colorWithRed:0/255.0 green:200/255.0 blue:70/255.0 alpha:1.0]
#define FOSAgreengrad [UIColor colorWithRed:80/255.0 green:200/255.0 blue:80/255.0 alpha:1.0]
#define FOSARed  [UIColor redColor]
#define RandomColor ([UIColor colorWithRed:arc4random_uniform(255)/255.0 green:arc4random_uniform(255)/255.0 blue:arc4random_uniform(255)/255.0 alpha:1.0])//随机颜色
#define FOSAFoodBackgroundColor [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0]
#define FOSAWhite [UIColor whiteColor]
//食品信息弹窗
#define FOSAAlertBacgBlue [UIColor colorWithRed:0 green:152/255.0 blue:187/255.0 alpha:1.0]
#define FOSAAlertBlue     [UIColor colorWithRed:0 green:131/255.0 blue:200/255.0 alpha:1.0]
#define FOSAAlertBacgGreen [UIColor colorWithRed:2/255.0 green:159/255.0 blue:26/255.0 alpha:1.0]
#define FOSAAlertGreen     [UIColor colorWithRed:33/255.0 green:198/255.0 blue:42/255.0 alpha:1.0]
#define FOSAAlertBacgYellow [UIColor colorWithRed:249/255.0 green:211/255.0 blue:51/255.0 alpha:1.0]
#define FOSAAlertYellow     [UIColor colorWithRed:252/255.0 green:175/255.0 blue:0/255.0 alpha:1.0]
//可以添加其他常用颜色，方便修改

// 8.解决日志打印不全的问题
#ifdef DEBUG
#define NSLog( s, ... ) printf("class: <%p %s:(%d) > method: %s \n%s\n", self, [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__, [[NSString stringWithFormat:(s), ##__VA_ARGS__] UTF8String] );
#else
#define NSLog( s, ... )
#endif

// 9.获取app的info.plist详细信息
#define Version [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]  //build 版本号
#define ShortVersion [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]; //version 版本号
#define Package [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] //包名

#define DisplayName [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"] //应用显示的名称
#define BundleName [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"] //工程名

/** 屏幕高度 */
#define screen_height [UIScreen mainScreen].bounds.size.height
/** 屏幕宽度 */
#define screen_width [UIScreen mainScreen].bounds.size.width
//判断是否是iPad
#define ISIPAD [[UIDevice currentDevice] userInterfaceIdiom] ==UIUserInterfaceIdiomPad
//判断手机型号为X
#define is_IPHONEX [[UIScreen mainScreen] bounds].size.width == 375.0f &&([[UIScreen mainScreen] bounds].size.height == 812.0f)
//获取状态栏的高度 iPhone X - 44pt 其他20pt
#define StatusBarHeight [[UIApplication sharedApplication] statusBarFrame].size.height
//获取导航栏的高度 - （不包含状态栏高度） 44pt
#define NavigationBarHeight self.navigationController.navigationBar.frame.size.height
//屏幕底部 tabBar高度49pt + 安全视图高度34pt(iPhone X)
#define TabbarHeight self.tabBarController.tabBar.frame.size.height
//屏幕顶部 导航栏高度（包含状态栏高度）
#define NavigationHeight (StatusBarHeight + NavigationBarHeight)
//屏幕底部安全视图高度 - 适配iPhone X底部
#define TOOLH (is_IPHONEX ? 34 : 0)
//屏幕底部 toolbar高度 + 安全视图高度34pt
#define ToolbarHeight self.navigationController.toolbar.frame.size.height

#endif /* MacroHeader_h */
