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
 *  验证实例（单例）
 *
 *  @return 单例
 */
+ (instancetype)sharedGTManger;

/**
 *  向CustomServer发送geetest验证请求，如果网站主服务器判断geetest服务可用，customRetDict，否则返回nil
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
