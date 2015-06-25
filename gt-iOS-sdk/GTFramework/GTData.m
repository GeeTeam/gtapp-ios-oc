//
//  GTData.m
//  GTTest
//
//  Created by LYJ on 15/5/14.
//  Copyright (c) 2015年 LYJ. All rights reserved.
//

#import "GTData.h"

#include <sys/socket.h>
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

@interface GTData ()

@property (nonatomic, strong) NSMutableDictionary *mobileInfo;

/**
 * 识别屏幕分辨率
 */
+ (NSString *)screen;

/**
 * 发布版本
 */
+ (NSString *)buildVersionRelease;

/**
 * 版本
 */
+ (NSString *)buildVersion;


/**
 * 系统
 */
+ (NSString *)osType;

/**
 * 设备系统
 */
+ (NSString *)systemVersion;


@end

@implementation GTData

- (instancetype)init {
    self = [super init];
    if (self) {

    }
    return self;
}

- (NSMutableDictionary *)mobileInfo {
    if (!_mobileInfo) {
        _mobileInfo = [@{@"mType" : [GTData osType],
                         @"mScreen" : [GTData screen],
                         @"osType" : @"ios",
                         @"osVerRelease" : [GTData systemVersion],
                         @"osVerInt" : [GTData systemVersion],
                         @"hAppVerCode" : [GTData buildVersion],
                         @"hAppVerName" : [GTData buildVersionRelease],
                         @"gsdkVerCode" : @"2.15.5.15.1",
                         @"imei" : @"000000000000000" } mutableCopy];
    }
    return _mobileInfo;
}

- (NSString *)mobile {
    NSMutableDictionary *mobileDictionarys = [self mobileInfo];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mobileDictionarys
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

+ (NSString *)systemVersion {
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion];
    return systemVersion;
}

+ (NSString *)osType {
    NSString *model = [[UIDevice currentDevice] model];
    return model;
}

+ (NSString *)buildVersionRelease {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version =[infoDict objectForKey:@"CFBundleShortVersionString"];
    return version;
}

+ (NSString *)buildVersion {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version =[infoDict objectForKey:@"CFBundleVersion"];
    return version;
}

+ (NSString *)screen {
    CGRect rect_screen = [[UIScreen mainScreen]bounds];
    CGSize size_screen = rect_screen.size;
    CGFloat scale_screen = [UIScreen mainScreen].scale;
    NSString *screenString = [NSString stringWithFormat:@"%0.fx%0.f",size_screen.width*scale_screen,size_screen.height*scale_screen];
    return screenString;
}

@end
