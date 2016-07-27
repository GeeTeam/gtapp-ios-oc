//
//  ViewController.m
//  TestGT
//
//  !!! this is a demo app. we just give you a sample in this demo. you can code or change what you need.
//
//  Created by LYJ on 15/6/14.
//  Copyright (c) 2015年 gt. All rights reserved.
//

/**
 *  将下面用于演示的的两个接口替换成你们服务端配置的
 *  切勿在正式版本或者发布版本里使用以下两个api, 我们可能在以后的demo版本里修改此处的两个api
 *  并且在标有'TODO'的地方写上你们的处理逻辑
 */
//客户端向网站主服务端请求gt验证的接口(api_1)
#define api_1 @"http://webapi.geelao.ren:8011/gtcap/start-mobile-captcha/"
//网站主部署的二次验证链接 (api_2)
#define api_2 @"http://webapi.geelao.ren:8011/gtcap/gt-server-validate/"


#import "ViewController.h"
#import <GTFramework/GTFramework.h>


@interface ViewController () <GTManageDelegate>

@property (nonatomic, strong) GTManager *manager;

- (IBAction)switchDebugMode:(id)sender;

- (IBAction)testAction:(id)sender;

@end

@implementation ViewController

- (GTManager *)manager {
    if (!_manager) {
        _manager = [GTManager sharedGTManager];
        [_manager setGTDelegate:self];
        
        /** 以下方法按需使用,非必要方法,有默认值 */
        //debug配置
        [_manager enableDebugMode:NO];
        //https配置
        [_manager useSecurityAuthentication:YES];
        //多语言配置
        [_manager languageSwitch:LANGTYPE_AUTO];
        //状态指示器配置
        [_manager configureAnimatedAcitvityIndicator:^(CALayer *layer, CGSize size, UIColor *color) {
            [self setupIndicatorAnimationSample2:layer withSize:size tintColor:color];
        } withIndicatorType:GTIndicatorCustomType];
        //配置布局方式
        [_manager useGTViewWithPresentType:GTPopupCenterType];
        //验证高度约束
        [_manager useGTViewWithHeightConstraintType:GTViewHeightConstraintLargeViewWithLogo];
        //使用背景模糊
        [_manager useVisualViewWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
        //验证背景颜色(例:yellow rgb(255,200,50))
        [_manager setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3]];
        /** 注释在此结束 */
        
    }
    return _manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)switchDebugMode:(id)sender {
    UISwitch *mSwitch = (UISwitch *)sender;
    if (mSwitch.isOn) {
        [self.manager enableDebugMode:YES];
    }else{
        [self.manager enableDebugMode:NO];
    }
}

//验证触发条件, 可以根据业务需求设计
- (IBAction)testAction:(id)sender {
    //dismiss keyboard if there is a keyboard.
    [self.view endEditing:YES];
    [self requestGTest];
}

/**
 *  向custom服务器请求gt验证
 *
 *  @discussion 开启验证前需要向网站主的服务器获取相应的验证数据(id,challenge,success),这块根据用户的网络情况需要若干时间来完成,建议在使用异步请求方式时提供状态指示器以告诉用户验证状态。
 *
 */
- (void)requestGTest {
    
    __weak __typeof(self) weakSelf = self;
    
    /** TODO 在此写入客户端首次向网站主服务端请求gt验证的链接(api_1) (replace demo api_1 with yours)*/
    NSURL *requestGTestURL = [NSURL URLWithString:[NSString stringWithFormat:api_1]];
    
    //验证通过时调用
    GTCallFinishBlock finishBlock = ^(NSString *code, NSDictionary *result, NSString *message) {
        
        if ([code isEqualToString:@"1"]) {
            //在用户服务器进行二次验证(start Secondery-Validate)
            [weakSelf seconderyValidate:code result:result message:message];
            /**UI请在主线程操作*/
            
        }
        else {
            NSLog(@"code : %@, message : %@",code,message);
        }
        
    };
    
    //用户关闭验证时调用
    GTCallCloseBlock closeBlock = ^{
        //用户关闭验证后执行的方法
        NSLog(@"close geetest");
    };
    
    //默认failback处理, 在此打开验证
    GTDefaultCaptchaHandlerBlock defaultCaptchaHandlerBlock = ^(NSString *gt_captcha_id, NSString *gt_challenge, NSNumber *gt_success_code) {
        
        //根据custom server的返回success字段判断是否开启failback
        if ([gt_success_code intValue] == 1) {
            
            if (gt_captcha_id.length == 32) {
                //打开极速验证，在此处完成gt验证结果的返回
                [weakSelf.manager openGTViewAddFinishHandler:finishBlock closeHandler:closeBlock animated:YES];
            }
            else {
                NSLog(@"invalid geetest ID, please set right ID");
            }
            
        }
        else {
            //TODO 当极验服务器不可用时，将执行此处网站主的自定义验证方法或者其他处理方法(gt-server is not available, add your handler methods in here)
            /**请网站主务必考虑这一处的逻辑处理，否者当极验服务不可用的时候会导致用户的业务无法正常执行*/
            UIAlertView *warning = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                              message:@"极验验证服务异常不可用,请准备备用验证"
                                                             delegate:self
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles:nil, nil];
            dispatch_async(dispatch_get_main_queue(), ^{
                [warning show];
            });
            NSLog(@"极验验证服务暂时不可用,请网站主在此写入启用备用验证的方法");
        }
    };
    
    //配置验证, 必须weak, 否则内存泄露
    [weakSelf.manager configureGTest:requestGTestURL
                             timeout:15.0
                      withCookieName:nil
                             options:GTDefaultAsynchronousRequest
                   completionHandler:defaultCaptchaHandlerBlock];
    
}

/**
 *  二次验证是验证的必要环节,此方法的构造供参考,可根据需求自行调整(NSURLSession is just a sample for this demo. You can choose what your like to complete this step.)
 *  考虑到nsurlsession的是苹果推荐的网络库,并且希望开发者了解这块的逻辑以及重要性,而没使用使用大家熟悉的AFNetworking
 *  使用POST请求将 result 以表单格式发送至网站主服务器进行二次验证, 集成极验提供的server sdk会根据提交的数据作出判断并且返回相应的结果
 *
 *  @param code    <#code description#>
 *  @param result  <#result description#>
 *  @param message <#message description#>
 */
- (void)seconderyValidate:(NSString *)code result:(NSDictionary *)result message:(NSString *)message {
    if (code && result) {
        @try {
            if ([code isEqualToString:@"1"]) {
                __block NSMutableString *postResult = [[NSMutableString alloc] init];
                
                //TODO 行为判定通过，进行二次验证,替换成你的api_2(replace this demo's api_2 with yours)
                //‼️请不要在发行版本里使用我们仅供演示的二次验证API, 此API我们可能修改
                /** custom_server_validate_url 网站主部署的二次验证链接 (api_2)*/
                NSString *custom_server_validate_url = api_2;
                NSDictionary *headerFields = @{@"Content-Type":@"application/x-www-form-urlencoded;charset=UTF-8"};
                
                NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:custom_server_validate_url]];
                [result enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [postResult appendFormat:@"%@=%@&",key,obj];
                }];
                NSLog(@"postResult: %@",postResult);
                if (postResult.length > 0) {
                    
                    NSURLSessionConfiguration *configurtion = [NSURLSessionConfiguration defaultSessionConfiguration];
                    configurtion.allowsCellularAccess = YES;
                    configurtion.HTTPAdditionalHeaders = headerFields;
                    configurtion.timeoutIntervalForRequest = 15.0;
                    configurtion.timeoutIntervalForResource = 15.0;
                    
                    NSURLSession *session = [NSURLSession sessionWithConfiguration:configurtion];
                    request.HTTPMethod = @"POST";
                    // demo中与仅仅使用表单格式格式化二次验证数据作为演示, 使用其他的格式也是可以的, 但需要与网站主的服务端沟通好以便提交并解析数据
                    request.HTTPBody = [postResult dataUsingEncoding:NSUTF8StringEncoding];
                    
                    NSURLSessionDataTask *sessionDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        
                        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
                        
                        if (data.length > 0 && !error) {
                            
                            if (httpResponse.statusCode == 200) {
                                
                                // TODO 二次验证成功后执行的方法(after finish Secondery-Validate, to do something)
                                NSError *err = nil;
                                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
                                
                                if (!err) {
                                    
                                    //Demo配套的使用的是python server sdk, response里的返回的是success/fail表示二次验证结果
                                    if ([[dic objectForKey:@"msg"] isEqualToString:@"success"]) {
                                        
                                        // TODO 验证成功(Secondery-Validate success)
                                        NSLog(@"captcha success");
                                        [self showSuccessView:YES];
                                        
                                    }
                                    else {
                                        // TODO 验证失败(Secondery-Validate fail)
                                        [self showSuccessView:NO];
                                        NSLog(@"secondery captcha failed, server response: %@", dic);
                                    }
                                }
                                else {
                                    NSLog(@"JSON Format Error: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
                                }
                                
                            }
                            else {
                                NSLog(@"statusCode: %ld", (long)httpResponse.statusCode);
                            }
                        }
                        else {
                            NSLog(@"error: %@", error.localizedDescription);
                        }
                    }];
                    [sessionDataTask resume];
                    
                    [session finishTasksAndInvalidate];
                }

            } else {
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

/**
 *  custom animation sample
 *
 *  @param layer <#layer description#>
 *  @param size  <#size description#>
 *  @param color <#color description#>
 */
- (void)setupIndicatorAnimationSample2:(CALayer *)layer withSize:(CGSize)size tintColor:(UIColor *)color{
    color = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0];
    NSTimeInterval beginTime = CACurrentMediaTime();
    
    CGFloat oX = (layer.bounds.size.width - size.width) / 2.0f;
    CGFloat oY = (layer.bounds.size.height - size.height) / 2.0f;
    for (int i = 0; i < 4; i++) {
        CALayer *circle = [CALayer layer];
        circle.frame = CGRectMake(oX, oY, size.width, size.height);
        [circle setShouldRasterize:NO];
        [circle setMasksToBounds:NO];
        [circle setContentsScale:[UIScreen mainScreen].scale];
        circle.backgroundColor = color.CGColor;
        circle.anchorPoint = CGPointMake(0.5f, 0.5f);
        circle.opacity = 0.6f;
        circle.cornerRadius = circle.bounds.size.height / 2.0f;
        circle.transform = CATransform3DMakeScale(0.0f, 0.0f, 0.0f);
        
        CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
        transformAnimation.fromValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.0f, 0.0f, 0.0f)];
        transformAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0f, 1.0f, 0.0f)];
        
        CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacityAnimation.fromValue = @(0.7f);
        opacityAnimation.toValue = @(0.0f);
        
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.removedOnCompletion = NO;
        animationGroup.beginTime = beginTime + i * 0.2f;
        animationGroup.repeatCount = HUGE_VALF;
        animationGroup.duration = 1.2f;
        animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        animationGroup.animations = @[transformAnimation, opacityAnimation];
        
        [layer addSublayer:circle];
        [circle addAnimation:animationGroup forKey:@"animation"];
    }
}

//you can kick this method out of your projects
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
    //不推荐直接使用alert将错误弹出, 请对错误做一个判断, 参照开发文档
    //使用alert是为了方便用于演示
    NSLog(@"[GTSDK] Error: %@",error);
    
    if (error.code == -999) {
        //忽略此类型错误, 仅打印
        //用户在加载请求时, 关闭验证可能导致此错误
        NSLog(@"Error: %@", error.localizedDescription);
    }
    else {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"There's a trouble"
                                                             message:error.localizedDescription
                                                            delegate:self
                                                   cancelButtonTitle:@"Ok"
                                                   otherButtonTitles:nil, nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            __weak __typeof(self) weakSelf = self;
            [weakSelf.manager closeGTViewIfIsOpen];
            [errorAlert show];
        });
    }
    
}

@end
