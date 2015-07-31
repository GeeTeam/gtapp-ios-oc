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
    [self askGTest];
}

//向custom服务器询问gt验证
- (void)askGTest{
    __weak __typeof(self) weakSelf = self;
    
    /* TODO 在此写入客户端首次向用户服务端请求gt验证模块(api_1) */
    NSURL *askGTestURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://testcenter.geetest.com/gtweb/start_mobile_captcha/"]];

    GTManager *manger = [GTManager sharedGTManger];
    
    NSString *gt_id = [manger askCustomServerForGTest:askGTestURL];
    NSString * GT_captcha_id = gt_id;
    NSLog(@"从用户服务器获取的id === %@",GT_captcha_id);
    
    //
    if (GT_captcha_id != nil) {
        //GT_captcha_id不为空，
        
        //检测极速验证服务器是否畅通（可添加请求提示）
        if ([manger serverStatusWithCaptcha_id:GT_captcha_id]) {
            
            //打开极速验证，在此处完成gt验证结果的返回
            [manger openGTViewAddFinishHandler:^(NSString *code, NSDictionary *result, NSString *message) {
                if ([code isEqualToString:@"1"]) {
                    // TODO 可进行二次验证
                    [weakSelf gttest:code result:result message:message];
                } else {
                    
                }
            } closeHandler:^{
                //用户关闭验证后执行的方法
                
            }];
        } else {
            // TODO 使用自己的验证码体系来进行判断，或者不做任何处理
            
        }
        
    }else{
        //TODO Failback
        if (0) {
            //默认failback备用验证
            
        }else{
            //用户自定义验证
            
        }
    }
    
}

- (void)gttest:(NSString *)code result:(NSDictionary *)result message:(NSString *)message {
    if (code && result) {
        @try {
            if ([code isEqualToString:@"1"]) {
                // TODO 验证成功，进行二次验证
                
                /* custom_server_validate_url 为用户部署的二次验证链接 (api_2)*/
                NSString *custom_server_validate_url = @"http://testcenter.geetest.com/gtweb/android_sdk_demo_server_validate/";
                NSDictionary *headerFields = @{@"Content-Type":@"application/x-www-form-urlencoded;charset=UTF-8"};
                MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:nil customHeaderFields:headerFields];
                
                MKNetworkOperation *operation = [engine operationWithURLString:custom_server_validate_url params:result httpMethod:@"POST"];
                
                [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
                    if (completedOperation.HTTPStatusCode == 200) {
                        //TODO 二次验证成功后执行的方法
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
