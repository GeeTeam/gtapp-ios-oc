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
    [self requestGTest];
}

//向custom服务器请求gt验证
- (void)requestGTest{
    __weak __typeof(self) weakSelf = self;
    
    /* TODO 在此写入客户端首次向网站主服务端请求gt验证的链接(api_1) */
    NSURL *requestGTestURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://testcenter.geetest.com/gtweb/start_mobile_captcha/"]];

    GTManager *manger = [GTManager sharedGTManger];
    
    NSDictionary *retDict = [[NSDictionary alloc] init];
    //获取返回的json数据转字典
    retDict = [manger requestCustomServerForGTest:requestGTestURL];
    NSString *GT_captcha_id = [retDict objectForKey:@"gt"];
    NSNumber *gt_success = [retDict objectForKey:@"success"];
    
    NSLog(@"从网站主服务器获取的id === %@",GT_captcha_id);
    
    if ([gt_success intValue] == 1 ) {
        //根据custom server的返回字段判断是否开启failback
        if (GT_captcha_id != nil) {
            
            //打开极速验证，在此处完成gt验证结果的返回
            [manger openGTViewAddFinishHandler:^(NSString *code, NSDictionary *result, NSString *message) {
                
                if ([code isEqualToString:@"1"]) {
                    // TODO 在用户服务器进行二次验证
                    [weakSelf gttest:code result:result message:message];
                } else {
                    NSLog(@"validate Fail, code === %@",code);
                }
                
            } closeHandler:^{
                //用户关闭验证后执行的方法
                
            }];
        } else {
            // TODO 使用自己的验证码体系来进行判断，或者不做任何处理
            NSLog(@"请求验证初始化失败");
        }
    }else{
     //TODO 极验服务器不可用，在此处写入网站主的自定义验证方法
        
    }
    
}

/**
 *  二次验证
 *
 *  @param code    <#code description#>
 *  @param result  <#result description#>
 *  @param message <#message description#>
 */
- (void)gttest:(NSString *)code result:(NSDictionary *)result message:(NSString *)message {
    if (code && result) {
        @try {
            if ([code isEqualToString:@"1"]) {
                // TODO 验证成功，进行二次验证
                
                /* custom_server_validate_url 网站主部署的二次验证链接 (api_2)*/
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
