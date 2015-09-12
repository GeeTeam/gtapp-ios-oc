//
//  ViewController.m
//  TestGT
//
//  Created by LYJ on 15/6/14.
//  Copyright (c) 2015年 gt. All rights reserved.
//

#import "ViewController.h"
#import "MKNetworkEngine.h"
#import <GTFramework/GTFramework.h>


@interface ViewController ()<UIWebViewDelegate, UISearchBarDelegate>

- (IBAction)testAction:(id)sender;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

- (IBAction)testAction:(id)sender {
    __weak __typeof(self) weakSelf = self;

    
    // TODO 使用申请的极速验证应用公钥
    static NSString * const GT_captcha_id =  @"ad872a4e1a51888967bdb7cb45589605";
    
    GTManager *manager = [GTManager sharedGTManger];
    
    //检测极速验证服务器是否畅通（可添加请求提示）
    if ([manager serverStatusWithCaptcha_id:GT_captcha_id]) {
        
        //打开极速验证
        [manager openGTViewAddFinishHandler:^(NSString *code, NSDictionary *result, NSString *message) {
            if ([code isEqualToString:@"1"]) {
                // TODO 可进行二次验证
                [weakSelf gttest:code result:result message:message];
            } else {
                
            }
        } closeHandler:^{
            
        }];
    } else {
        // TODO 使用自己的验证码体系来进行判断。或者不做任何处理
    }
}


- (void)gttest:(NSString *)code result:(NSDictionary *)result message:(NSString *)message {
    if (code && result) {
        @try {
            if ([code isEqualToString:@"1"]) {
                // TODO 验证成功，可进行二次验证
                NSString *custom_server_validate_url = @"http://testcenter.geetest.com/gtweb/android_sdk_demo_server_validate/";
                NSDictionary *headerFields = @{@"Content-Type":@"application/x-www-form-urlencoded;charset=UTF-8"};
                MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:nil customHeaderFields:headerFields];
                
                MKNetworkOperation *operation = [engine operationWithURLString:custom_server_validate_url params:result httpMethod:@"POST"];
                
                [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
                    if (completedOperation.HTTPStatusCode == 200) {
                        NSLog(@"client captcha response:%@",completedOperation.responseString);
                    } else {
                        NSLog(@"client captcha response:%@",completedOperation.responseString);
                    }
                } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
                    NSLog(@"client captcha response error:%@",error.localizedDescription);
                }];
                [engine enqueueOperation:operation];

            } else {
                // TODO 验证失败
                NSLog(@"client captcha failed:\ncode :%@ message:%@ result:%@", code, message, result);
            }
        }
        @catch (NSException *exception) {
            NSLog(@"client captcha exception:%@", exception.description);
        }
        @finally {
            
        }
    }
}

@end
