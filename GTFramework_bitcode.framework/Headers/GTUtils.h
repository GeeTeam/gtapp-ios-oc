//
//  GTUtils.h
//  GTFramework
//
//  Created by LYJ on 15/5/18.
//  Copyright (c) 2015年 gt. All rights reserved.
//

#ifndef GTFramework_GTUtils_h
#define GTFramework_GTUtils_h

#import <UIKit/UIKit.h>

/**
 *  默认failback请求类型选项
 */
typedef NS_ENUM(NSInteger, DefaultRequestTypeOptions) {
    /** Send Synchronous Request */
    GTDefaultSynchronousRequest = 0,
    /** Send Asynchronous Request */
    GTDefaultAsynchronousRequest
};

/**
 *  展示方式
 */
typedef NS_ENUM(NSInteger, GTPresentType) {
    /** 居中展示, 默认 */
    GTPopupCenterType = 0,
    /**
     * @abstract 从底部展示验证, 仅限iPhone竖屏
     *
     * @discussion 当检测到旋转了屏幕, 会自动关闭验证
     */
    GTPopupBottomType
};

typedef NS_ENUM(NSInteger, GTViewHeightConstraintType) {
    /** 默认高度 */
    GTViewHeightConstraintDefault,
    /** 小图有logo */
    GTViewHeightConstraintSmallViewWithLogo,
    /** 小图无logo */
    GTViewHeightConstraintSmallViewWithNoLogo,
    /** 大图有logo */
    GTViewHeightConstraintLargeViewWithLogo,
    /** 大图无logo */
    GTViewHeightConstraintLargeViewWithNoLogo
};

/**
 *  语言选项
 */
typedef NS_ENUM(NSInteger, LanguageType) {
    /** Simplified Chinese */
    LANGTYPE_ZH_CN = 0,
    /** Traditional Chinese */
    LANGTYPE_ZH_TW,
    /** Traditional Chinese */
    LANGTYPE_ZH_HK,
    /** Korean */
    LANGTYPE_KO_KR,
    /** Japenese */
    LANGTYPE_JA_JP,
    /** English */
    LANGTYPE_EN_US,
    /** System language*/
    LANGTYPE_AUTO
};

typedef NS_ENUM(NSInteger, ActivityIndicatorViewType) {
    /** System Indicator Type */
    GTIndicatorSystemType = 0,
    /** Geetest Defualt Indicator Type */
    GTIndicatorDefaultType,
    /** Custom Indicator Type */
    GTIndicatorCustomType,
};

/**
 *  默认验证处理block
 *
 *  @param gt_captcha_id   用于验证的captcha_id
 *  @param gt_challenge    验证的流水号
 *  @param gt_success_code 网站主侦测到极验服务器的状态
 */
typedef void(^GTDefaultCaptchaHandlerBlock)(NSString *gt_captcha_id, NSString *gt_challenge, NSNumber *gt_success_code);

/**
 *  自定义状态指示器的动画实现block
 *
 *  @param layer 状态指示器视图的layer
 *  @param size  layer的大小,默认 {64, 64}
 *  @param color layer的颜色,默认 蓝色 [UIColor colorWithRed:0.3 green:0.6 blue:0.9 alpha:1]
 */
typedef void(^GTIndicatorAnimationViewBlock)(CALayer *layer, CGSize size, UIColor *color);

/**
 *  验证完成回调
 *
 *  @param code    验证结果 1 成功/ 其他 失败
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
 *  关闭验证回调
 */
typedef void(^GTCallCloseBlock)(void);

#endif
