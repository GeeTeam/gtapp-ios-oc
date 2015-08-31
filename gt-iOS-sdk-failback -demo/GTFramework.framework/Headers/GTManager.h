//
//  GTManager.h
//  GTTest
//
//  Created by LYJ on 15/5/14.
//  Copyright (c) 2015年 LYJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTUtils.h"

/**
 * 验证管理器
 */
@interface GTManager : NSObject

/**
 *  第一次向网站主服务器API_1请求返回的cookie里的Session ID
 */
@property (nonatomic, strong) NSString *sessionID; 

/**
 *  验证背景遮罩的透明度,可为空,默认为0,范围为0.0～1.0,超出范围则为1.0
 */
@property (nonatomic, assign) float backgroundAlpha;

/**
 *  验证实例（单例）
 *
 *  @return 单例
 */
+ (instancetype)sharedGTManger;

/**
 *  向CustomServer发送geetest验证请求，如果网站主服务器判断geetest服务可用，返回customRetDict，否则返回nil
 *
 *  @param requestCustomServerForGTestURL 客户端向网站主服务端发起验证请求的链接(api_1)
 *
 *  @return 只有当网站主服务器可用时，返回customRetDict，否则返回nil
            {
            "challenge": "12ae1159ffdfcbbc306897e8d9bf6d06" ,
            "gt"       : "ad872a4e1a51888967bdb7cb45589605" ,
            "success"  : 1
            }
 */
- (NSDictionary *)requestCustomServerForGTest:(NSURL *)requestCustomServerForGTestURL;

/**
 *  测试用户端与极验服务连接是否畅通可用,如果直接使用此方法来判断是否开启验证,则会导致当极验验证动态服务器宕机的情况下无法正常进行极验验证
 *
 *  @param captcha_id 分配的captcha_id
 *
 *  @return YES则服务可用；NO则不可用
 */
- (BOOL)serverStatusWithCaptcha_id:(NSString *)captcha_id;

/**
 *  展示验证
 *  实现方式 直接在 keyWindow 上添加遮罩视图、极验验证的UIWebView视图
 *  极速验证UIWebView通过JS与SDK通信
 *  
 *
 *  @param finish 验证返回结果
 *  @param close  关闭验证
 */
- (void)openGTViewAddFinishHandler:(GTCallFinishBlock)finish closeHandler:(GTCallCloseBlock)close;

/**
 *  若验证显示则关闭验证界面
 */
- (void)closeGTViewIfIsOpen;

@end
