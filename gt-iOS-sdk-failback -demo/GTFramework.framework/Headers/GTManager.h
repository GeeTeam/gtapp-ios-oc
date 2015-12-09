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
 *  第一次向网站主服务器API_1请求返回的cookie里的Session ID,仅在默认failback可用
 */
@property (nonatomic, strong) NSString *sessionID;

/**
 *  验证背景的16进制颜色,例如灰色:0xa0a0a0,对应rgb颜色(160,160,160)
    范围为:0x000000~0xffffff,请慎用此属性
 */
@property (nonatomic, assign) int colorWithHexInt;

/**
 *  验证背景遮罩的透明度,默认为0,范围为0.0～1.0,超出范围则为1.0
 */
@property (nonatomic, assign) float backgroundAlpha;

/**
 *  验证背景窗口的阴影
 */
@property (nonatomic, assign) BOOL cornerViewShadow;

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
 *  @param name                           网站主http cookie name的键名
 *
 *  @return 只有当网站主服务器可用时，返回customRetDict，否则返回nil
            {
            "challenge": "12ae1159ffdfcbbc306897e8d9bf6d06" ,
            "gt"       : "ad872a4e1a51888967bdb7cb45589605" ,
            "success"  : 1
            }
 */
- (NSDictionary *)requestCustomServerForGTest:(NSURL *)requestCustomServerForGTestURL withHTTPCookieName:(NSString *)name;

/**
 *  **仅允许在debugMode下调用**
 *  测试用户端与极验服务连接是否畅通可用,如果直接使用此方法来判断是否开启验证,则会导致当极验验证动态服务器宕机的情况下无法正常进行极验验证。
 *  此方法仅用于debugMode
 *
 *  @param captcha_id 分配的captcha_id
 *
 *  @return YES则服务可用；NO则客户端与geetest服务端之间连接不通畅
 */
- (BOOL)serverStatusWithCaptcha_id:(NSString *)captcha_id;

/**
 *  当网站主使用自己的failback逻辑的时候使用此方法开启验证
 *  使用此方法之前，网站主必须在服务端测试geetest服务可用性然后通知客户端
 *  此方法与方法requestCustomServerForGTest:二选一
 *
 *  @param captcha_id   在官网申请的captcha_id
 *  @param gt_challenge 从geetest服务器获取的challenge
 *  @param success      网站主服务器监测geetest服务的可用状态
 *  @param name         网站主http cookie name的键名
 *
 *  @return YES可开启验证，NO则客户端与geetest服务端之间连接不通畅
 */
- (BOOL)requestGTest:(NSString *)captcha_id challenge:(NSString *)gt_challenge success:(NSNumber *)successCode;

/**
 *  展示验证
 *  实现方式 直接在 keyWindow 上添加遮罩视图、极验验证的UIWebView视图
 *  极速验证UIWebView通过JS与SDK通信
 *
 *  @param finish 验证返回结果
 *  @param close  关闭验证
 *  @param animated 开启验证的动画
 */
- (void)openGTViewAddFinishHandler:(GTCallFinishBlock)finish closeHandler:(GTCallCloseBlock)close animated:(BOOL)animated;

/**
 *  若验证显示则关闭验证界面
 */
- (void)closeGTViewIfIsOpen;

/**
 *  开启debugMode,在开启验证之前调用此方法
 *
 *  @param debugModeAvailable YES开启,NO关闭
 */
- (void)debugModeEnable:(BOOL)debugEnable;

@end
