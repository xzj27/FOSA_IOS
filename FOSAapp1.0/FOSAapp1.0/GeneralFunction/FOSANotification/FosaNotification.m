//
//  FosaNotification.m
//  FOSAapp1.0
//
//  Created by hs on 2020/1/3.
//  Copyright © 2020 hs. All rights reserved.
//

#import "FosaNotification.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreImage/CoreImage.h>
//图片宽高的最大值
#define KCompressibilityFactor 1280.00

@interface FosaNotification()<UNUserNotificationCenterDelegate>{
    NSString *foodName;
}
@property (nonatomic,strong) UIImage *image,*codeImage;
@end

@implementation FosaNotification


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
}
//代理回调方法，通知即将展示的时候
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
    NSLog(@"即将展示通知");
    UNNotificationRequest *request = notification.request; // 原始请求
    //NSDictionary * userInfo = notification.request.content.userInfo;//userInfo数据
    UNNotificationContent *content = request.content; // 原始内容
//建议将根据Notification进行处理的逻辑统一封装，后期可在Extension中复用~
completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 回调block，将设置传入
    [self deleteFile:content.subtitle];
}
//用户与通知进行交互后的response，比如说用户直接点开通知打开App、用户点击通知的按钮或者进行输入文本框的文本
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
   //获取通知相关内容
    UNNotificationRequest *request = response.notification.request; // 原始请求
    UNNotificationContent *content = request.content; // 原始内容
    NSString *title = content.title;  // 标题
    NSString *body = content.body;    // 推送消息体

//在此，可判断response的种类和request的触发器是什么，可根据远程通知和本地通知分别处理，再根据action进行后续回调
    if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {
        UNTextInputNotificationResponse * textResponse = (UNTextInputNotificationResponse*)response;
        NSString * text = textResponse.userText;
        NSLog(@"%@",text);
    }
    else{
        if ([response.actionIdentifier isEqualToString:@"see1"]){
            NSLog(@"Save UIView as photo");
            UIImage *notificationImage = [self SaveViewAsPicture:[self CreatNotificatonView:title body:body]];
            //[self beginShare:image];
            UIImageWriteToSavedPhotosAlbum(notificationImage, self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
        }
        if ([response.actionIdentifier isEqualToString:@"see2"]) {
            //I don't care~
            NSLog(@"I know");
            [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[response.notification.request.identifier]];
        }
    }
    completionHandler();
}

- (void)sendNotificationByDate:(NSString *)foodName body:(NSString *)body path:(NSString *)photo deviceName:(NSString *)device date:(NSString *)mdate{
    NSLog(@"我将发送一个系统通知");
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"\"Reminding\"";
    content.subtitle = @"by Fosa";
    content.body = body;
    content.badge = @0;
    //获取沙盒中的图片
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photopath = [NSString stringWithFormat:@"%@.png",photo];
    NSString *imagePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",photopath]];
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    self.image = img;
    NSLog(@"%@",imagePath);
    NSError *error = nil;
    //将本地图片的路径形成一个图片附件，加入到content中
    UNNotificationAttachment *img_attachment = [UNNotificationAttachment attachmentWithIdentifier:@"att1" URL:[NSURL fileURLWithPath:imagePath] options:nil error:&error];
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
    [formatter setDateFormat:@"yyyy/MM/dd/HH:mm"];
    NSDate * date = [formatter dateFromString:mdate];
    NSDateComponents * components = [[NSCalendar currentCalendar]
                                                components:NSCalendarUnitYear |
                                                NSCalendarUnitMonth |
                                                NSCalendarUnitWeekday |
                                                NSCalendarUnitDay |
                                                NSCalendarUnitHour |
                                                NSCalendarUnitMinute |
                                                NSCalendarUnitSecond
                                                fromDate:date];
    UNCalendarNotificationTrigger *date_trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
    NSString *requestIdentifer = photo;
           //content.categoryIdentifier = @"textCategory";
    content.categoryIdentifier = @"seeCategory";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifer content:content trigger:date_trigger];
       
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
           NSLog(@"%@",error);
    }];
    //[self Savephoto:img name:photo];
}
- (void)sendNotification:(FoodModel *)model body:(NSString *)body image:(UIImage *)img{
    NSLog(@"我将发送一个系统通知");
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"FOSA Reminding";
    content.subtitle = model.foodName;
    content.body = body;
    content.badge = @0;
    //获取沙盒中的图片
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photopath = [NSString stringWithFormat:@"%@.png",model.foodName];
    NSString *imagePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",photopath]];
    NSError *error = nil;
    //将本地图片的路径形成一个图片附件，加入到content中
    UNNotificationAttachment *img_attachment = [UNNotificationAttachment attachmentWithIdentifier:@"att1" URL:[NSURL fileURLWithPath:imagePath] options:nil error:&error];

    if (error) {
        NSLog(@"%@", error);
    }
    content.attachments = @[img_attachment];
    
    //设置为@""以后，进入app将没有启动页
    content.launchImageName = @"";
    UNNotificationSound *sound = [UNNotificationSound defaultSound];
    content.sound = sound;
    //设置时间间隔的触发器
    UNTimeIntervalNotificationTrigger *time_trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:2 repeats:NO];
    NSString *requestIdentifer = model.foodName;
    content.categoryIdentifier = @"seeCategory";
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifer content:content trigger:time_trigger];
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        NSLog(@"%@",error);
    }];
    //生成二维码
    NSString *message = [NSString stringWithFormat:@"FOSAINFO&%@&%@&%@&%@&%@&%@",model.foodName,model.device,model.aboutFood,model.expireDate,model.remindDate,model.category];
    self.codeImage = [self GenerateQRCodeByMessage:message];
    self.image = img;
    foodName = model.foodName;
    NSLog(@"这是分享图片上的食物%@图片:%@",model.foodName,self.image);
}

-(NSSet *)createNotificationCategoryActions{
    //定义按钮的交互button action
    UNNotificationAction * likeButton = [UNNotificationAction actionWithIdentifier:@"see1" title:@"Save as Picture" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive|UNNotificationActionOptionForeground];
    UNNotificationAction * dislikeButton = [UNNotificationAction actionWithIdentifier:@"see2" title:@"I don't care~" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive|UNNotificationActionOptionForeground];
    //定义文本框的action
    UNTextInputNotificationAction * text = [UNTextInputNotificationAction actionWithIdentifier:@"text" title:@"How about it~?" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive|UNNotificationActionOptionForeground];
    //将这些action带入category
    UNNotificationCategory * choseCategory = [UNNotificationCategory categoryWithIdentifier:@"seeCategory" actions:@[likeButton,dislikeButton] intentIdentifiers:@[@"see1",@"see2"] options:UNNotificationCategoryOptionNone];
    UNNotificationCategory * comment = [UNNotificationCategory categoryWithIdentifier:@"textCategory" actions:@[text] intentIdentifiers:@[@"text"] options:UNNotificationCategoryOptionNone];
    return [NSSet setWithObjects:choseCategory,comment,nil];
}

#pragma mark - 分享图片
//仿照系统通知绘制UIview
- (UIView *)CreatNotificatonView:(NSString *)title body:(NSString *)body{
    NSLog(@"begin creating");
    
    int mainwidth = screen_width;
    int mainHeight = screen_height;
    
    UIView *notification = [[UIView alloc]initWithFrame:CGRectMake(0, 0, mainwidth,mainHeight)];
    notification.backgroundColor = [UIColor whiteColor];

    //食物图片
    UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(0,mainHeight/8, mainwidth, mainHeight/2)];
    
    //FOSA的logo
    UIImageView *logo = [[UIImageView alloc]initWithFrame:CGRectMake(mainwidth*2/5, mainHeight-mainwidth/5, mainwidth/10, mainwidth/10)];
    
    //FOSA
    UILabel *brand = [[UILabel alloc]initWithFrame:CGRectMake(mainwidth/15, mainHeight*5/8, mainwidth/4, mainHeight/16)];
    
    //食物信息二维码
    UIImageView *InfoCodeView = [[UIImageView alloc]initWithFrame:CGRectMake(mainwidth*4/5-20, mainHeight*5/8+5, mainwidth/5, mainwidth/5)];

    //提醒内容
    UITextView *Nbody = [[UITextView alloc]initWithFrame:CGRectMake(mainwidth/15, mainHeight*11/16, mainwidth*3/5, mainwidth/5)];
    Nbody.userInteractionEnabled = NO;

    [notification addSubview:logo];
    [notification addSubview:brand];
    [notification addSubview:InfoCodeView];
    [notification addSubview:image];
    [notification addSubview:Nbody];

    logo.image  = [UIImage imageNamed:@"icon_logoHL"];
    NSLog(@"食物图片被添加到分享视图上:%@",self.image);
    image.image = self.image;
    image.contentMode = UIViewContentModeScaleAspectFill;
    image.clipsToBounds = YES;
    InfoCodeView.image = self.codeImage;
    InfoCodeView.backgroundColor = [UIColor redColor];
    InfoCodeView.contentMode = UIViewContentModeScaleAspectFill;
    InfoCodeView.clipsToBounds = YES;
    
    brand.font  = [UIFont systemFontOfSize:15];
    brand.textAlignment = NSTextAlignmentCenter;
    brand.text  = @"FOSA";
    
    Nbody.font   = [UIFont systemFontOfSize:12];
    Nbody.text = body;
    
    return notification;
}

//将UIView转化为图片并保存在相册
- (UIImage *)SaveViewAsPicture:(UIView *)view{
    NSLog(@"begin saving");
    UIImage *imageRet = [[UIImage alloc]init];
    //UIGraphicsBeginImageContextWithOptions(区域大小, 是否是非透明的, 屏幕密度);
    UIGraphicsBeginImageContextWithOptions(view.frame.size, YES, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    imageRet = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageRet;
}

- (UIImage *)GenerateQRCodeByMessage:(NSString *)message{
    // 1. 创建一个二维码滤镜实例(CIFilter)
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 滤镜恢复默认设置
    [filter setDefaults];
    // 2. 给滤镜添加数据
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [filter setValue:data forKeyPath:@"inputMessage"];
    // 3. 生成二维码
    CIImage *image = [filter outputImage];
    //[self createNonInterpolatedUIImageFormCIImage:image withSize:];
    return [UIImage imageWithCIImage:image];
}

//获得高清的二维码图片
- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}
#pragma mark - <保存到相册>
-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    NSString *msg = nil ;
    if(error){
        msg = @"保存图片失败" ;
        NSLog(@"%@",msg);
    }else{
        msg = @"保存图片成功" ;
        NSLog(@"%@",msg);
        //[self SystemAlert:msg];
    }
}
//删除图片
- (void)deleteFile:(NSString *)photoName {
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photo = [NSString stringWithFormat:@"%@.png",photoName];
    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent: photo];
    NSFileManager* fileManager=[NSFileManager defaultManager];
    BOOL blHave=[[NSFileManager defaultManager] fileExistsAtPath:filePath];
    if (!blHave) {
        NSLog(@"no  have");
    }else {
        NSLog(@" have");
        BOOL blDele= [fileManager removeItemAtPath:filePath error:nil];
        if (blDele) {
            NSLog(@"dele success");
        }else {
            NSLog(@"dele fail");
        }
    }
}
////保存到沙盒
//-(NSString *)Savephoto:(UIImage *)image name:(NSString *)foodname{
//    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
//    NSString *photoName = [NSString stringWithFormat:@"%@%d.png",foodname,1];
//    NSString *filePath = [[paths objectAtIndex:0]stringByAppendingPathComponent: photoName];// 保存文件的路径
//    NSLog(@"这个是照片的保存地址:%@",filePath);
//    BOOL result =[UIImagePNGRepresentation(image) writeToFile:filePath  atomically:YES];// 保存成功会返回YES
//    if(result == YES) {
//        NSLog(@"保存成功");
//    }
//    return filePath;
//}
//弹出系统提示
//-(void)SystemAlert:(NSString *)message{
//    NSLog(@"$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$SystemAlert");
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Notification" message:message preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
//
//}
//取出保存在本地的图片
- (void)getImage:(NSString *)filepath{
    NSArray *paths =NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *photopath = [NSString stringWithFormat:@"%@%d.png",filepath,1];
    NSString *imagePath = [[paths objectAtIndex:0]stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",photopath]];
    // 保存文件的名称
    UIImage *img = [UIImage imageWithContentsOfFile:imagePath];
    NSLog(@">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>%@", img);
}
-(void)beginShare:(UIImage *)image{
    NSLog(@"点击了分享");
    //UIImage *sharephoto = [self getJPEGImagerImg:self.food_image];
    //UIImage *sharephoto1 = [self getJPEGImagerImg:[UIImage imageNamed:@"启动图2"]];
    //NSArray *activityItems = @[image];
    //UIActivityViewController *activityVC = [[UIActivityViewController alloc]initWithActivityItems:activityItems applicationActivities:nil];
}

#pragma mark - 压缩图片
- (UIImage *)getJPEGImagerImg:(UIImage *)image{
 CGFloat oldImg_WID = image.size.width;
 CGFloat oldImg_HEI = image.size.height;
 //CGFloat aspectRatio = oldImg_WID/oldImg_HEI;//宽高比
 if(oldImg_WID > KCompressibilityFactor || oldImg_HEI > KCompressibilityFactor){
 //超过设置的最大宽度 先判断那个边最长
 if(oldImg_WID > oldImg_HEI){
  //宽度大于高度
  oldImg_HEI = (KCompressibilityFactor * oldImg_HEI)/oldImg_WID;
  oldImg_WID = KCompressibilityFactor;
 }else{
  oldImg_WID = (KCompressibilityFactor * oldImg_WID)/oldImg_HEI;
  oldImg_HEI = KCompressibilityFactor;
 }
 }
 UIImage *newImg = [self imageWithImage:image scaledToSize:CGSizeMake(oldImg_WID, oldImg_HEI)];
 NSData *dJpeg = nil;
 if (UIImagePNGRepresentation(newImg)==nil) {
 dJpeg = UIImageJPEGRepresentation(newImg, 0.5);
 }else{
 dJpeg = UIImagePNGRepresentation(newImg);
 }
 return [UIImage imageWithData:dJpeg];
}
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
 UIGraphicsBeginImageContext(newSize);
 [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
 UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
 UIGraphicsEndImageContext();
 return newImage;
}

@end
