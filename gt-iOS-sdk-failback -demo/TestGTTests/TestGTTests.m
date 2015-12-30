//
//  TestGTTests.m
//  TestGTTests
//
//  Created by NikoXu on 12/29/15.
//  Copyright © 2015 gt. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GTFramework/GTFramework.h>

@interface TestGTTests : XCTestCase <GTManageDelegate>

@property (nonatomic, strong) GTManager *manager;

@property (nonatomic, strong) NSURL *requestGTestURL;

@property (nonatomic, strong) XCTestExpectation *customExpectation;

@end

@implementation TestGTTests

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

- (NSURL*)requestGTestURL{
    if (!_requestGTestURL) {
        _requestGTestURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://webapi.geetest.com/apis/start-mobile-captcha/"]];
    }
    return _requestGTestURL;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/**
 *  测试默认的failback同步请求
 */
- (void)testDefaultSyncRequestCaptchaData {
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"Check Sync Data"];
    
    [self.manager requestCustomServerForGTest:self.requestGTestURL
                              timeoutInterval:15.0
                           withHTTPCookieName:@"msid"
                                      options:GTDefaultSynchronousRequest
                            completionHandler:^(NSString *gt_captcha_id, NSString *gt_challenge, NSNumber *gt_success_code) {
                                NSLog(@"%@",gt_captcha_id);
                                XCTAssertTrue(gt_captcha_id.length == 32, @"invalid gt id");
                                XCTAssertTrue(gt_challenge.length == 32, @"invalid challenge");
                                XCTAssertTrue([gt_success_code intValue] == 1, @"UNEXCEPTED SUCCESS CODE");
                                [expectation fulfill];
                            }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:nil];
}

/**
 *  测试默认的failback异步请求
 */
- (void)testDefaultAsyncRequestCaptchaData {
    
    XCTestExpectation * expectation = [self expectationWithDescription:@"Check Async Data"];
    
    [self.manager requestCustomServerForGTest:self.requestGTestURL
                              timeoutInterval:15.0
                           withHTTPCookieName:@"msid"
                                      options:GTDefaultAsynchronousRequest
                            completionHandler:^(NSString *gt_captcha_id, NSString *gt_challenge, NSNumber *gt_success_code) {
                                NSLog(@"%@",gt_captcha_id);
                                XCTAssertTrue(gt_captcha_id.length == 32, @"invalid gt id");
                                XCTAssertTrue(gt_challenge.length == 32, @"invalid challenge");
                                XCTAssertTrue([gt_success_code intValue] == 1, @"UNEXCEPTED SUCCESS CODE");
                                [expectation fulfill];
                            }];
    
    [self waitForExpectationsWithTimeout:15.0 handler:nil];
}

/**
 *  测试自定义的failback验证
 */
- (void)testCustomCaptcha{
    
    self.customExpectation = [self expectationWithDescription:@"Test Custom Captcha"];
    //创建请求
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:self.requestGTestURL
                                                  cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData
                                              timeoutInterval:15.0];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * response, NSData * data, NSError * connectionError) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        if (httpResponse.statusCode == 200) {
            
            if (data.length > 0 && !connectionError) {
                
                NSDictionary *customRetDict = [NSJSONSerialization JSONObjectWithData:data
                                                                              options:NSJSONReadingAllowFragments
                                                                                error:nil];
                
                [self performSelectorOnMainThread:@selector(requestGeeTestWithDictionary:) withObject:customRetDict waitUntilDone:YES];
            }
        }else{
            NSLog(@"responseCode : %ld , error : %@", (long)httpResponse.statusCode, connectionError.localizedDescription);
        }
    }];
    
    [self waitForExpectationsWithTimeout:30.0 handler:^(NSError * _Nullable error) {
        NSLog(@"WARNING: You should finish the captcha to complete this test.");
    }];
}

/**
 *  测试错误处理,因为超时错误提示不是也是很难发生的,所以这个测试用例在网络质量好的情况下多是失败的
 */
- (void)testErrorHandle{
    
    [self.manager requestCustomServerForGTest:self.requestGTestURL
                              timeoutInterval:1.0
                           withHTTPCookieName:@"msid"
                                      options:GTDefaultSynchronousRequest
                            completionHandler:nil];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

/**
 *  根据获取的failback验证信息开启验证
 *
 *  @param dic 从服务端解析的数据字典
 */
- (void)requestGeeTestWithDictionary:(NSDictionary *)dic{
    
        /**
         *  对你们服务器返回的数据进行解析
            必要数据：
                    极验验证的服务状态： "success" 表示可用
                    极验验证的验证ID： "ad872a4e1a51888967bdb7cb45589605"
            以下依旧以极验的演示用的测试中心提供的数据为举例
         */
    
    NSString *gt_captcha_id = [dic objectForKey:@"gt"];
    NSString *gt_challenge = [dic objectForKey:@"challenge"];
    NSNumber *gt_success = [dic objectForKey:@"success"];
    NSLog(@"id : %@, challenge : %@",gt_captcha_id,gt_challenge);
    
    //如果failback使用我们的静态验证方式,下面的bool值填入YES/true
    if ([gt_success intValue] == 1) {
        //根据custom server的返回字段判断是否开启failback
        if ([self.manager requestGTest:gt_captcha_id challenge:gt_challenge success: gt_success]) {
            //打开极速验证，在此处完成gt验证结果的返回
            [self.manager openGTViewAddFinishHandler:^(NSString *code, NSDictionary *result, NSString *message) {
                
                if ([code isEqualToString:@"1"]) {
                    //在用户服务器进行二次验证(start Secondery-Validate)
                    NSLog(@"验证成功");
                } else {
                    NSLog(@"code : %@, message : %@",code,message);
                }
                [self.customExpectation fulfill];
            } closeHandler:^{
                //用户关闭验证后执行的方法
                NSLog(@"close geetest");
                [self.customExpectation fulfill];
            } animated:YES];
        } else {
            // TODO 写上检测网络的方法，或者不做任何处理(network error,check your network)
            NSLog(@"连接网站主服务器异常,网络不通畅");
        }
    }else{
        //TODO 当极验服务器不可用时，将执行此处网站主的自定义验证方法或者其他处理方法(gt-server is not available, add your hanle methods)
        /** 请网站主务必考虑这一处的逻辑处理，否者当极验服务不可用的时候会导致用户的业务无法正常执行*/
        NSLog(@"极验验证服务暂时不可用,请网站主在此写入启用备用验证的方法");
    }
    
}

#pragma mark -- GTManageDelegate

- (void)GTNetworkErrorHandler:(NSError *)error{
    if (error.code == NSURLErrorTimedOut) {
        XCTAssertTrue(error.code == -1001, @"it's timeout but show wrong code");
    }else if (error.code == NSURLErrorCannotConnectToHost){
        XCTAssertTrue(error.code == -1004, @"it can't connect to server but show wrong code");
    }else if (error.code == NSURLErrorNotConnectedToInternet){
        XCTAssertTrue(error.code == -1009, @"it can't connect to internet but show wrong code");
    }
}

@end
