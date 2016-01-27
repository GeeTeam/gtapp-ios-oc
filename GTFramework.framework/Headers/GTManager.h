//
//  GTManager.h
//  GTTest
//
//  Created by LYJ on 15/5/14.
//  Copyright (c) 2015年 LYJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTUtils.h"

@protocol GTManageDelegate <NSObject>

@required
/**
 *  验证错误的处理方法
 *  主要捕捉网络错误和Json解析错误, 详见在线文档说明
 *  https://github.com/GeeTeam/gtapp-ios-oc/blob/master/gt-iOS-sdk-failback%20-demo/geetest_ios_dev.rst
 *
 *  @param error 错误源
 */
- (void)GTNetworkErrorHandler:(NSError *)error;

@end

/**
 * 验证管理器
 */
@interface GTManager : NSObject

/**
 *  验证网络错误的代理
 */
@property (nonatomic, weak) id<GTManageDelegate> GTDelegate;

/**
 *  验证的显示状态
 *  此属性告知验证是否在执行
 */
@property (nonatomic, assign) BOOL operated;

/**
 *  第一次向网站主服务器API_1请求返回的cookie里的Session ID,仅在默认failback可用
 */
@property (nonatomic, strong) NSString *sessionID;

/**
 *  验证背景颜色
 */
@property (nonatomic, strong) UIColor *backgroundColor;

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
 *  @abstract 默认配置验证方法
 *
 *  @discussion
 *  向CustomServer发送geetest验证请求，如果网站主服务器判断geetest服务可用，返回验证必要的数据，否则通过错误代理方法里给出错误信息。
 *
 *  ❗️适合没有自己的灾难防备策略的网站主
 *
 *  @seealso
 *  ❗️此方法与 requestGTest:challenge:success: 方法二选一
 *
 *  @param requestCustomServerForGTestURL   客户端向网站主服务端发起验证请求的链接(api_1)
 *  @param timeoutInterval                  超时间隔
 *  @param name                             网站主http cookie name的键名,用于获取sessionID,如果不需要可为nil
 *  @param RequestType                      请求的类型
 *  @param handler                          请求完成后的处理(主线程)
 *
 *  @return 只有当网站主服务器可用时, 以block的形式返回以下数据
            {
            "gt_challenge"      : "12ae1159ffdfcbbc306897e8d9bf6d06" ,
            "gt_captcha_id"     : "ad872a4e1a51888967bdb7cb45589605" ,
            "gt_success_code"   : 1
            }
 */
- (void)requestCustomServerForGTest:(NSURL *)requestCustomServerForGTestURL
                    timeoutInterval:(NSTimeInterval)timeoutInterval
                 withHTTPCookieName:(NSString *)name
                            options:(DefaultRequestTypeOptions)RequestType
                  completionHandler:(GTDefaultCaptchaHandlerBlock)handler;

/**
 *  @abstract 取消异步请求。
 *
 *  @discussion
 *  当希望取消正在执行的 Default Asynchronous Request时，调用此方法取消。
 *  ❗️有且仅当使用默认异步请求可以调用该方法。
 */
- (void)cancelRequest;

/**
 *  @abstract 自定义配置验证方法
 *  
 *  @discussion
 *  当网站主使用自己的failback逻辑的时候使用此方法开启验证
 *  使用此方法之前，网站主必须在服务端测试geetest服务可用性然后通知客户端
 *
 *  ❗️适合有自己灾难防备策略的网站主
 *
 *  @seealso
 *  ❗️此方法与方法 requestCustomServerForGTest:timeoutInterval:withHTTPCookieName:options:completionHandler:二选一
 *
 *  @param captcha_id   在官网申请的captcha_id
 *  @param gt_challenge 根据极验服务器sdk生成的challenge
 *  @param success      网站主服务器监测geetest服务的可用状态 0/1 不可用/可用
 *
 *  @return YES可开启验证，NO则客户端与geetest服务端之间连接不通畅
 */
- (BOOL)requestGTest:(NSString *)captcha_id
           challenge:(NSString *)gt_challenge
             success:(NSNumber *)successCode;

/**
 *  ❗️必要方法❗️
 *  @abstract 展示验证
 *
 *  @discussion
 *  实现方式 直接在 keyWindow 上添加遮罩视图、极验验证的UIWebView视图
 *  极验验证UIWebView通过JS与SDK通信
 *
 *  @param finish   验证返回后的处理(非主线程)
 *  @param close    关闭验证的处理(非主线程)
 *  @param animated 开启验证的动画
 */
- (void)openGTViewAddFinishHandler:(GTCallFinishBlock)finish
                      closeHandler:(GTCallCloseBlock)close
                          animated:(BOOL)animated;

/**
 *  (非必要方法)
 *  @abstract 只使用id配置验证
 *
 *  @discussion
 *  测试用户端与极验服务连接是否畅通可用,如果直接使用此方法来判断是否开启验证,则会导致当极验验证动态服务器宕机的情况下无法正常进行极验验证。
 *  ❗️此方法仅允许在debugMode可用,用于测试
 *
 *  @param captcha_id 分配的captcha_id
 *
 *  @return YES则服务可用；NO则客户端与geetest服务端之间连接不通畅
 */
- (BOOL)serverStatusWithCaptcha_id:(NSString *)captcha_id;

/**
 *  若验证显示则关闭验证界面
 */
- (void)closeGTViewIfIsOpen;

/**
 *  (非必要方法)
 *  @abstract 配置状态指示器
 *
 *  @discussion
 *  为了能方便的调试动画,真机调试模拟低速网络 Settings->Developer->Status->Enable->Edge(E网,2.5G😂)
 *
 *  @param animationBlock 自定义时需要实现的动画block,仅在type配置为GTIndicatorCustomType时才执行
 *  @param type           状态指示器的类型
 */
- (void)configureAnimatedAcitvityIndicator:(GTIndicatorAnimationViewBlock)animationBlock
             withActivityIndicatorViewType:(ActivityIndicatorViewType)type;

/**
 *  (非必要方法)
 *  @abstract 使用HTTPS协议请求验证
 *
 *  @discussion
 *  默认不开启
 *
 *  @param secured 是否需要https支持
 */
- (void)useSecurityAuthentication:(BOOL)secured;

/**
 *  (非必要方法)
 *  @abstract 切换验证语言
 *
 *  @discussion
 *  默认中文
 *
 *  @param Type 语言类型
 */
- (void)languageSwitch:(LanguageType)Type;

/**
 *  (非必要方法)
 *  @abstract Debug Mode
 *
 *  @discussion
 *  开启debugMode,在开启验证之前调用此方法
 *  默认不开启
 *
 *  @param debugModeAvailable YES开启,NO关闭
 */
- (void)debugModeEnable:(BOOL)debugEnable;

@end
