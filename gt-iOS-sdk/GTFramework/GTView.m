//
//  GTView.m
//  GTTest
//
//  Created by LYJ on 15/5/14.
//  Copyright (c) 2015年 LYJ. All rights reserved.
//

#import "GTView.h"
#import "GTData.h"
#import <JavaScriptCore/JavaScriptCore.h>  

/**
 * 将实现JSExport 协议的对象直接赋值给JSContext 对象的属性即可暴露方法给JavaScript.
 *
 * 暴露方法 gtCloseWindow，gtCallBack
 * （参考：http://www.bkjia.com/Androidjc/935794.html）
 **/


/**
 * 实现JSExport协议 (GTCall)
 * 暴露方法 gtCloseWindow，gtCallBack
 */
@protocol GTCall <JSExport>

//关闭验证界面
- (void)gtCloseWindow;

//返回验证结果
- (void)gtCallBack:(JSValue *)code :(JSValue *)result :(JSValue *)message;

@end

/**
 * 实现JSExport协议的类
 *
 * WBNativeApis遵循GTCall协议
 */
@interface WBNativeApis : NSObject <GTCall>

@property (nonatomic, weak) id<GTViewDelegate>gtdelegate;

//结果
@property (nonatomic, copy) GTCallFinishBlock callFinishBlock;

//关闭
@property (nonatomic, copy) GTCallCloseBlock callCloseBlock;

@end

@implementation WBNativeApis

- (void)gtCloseWindow {
    if (_gtdelegate) {
        if ([_gtdelegate respondsToSelector:@selector(gtCallClose)]) {
            [_gtdelegate gtCallClose];
        }
    }
}

- (void)gtCallBack:(JSValue *)code :(JSValue *)result :(JSValue *)message {
    NSString *r_code = [code toString];
    NSString *r_result = [result toString];
    NSString *r_message = [message toString];
    NSData* data = [r_result dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    NSDictionary *dictionary  = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if (error || !dictionary) {
        dictionary = @{};
    }
    if (_gtdelegate) {
        if ([_gtdelegate respondsToSelector:@selector(gtCallFinish:result:message:)]) {
            [_gtdelegate gtCallFinish:r_code result:dictionary message:r_message];
        }
    }
}

@end


@interface GTView ()<UIWebViewDelegate, GTViewDelegate>

@property (nonatomic, strong) UIActivityIndicatorView *activeIndicatorView;
@property (nonatomic, strong) UILabel *activeAlertLabel;

- (void)updateLoadingState:(BOOL)loadingState;

@end

@implementation GTView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView.scrollEnabled = NO;
    }
    return self;
}

#pragma mark -- GTViewDelegate

- (void)gtCallFinish:(NSString *)code result:(NSDictionary *)result message:(NSString *)message{
    if (_gtdelegate) {
        if ([_gtdelegate respondsToSelector:@selector(gtCallFinish:result:message:)]) {
            [_gtdelegate gtCallFinish:code result:result message:message];
        }
    }
}

- (void)gtCallClose {
    if (_gtdelegate) {
        if ([_gtdelegate respondsToSelector:@selector(gtCallClose)]) {
            [_gtdelegate gtCallClose];
        }
    }
}

#pragma mark -- load

- (void)startLoadWithCaptcha_id:(NSString *)the_captcha_id {
    [self stopLoad];
    
    [self setDelegate:self];
    
    //验证地址
    NSString *urlString = [NSString stringWithFormat:@"http://static.geetest.com/static/appweb/ios-index.html"];
    
    //验证参数（参数做NSUTF8StringEncoding转码）
    // width 为展示极速验证视图的UIWebView宽度
    GTData *data  = [[GTData alloc] init];
    NSString *encodedString = [[NSString stringWithFormat:@"gt=%@&mobile_info=%@&width=%.0f",the_captcha_id, [data mobile], CGRectGetWidth(self.bounds)] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString *urls = [NSString stringWithFormat:@"%@?%@", urlString, encodedString];
    
    NSURL* url = [NSURL URLWithString:urls];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:0] ;
    [self loadRequest:request];
    
    [self updateLoadingState:YES];

    //初始化JSContext对象
    JSContext *jsContext = [self valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    //初始化实现JSExport 协议的对象
    //设置验证结果和关闭的回调代理
    WBNativeApis *nativeApis = [[WBNativeApis alloc] init];
    nativeApis.gtdelegate = self;
    
    //将实现JSExport 协议的对象直接赋值给JSContext 对象的属性
    //暴露方法给JavaScript
    jsContext[@"android"] = nativeApis;
}

- (void)stopLoad {
    if (self.isLoading) {
        [self stopLoad];
        [self updateLoadingState:NO];
    }
}

- (void)updateLoadingState:(BOOL)loadingState {
    if (!_activeIndicatorView) {
        _activeIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [_activeIndicatorView setHidesWhenStopped:YES];
        [_activeIndicatorView stopAnimating];
    }
    if (!loadingState) {
        [_activeIndicatorView stopAnimating];
        [_activeIndicatorView removeFromSuperview];
    } else {
        [self addSubview:_activeIndicatorView];
        CGRect frame = _activeIndicatorView.frame;
        frame.origin.x = (CGRectGetWidth(self.frame)-CGRectGetWidth(frame))/2.0;
        frame.origin.y = (CGRectGetHeight(self.frame)-CGRectGetHeight(frame))/2.0;
        [_activeIndicatorView setFrame:frame];
        [_activeIndicatorView startAnimating];
    }
}

#pragma mark -- UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self updateLoadingState:NO];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [self updateLoadingState:NO];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    return YES;
}

@end
