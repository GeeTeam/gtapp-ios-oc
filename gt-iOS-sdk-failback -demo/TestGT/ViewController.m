//
//  ViewController.m
//  TestGT
//
//  !!! this is a demo app. we just give you a sample in this demo. you can code or change what you need.
//
//  Created by LYJ on 15/6/14.
//  Copyright (c) 2015年 gt. All rights reserved.
//

#import "ViewController.h"
#import "MKNetworkEngine.h"
#import "MBProgressHUD.h"
#import <GTFramework/GTFramework.h>


@interface ViewController () <GTManageDelegate>

@property (nonatomic, strong) GTManager *manager;

@property (nonatomic, strong) UIVisualEffectView *visualEffect;

- (IBAction)testAction:(id)sender;

@end

@implementation ViewController

- (GTManager *)manager{
    if (!_manager) {
        _manager = [GTManager sharedGTManger];
        [_manager debugModeEnable:NO];
        [_manager setGTDelegate:self];
        //在此设置验证背景遮罩的透明度,如果不想要背景遮罩,将此属性设置为0
        _manager.backgroundAlpha = 0.2;
        //开启验证视图的外围阴影
        _manager.cornerViewShadow = NO;
        //验证背景颜色(例:yellow 0xffc832 rgb(255,200,50))
        _manager.colorWithHexInt = 0x0a0a0a;
    }
    return _manager;
}

- (UIVisualEffectView *)visualEffect{
    if (!_visualEffect) {
        _visualEffect = [[UIVisualEffectView alloc] initWithEffect:[UIVibrancyEffect effectForBlurEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]]];
        [_visualEffect setFrame:[[UIScreen mainScreen] bounds]];
    }
    return _visualEffect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)testAction:(id)sender {
    [self requestGTest];
}

/**
 *  向custom服务器请求gt验证
 */
- (void)requestGTest{
    __weak __typeof(self) weakSelf = self;
    
    //MBProgressHUD 是不必要的,仅用于演示
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    /** TODO 在此写入客户端首次向网站主服务端请求gt验证的链接(api_1) (replace demo api_1 with yours)*/
    NSURL *requestGTestURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://webapi.geetest.com/apis/start-mobile-captcha/"]];
    
    [self.manager requestCustomServerForGTest:requestGTestURL
                              timeoutInterval:15.0
                           withHTTPCookieName:@"msid"
                                      options:GTDefaultSynchronousRequest
                            completionHandler:^(NSString *gt_captcha_id, NSString *gt_challenge, NSNumber *gt_success_code) {
                                NSLog(@"sessionID === %@",self.manager.sessionID);
                                
                                if ([gt_success_code intValue] == 1) {
                                    
                                    //根据custom server的返回字段判断是否开启failback
                                    if (gt_captcha_id.length == 32) {
                                        
                                        //打开极速验证，在此处完成gt验证结果的返回
                                        [weakSelf.manager openGTViewAddFinishHandler:^(NSString *code, NSDictionary *result, NSString *message) {
                                            
                                            if ([code isEqualToString:@"1"]) {
                                                
                                                //在用户服务器进行二次验证(start Secondery-Validate)
                                                [weakSelf seconderyValidate:code result:result message:message];
                                                /**UI请在主线程操作*/
                                            } else {
                                                NSLog(@"code : %@, message : %@",code,message);
                                            }
                                        }closeHandler:^{
                                            //用户关闭验证后执行的方法
//                                            [self removeMBProgressHUD];
                                            NSLog(@"close geetest");
                                        } animated:YES];
                                        
                                    } else {
//                                        [self removeMBProgressHUD];
                                        NSLog(@"invalid geetest ID, please set right ID");
                                    }
                                }else{
                                    //TODO 当极验服务器不可用时，将执行此处网站主的自定义验证方法或者其他处理方法(gt-server is not available, add your handler methods)
                                    /**请网站主务必考虑这一处的逻辑处理，否者当极验服务不可用的时候会导致用户的业务无法正常执行*/
                                    UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                                                      message:@"极验验证服务异常不可用,请准备备用验证"
                                                                                     delegate:self
                                                                            cancelButtonTitle:@"OK"
                                                                            otherButtonTitles:nil, nil];
                                    dispatch_async(dispatch_get_main_queue(), ^{
//                                            [MBProgressHUD hideHUDForView:self.view animated:YES];
                                            [warning show];
                                    });
                                    NSLog(@"极验验证服务暂时不可用,请网站主在此写入启用备用验证的方法");
                                }
    }];
}

/**
 *  二次验证是验证的必要环节,此方法的构造供参考,可根据需求自行调整
 *
 *  @param code    <#code description#>
 *  @param result  <#result description#>
 *  @param message <#message description#>
 */
- (void)seconderyValidate:(NSString *)code result:(NSDictionary *)result message:(NSString *)message {
    if (code && result) {
        @try {
            if ([code isEqualToString:@"1"]) {
                
                //TODO行为判定通过，进行二次验证,替换成你的api_2(replace this demo api_2 with yours)
                /** custom_server_validate_url 网站主部署的二次验证链接 (api_2)*/
                NSString *custom_server_validate_url = @"http://testcenter.geetest.com/gtweb/android_sdk_demo_server_validate/";
                NSDictionary *headerFields = @{@"Content-Type":@"application/x-www-form-urlencoded;charset=UTF-8"};
                MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:nil customHeaderFields:headerFields];
                
                MKNetworkOperation *operation = [engine operationWithURLString:custom_server_validate_url
                                                                        params:result
                                                                    httpMethod:@"POST"];
                
                [operation addCompletionHandler:^(MKNetworkOperation *completedOperation) {
                    
                    if (completedOperation.HTTPStatusCode == 200) {
                        
                        //TODO 二次验证成功后执行的方法(after finish Secondery-Validate, to do something)
                        NSLog(@"client captcha response:%@",completedOperation.responseString);
                        
                        [self showSuccessView:YES];
                    } else {
                        NSLog(@"client captcha response:%@",completedOperation.responseString);
                        
                        [self showSuccessView:NO];
                    }
                
                } errorHandler:^(MKNetworkOperation *completedOperation, NSError *error) {
                    NSLog(@"client captcha response error:%@",error.localizedDescription);
                }];
                
                [engine enqueueOperation:operation];

            } else {
                // TODO 验证失败(Secondery-Validate fail)
                NSLog(@"client captcha failed:\ncode :%@ message:%@ result:%@", code, message, result);
            }
        }
        @catch (NSException *exception) {
            NSLog(@"client captcha exception:%@", exception.description);
        }
        @finally {
//            [self removeMBProgressHUD];
        }
    }
}

- (void)removeMBProgressHUD{
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

- (void)showSuccessView:(BOOL)result{
    
    UIAlertView *seconderyResult = [[UIAlertView alloc] initWithTitle:@"二次验证结果"
                                                              message:result?@"成功":@"失败"
                                                             delegate:self
                                                    cancelButtonTitle:@"确定"
                                                    otherButtonTitles:nil, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [seconderyResult show];
    });
}

#pragma --mark GTManageDelegate

- (void)GTNetworkErrorHandler:(NSError *)error{
    NSLog(@"GTNetWork Error: %@",error.localizedDescription);
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"网络错误"
                                                         message:error.localizedDescription
                                                        delegate:self
                                               cancelButtonTitle:@"确定"
                                               otherButtonTitles:nil, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [errorAlert show];
    });
}

@end
