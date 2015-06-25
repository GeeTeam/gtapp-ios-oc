//
//  GTUtils.h
//  GTFramework
//
//  Created by LYJ on 15/5/18.
//  Copyright (c) 2015年 gt. All rights reserved.
//

#ifndef GTFramework_GTUtils_h
#define GTFramework_GTUtils_h

/**
 *  验证完成回调
 *
 *  @param code    验证结果 0 成功/ 其他 失败
 *  @param result  返回二次验证所需数据
                     {
                     "geetest_challenge": "5a8c21e206f5f7ba4fa630acf269d0ec4z",
                     "geetest_validate": "f0f541006215ac784859e29ec23d5b97",
                     "geetest_seccode": "f0f541006215ac784859e29ec23d5b97|jordan"
                     }
 *  @param message 验证结果信息 （sucess/fail）
 */
typedef void(^GTCallFinishBlock)(NSString *code, NSDictionary *result, NSString *message);

/**
 * 关闭验证
 */
typedef void(^GTCallCloseBlock)(void);

#endif
