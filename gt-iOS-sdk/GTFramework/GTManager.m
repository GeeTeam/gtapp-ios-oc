//
//  GTManager.m
//  GTTest
//
//  Created by LYJ on 15/5/14.
//  Copyright (c) 2015年 LYJ. All rights reserved.
//

#import "GTManager.h"
#import "GTView.h"

@interface GTManager ()<GTViewDelegate>

/**
 * 遮罩视图
 */
@property (nonatomic, strong) UIControl *backGroundView;

/**
 * 圆角视图
 */
@property (nonatomic, strong) UIView *cornerView;

/**
 * 验证视图
 */
@property (nonatomic, strong) GTView *gtView;

/**
 *   展示验证视图
 *
 *  @param captcha_id 应用公钥
 */
- (void)showGTView:(NSString *)captcha_id;

- (void)applicationDidChangeStatusBarOrientation ;

@property (nonatomic, assign) BOOL shown;
@property (nonatomic, strong) NSString *captcha_id;

// 验证结果
@property (nonatomic, copy) GTCallFinishBlock finish;

// 验证关闭
@property (nonatomic, copy) GTCallCloseBlock close;

@end


@implementation GTManager

static CGRect s320480 = {{0, 0}, {320, 480}};
static CGRect s480320 = {{0, 0}, {480, 320}};

static CGRect s320568 = {{0, 0}, {320, 568}};
static CGRect s568320 = {{0, 0}, {568, 320}};

static CGRect s375667 = {{0, 0}, {375, 667}};
static CGRect s667375 = {{0, 0}, {667, 375}};

static CGRect s414736 = {{0, 0}, {414, 736}};
static CGRect s736414 = {{0, 0}, {736, 414}};

static CGRect s7681024 = {{0, 0}, {1024, 1024}};
static CGRect s1024768 = {{0, 0}, {768, 768}};
static CGRect s15362048 = {{0, 0}, {1536, 2048}};
static CGRect s20481536 = {{0, 0}, {2048, 1536}};

static CGRect g1 = {{0, 0}, {280, 330}};
static CGRect g2 = {{0, 0}, {328, 387}};
static CGRect g3 = {{0, 0}, {363, 427}};

#define UIColorFromRGB(rgbValue ,alphaValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:((alphaValue>=0 && alphaValue <=1.0) ? alphaValue : 1.0)]

#pragma mark -- 初始化

__strong static id sharedGTManger = nil;

+ (instancetype)sharedGTManger {
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        sharedGTManger = [[GTManager alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:sharedGTManger selector:@selector(applicationDidChangeStatusBarOrientation) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    });
    return sharedGTManger;
}

+ (id)allocWithZone:(NSZone *)zone{
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        if (sharedGTManger == nil) {
            sharedGTManger = [super allocWithZone:zone];
        }
    });
    return sharedGTManger;
}

- (id)copyWithZone:(NSZone *)zone{
    return sharedGTManger;
}

/**
 *  设计尺寸
 *
 *  @param screen 屏幕尺寸
 *
 *  @return 依据屏幕尺寸设计的最佳展示尺寸
 */
- (CGRect)getMainRectFromScreen:(CGRect)screen {
    if (CGRectEqualToRect(screen, s320480) ||
        CGRectEqualToRect(screen, s480320) ||
        CGRectEqualToRect(screen, s320568) ||
        CGRectEqualToRect(screen, s568320)) {
        return g1;
    }
    if (CGRectEqualToRect(screen, s375667) ||
        CGRectEqualToRect(screen, s667375)) {
        return g2;
    }
    if (CGRectEqualToRect(screen, s414736) ||
        CGRectEqualToRect(screen, s736414)) {
        return g3;
    }
    if (CGRectEqualToRect(screen, s7681024) ||
        CGRectEqualToRect(screen, s1024768) ||
        CGRectEqualToRect(screen, s15362048) ||
        CGRectEqualToRect(screen, s20481536)) {
        return g2;
    }
    return g2;
}

/**
 *  锁屏遮罩
 *
 *  @return 锁屏遮罩（点击隐藏）
 */
- (UIControl *)backGroundView {
    if (!_backGroundView) {
        CGRect mainFrame = [[UIScreen mainScreen] bounds];
        _backGroundView = [[UIControl alloc] initWithFrame:mainFrame];
        [_backGroundView setBackgroundColor:UIColorFromRGB(0xa0a0a0, 0.3)];
        [_backGroundView setUserInteractionEnabled:YES];
    }
    return _backGroundView;
}

- (UIView *)cornerView {
    if (!_cornerView) {
        CGRect mainFrame = [[UIScreen mainScreen] bounds];
        CGRect cFrame = [self getMainRectFromScreen:mainFrame];
        _cornerView = [[UIControl alloc] initWithFrame:cFrame];
        [_cornerView setBackgroundColor:[UIColor whiteColor]];
        [_cornerView setUserInteractionEnabled:YES];
        
        [_cornerView setClipsToBounds:NO];
        [_cornerView.layer setCornerRadius:7.0];
        
        [_cornerView.layer setMasksToBounds:NO];
        _cornerView.layer.shadowColor = UIColorFromRGB(0xb2afaf, 1.0).CGColor;//shadowColor阴影颜色
        _cornerView.layer.shadowOffset = CGSizeMake(2.5,2.5);//shadowOffset阴影偏移,x向右偏移4，y向下偏移4，默认(0, -3),这个跟shadowRadius配合使用
        _cornerView.layer.shadowOpacity = 0.75;//阴影透明度，默认0
        _cornerView.layer.shadowRadius = 7.0;
    }
    return _cornerView;
}


- (GTView *)gtView {
    if (!_gtView) {
        CGRect mainRect = [[UIScreen mainScreen] bounds];
        CGRect frame = [self getMainRectFromScreen:mainRect];
        _gtView = [[GTView alloc] initWithFrame:frame];
        [_gtView setScalesPageToFit:NO];     //yes:根据webview自适应，NO：根据内容自适应
        [_gtView setClipsToBounds:YES];
        [_gtView.layer setCornerRadius:7.0];
        [_gtView setGtdelegate:self];
        [_gtView setDataDetectorTypes:UIDataDetectorTypeNone];
    }
    return _gtView;
}

#pragma mark -- 测试服务是否可用

- (BOOL)serverStatusWithCaptcha_id:(NSString *)captcha_id {
    [sharedGTManger setCaptcha_id:captcha_id];
    BOOL canbeUsed = NO;

    NSError *error = nil;
    NSHTTPURLResponse *response = nil;
    
    NSURL *sendurl = [NSURL URLWithString:[NSString stringWithFormat:@"http://api.geetest.com/register.php?gt=%@",captcha_id]];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:sendurl cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:3.0];
    NSData *receivedData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (!error && receivedData.length > 0) {
        if (response.statusCode==200) {
            NSString *result  = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
            if (result.length == 32) {
                canbeUsed = YES;
            }
        }
    }
    return canbeUsed;
}


#pragma mark -- 展示验证及结果回调

- (void)openGTViewAddFinishHandler:(GTCallFinishBlock)finish closeHandler:(GTCallCloseBlock)close {
    [self closeGTViewIfIsOpen];
    self.finish = finish;
    self.close = close;
    [self showGTView:[NSString stringWithFormat:@"%@",self.captcha_id]];
}

#pragma mark -- 关闭验证

- (void)closeGTViewIfIsOpen {
    if (_shown) {
        if (self.gtView.isLoading) {
            [self.gtView stopLoading];
        }
        self.gtView.hidden = YES;
        [self.backGroundView removeFromSuperview];
        [self setShown:NO];
    }
    self.gtView.gtdelegate = nil;
    self.gtView = nil;
}

#pragma mark -- 显示验证

- (void)showGTView:(NSString *)captcha_id {
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:self.backGroundView];
    [self.backGroundView addSubview:self.cornerView];
    [self.backGroundView addSubview:self.gtView];
    CGRect mainframe = [[UIScreen mainScreen] bounds];
    [self.backGroundView setFrame:mainframe];
    [self.cornerView setCenter:self.backGroundView.center];
    [self.gtView setCenter:self.backGroundView.center];
    [self.gtView setHidden:NO];
    [self exChangeOut:self.backGroundView dur:0.3];
    [self.gtView startLoadWithCaptcha_id:captcha_id];
    [self setShown:YES];
}

#pragma mark -- GTViewDelegate

- (void)gtCallFinish:(NSString *)code result:(NSDictionary *)result message:(NSString *)message {
    if ([code isEqualToString:@"1"]) {
        [self closeGTViewIfIsOpen];
    }
    if (self.finish) {
        self.finish(code, result, message);
    }
}

- (void)gtCallClose {
    [self closeGTViewIfIsOpen];
    if (self.close) {
        self.close();
    }
}

#pragma mark --

- (void)applicationDidChangeStatusBarOrientation {
    if (_shown) {
        CGRect mainframe = [[UIScreen mainScreen] bounds];
        [self.backGroundView setFrame:mainframe];
        [self.cornerView setCenter:self.backGroundView.center];
        [self.gtView setCenter:self.backGroundView.center];
    }
}

- (void)exChangeOut:(UIView *)changeOutView dur:(CFTimeInterval)dur{
    
    CAKeyframeAnimation * animation;
    animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    animation.duration = dur;
    
//    animation.delegate = self;
    
    animation.removedOnCompletion = NO;
    
    animation.fillMode = kCAFillModeForwards;
    
    NSMutableArray *values = [NSMutableArray array];
    
//    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)]];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.5, 0.5, 0.5)]];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 0.9)]];
    
    [values addObject:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)]];
    
    animation.values = values;
    
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [changeOutView.layer addAnimation:animation forKey:nil];
}

@end
