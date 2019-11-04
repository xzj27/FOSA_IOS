//
//  BltPoundViewController.m
//  fosa1.0
//
//  Created by hs on 2019/10/16.
//  Copyright © 2019 hs. All rights reserved.
//

#import "BltPoundViewController.h"
#import <UserNotifications/UserNotifications.h>
#import "ScanViewController.h"

@interface BltPoundViewController ()<UNUserNotificationCenterDelegate>
@property (nonatomic,strong) UIButton *send;
@end

@implementation BltPoundViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   // self.view.backgroundColor = [UIColor blueColor];
   
    _send = [[UIButton alloc]initWithFrame:CGRectMake(20, 80, self.view.frame.size.width-40, 30)];
    [_send addTarget:self action:@selector(sendNotification) forControlEvents:UIControlEventTouchUpInside];
    [_send setTitle:@"点击发送通知" forState:UIControlStateNormal];
    _send.backgroundColor = [UIColor greenColor];
    [self.view addSubview:_send];
    
    [self initNotification];
}

-(void)initNotification{
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            // 必须写代理，不然无法监听通知的接收与点击
    center.delegate = self;
        //设置预设好的交互类型，NSSet里面是设置好的UNNotificationCategory
    [center setNotificationCategories:[self createNotificationCategoryActions]];
    
    [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
    if (settings.authorizationStatus==UNAuthorizationStatusNotDetermined){
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert|UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error){
                if (granted) {
                    } else {
                    }
                }];
            }
        else{
           //do other things
        }
    }];
    //移除一条通知
   // [center removePendingNotificationRequestsWithIdentifiers:@[@"time interval request"]];
}

//代理回调方法，通知即将展示的时候
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"即将展示通知");
    UNNotificationRequest *request = notification.request; // 原始请求
    NSDictionary * userInfo = notification.request.content.userInfo;//userInfo数据
    UNNotificationContent *content = request.content; // 原始内容
    NSString *title = content.title;  // 标题
    NSString *subtitle = content.subtitle;  // 副标题
    NSNumber *badge = content.badge;  // 角标
    NSString *body = content.body;    // 推送消息体
    UNNotificationSound *sound = content.sound;  // 指定的声音
//建议将根据Notification进行处理的逻辑统一封装，后期可在Extension中复用~
completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 回调block，将设置传入
}
//用户与通知进行交互后的response，比如说用户直接点开通知打开App、用户点击通知的按钮或者进行输入文本框的文本
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
//在此，可判断response的种类和request的触发器是什么，可根据远程通知和本地通知分别处理，再根据action进行后续回调
    if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {
        UNTextInputNotificationResponse * textResponse = (UNTextInputNotificationResponse*)response;
        NSString * text = textResponse.userText;
        NSLog(@"%@",text);
    }
    else{
        if ([response.actionIdentifier isEqualToString:@"see1"]){
            NSLog(@"I love it!!");
            ScanViewController *scan = [[ScanViewController alloc]init];
            scan.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:scan animated:NO];
        }
        if ([response.actionIdentifier isEqualToString:@"see2"]) {
            //I don't care~
            NSLog(@"I don't like it");
            [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[response.notification.request.identifier]];
        }
    }
    completionHandler();
//
//    UNNotificationRequest *request = response.notification.request; // 原始请求
////NSDictionary * userInfo = notification.request.content.userInfo;//userInfo数据
//    UNNotificationContent *content = request.content; // 原始内容
//    NSString *title = content.title;  // 标题
//    NSString *subtitle = content.subtitle;  // 副标题
//    NSNumber *badge = content.badge;  // 角标
//    NSString *body = content.body;    // 推送消息体
//    UNNotificationSound *sound = content.sound;
//在此，可判断response的种类和request的触发器是什么，可根据远程通知和本地通知分别处理，再根据action进行后续回调

}
-(void)sendNotification{
       UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    
           content.title = @"\"Reminding\"";
           content.subtitle = @"by Fosa";
           content.body = @"your food will expire";
           content.badge = @0;
           NSString *path = [[NSBundle mainBundle] pathForResource:@"启动图2" ofType:@"png"];
           NSError *error = nil;
       //将本地图片的路径形成一个图片附件，加入到content中
           UNNotificationAttachment *img_attachment = [UNNotificationAttachment attachmentWithIdentifier:@"att1" URL:[NSURL fileURLWithPath:path] options:nil error:&error];
           if (error) {
               NSLog(@"%@", error);
           }
           content.attachments = @[img_attachment];
           //设置为@""以后，进入app将没有启动页
           content.launchImageName = @"";
           UNNotificationSound *sound = [UNNotificationSound defaultSound];
           content.sound = sound;
           //设置时间间隔的触发器
            //格式化时间
          NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
          [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
          NSDate * date = [formatter dateFromString:@"2019-10-29 9:46:00"];
          NSDateComponents * components = [[NSCalendar currentCalendar]
                                             components:NSCalendarUnitYear |
                                             NSCalendarUnitMonth |
                                             NSCalendarUnitWeekday |
                                             NSCalendarUnitDay |
                                             NSCalendarUnitHour |
                                             NSCalendarUnitMinute |
                                             NSCalendarUnitSecond
                                             fromDate:date];
    
            //UNTimeIntervalNotificationTrigger *time_trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
    UNCalendarNotificationTrigger *date_trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
           NSString *requestIdentifer = @"Fosa Reminding";
           //content.categoryIdentifier = @"seeCategory";
           content.categoryIdentifier = @"seeCategory";
           UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifer content:content trigger:date_trigger];
    
           [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
               NSLog(@"%@",error);
           }];
}
-(NSSet *)createNotificationCategoryActions{
    //定义按钮的交互button action
    UNNotificationAction * likeButton = [UNNotificationAction actionWithIdentifier:@"see1" title:@"I love it~" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive|UNNotificationActionOptionForeground];
    UNNotificationAction * dislikeButton = [UNNotificationAction actionWithIdentifier:@"see2" title:@"I don't care~" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive|UNNotificationActionOptionForeground];
    //定义文本框的action
    UNTextInputNotificationAction * text = [UNTextInputNotificationAction actionWithIdentifier:@"text" title:@"How about it~?" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive|UNNotificationActionOptionForeground];
    //将这些action带入category
    UNNotificationCategory * choseCategory = [UNNotificationCategory categoryWithIdentifier:@"seeCategory" actions:@[likeButton,dislikeButton] intentIdentifiers:@[@"see1",@"see2"] options:UNNotificationCategoryOptionNone];
    UNNotificationCategory * comment = [UNNotificationCategory categoryWithIdentifier:@"seeCategory1" actions:@[text] intentIdentifiers:@[@"text"] options:UNNotificationCategoryOptionNone];
    return [NSSet setWithObjects:choseCategory,comment,nil];
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
