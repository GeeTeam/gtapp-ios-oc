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
 *  测试服务是否可用
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
