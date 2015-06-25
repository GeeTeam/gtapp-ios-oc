//
//  GTView.h
//  GTTest
//
//  Created by LYJ on 15/5/14.
//  Copyright (c) 2015年 LYJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTUtils.h"


@protocol GTViewDelegate;

/**
 * 验证显示WebView
 */
@interface GTView : UIWebView

@property (nonatomic, weak) id<GTViewDelegate>gtdelegate;

/**
 *  开始加载
 *
 *  @param the_captcha_id 分配的captcha_id
 */
- (void)startLoadWithCaptcha_id:(NSString *)the_captcha_id;

/**
 *  停止加载
 */
- (void)stopLoad;

@end


/**
 *  验证结果代理
 */
@protocol GTViewDelegate <NSObject>

@required

- (void)gtCallFinish:(NSString *)code result:(NSDictionary *)result message:(NSString *)message;

- (void)gtCallClose;

@end