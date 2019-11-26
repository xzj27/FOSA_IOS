//
//  FosaNotification.h
//  FOSA
//
//  Created by hs on 2019/11/14.
//  Copyright © 2019 hs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FosaNotification : NSObject

- (UIView *)CreatNotificatonView:(NSString *)title body:(NSString *)body;
- (UIImage *)SaveViewAsPicture:(UIView *)view;
- (void)initNotification;
- (void)sendNotification:(NSString *)foodName body:(NSString *)body path:(UIImage *)image deviceName:(NSString *)device;
- (void)sendNotificationByDate:(NSString *)foodName body:(NSString *)body path:(NSString *)photo deviceName:(NSString *)device;
- (UIImage *)GenerateQRCodeByMessage:(NSString *)message;
@end

NS_ASSUME_NONNULL_END
