//
//  StoreViewController.m
//  TeamsHit
//
//  Created by 仙林 on 16/10/21.
//  Copyright © 2016年 仙林. All rights reserved.
//

#import "StoreViewController.h"
#import <WebKit/WebKit.h>
#import "WXApi.h"
#import "WXApiManager.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
@interface StoreViewController ()<WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, WXApiManagerDelegate>
{
    MBProgressHUD * hud;
}
@property (nonatomic, strong)WKWebView *webView;
@property (nonatomic, strong)UIProgressView * progressView;
@property (nonatomic, copy)NSString * orderId;
@property (nonatomic, assign)int canusecoin;
@end

@implementation StoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    TeamHitBarButtonItem * leftBarItem = [TeamHitBarButtonItem leftButtonWithImage:[UIImage imageNamed:@"closeStoreImage"] title:@""];
//    self.navigationItem.leftBarButtonItem setCustomView:<#(__kindof UIView * _Nullable)#>
    [leftBarItem addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:leftBarItem];
    self.title = @"对对商城";
    [WXApiManager sharedManager].delegate = self;
    // 创建配置类
    WKWebViewConfiguration * config = [[WKWebViewConfiguration alloc]init];
    config.preferences = [[WKPreferences alloc]init];
    config.preferences.minimumFontSize = 10;
    config.preferences.javaScriptEnabled = YES;
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
    //配置web内容处理池
    config.processPool = [[WKProcessPool alloc] init];
    
    /*
     
     配置Js与Web内容交互
     WKUserContentController是用于给JS注入对象的，注入对象后，JS端就可以使用：
     window.webkit.messageHandlers.<name>.postMessage(<messageBody>)
     
     来调用发送数据给iOS端，比如：
     window.webkit.messageHandlers.AppModel.postMessage({body: '传数据'});
     
     AppModel就是我们要注入的名称，注入以后，就可以在JS端调用了，传数据统一通过body传，可以是多种类型，只支持NSNumber, NSString, NSDate, NSArray,NSDictionary, and NSNull类型。
     
     下面我们配置给JS的main frame注入AppModel名称，对于JS端可就是对象了：
     */
    
    // 通过JS与webview内容交互
    config.userContentController = [[WKUserContentController alloc]init];
    // 注入JS对象名称AppModel，当JS通过AppModel来调用时，
    // 我们可以在WKScriptMessageHandler代理中接收到
    [config.userContentController addScriptMessageHandler:self name:@"AppModel"];
    
    
    if ([self isChinaMobile]) {
        NSLog(@"是中国运营商");
        self.canusecoin = 1;
    }else
    {
        if ([self ishaveWechat]) {
            NSLog(@"不是中国运营商，但是安装有微信");
            self.canusecoin = 1;
        }else
        {
            NSLog(@"不是中国运营商，也没有安装微信");
            self.canusecoin = 0;
        }
    }
    
    // 1.创建webview，并设置大小，"20"为状态栏高度
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 64) configuration:config];
    _webView.UIDelegate = self;
    _webView.navigationDelegate = self;
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self
                   forKeyPath:@"loading"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
    
    NSString * urlStr = [NSString stringWithFormat:@"http://www.wap.mstching.com/account/applogin?username=%@&password=%@&backurl=/?from=app%%26canusecoin=%d",[[NSUserDefaults standardUserDefaults] objectForKey:@"AccountNumber"], [[NSUserDefaults standardUserDefaults] objectForKey:@"Password"], self.canusecoin];
    
    NSLog(@"%@", urlStr);
    
//    WKWebViewConfiguration
//    WKUserContentController
    
    // 2.创建请求
    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
    // 3.加载网页
    [_webView loadRequest:request];
    // 最后将webView添加到界面
    [self.view addSubview:_webView];
    
    self.progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, screenWidth, 1)];
    self.progressView.tintColor = MAIN_COLOR;
    self.progressView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:self.progressView];
    
    hud= [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [hud show:YES];
    
}

// 当JS通过AppModel发送数据到iOS端时，会在代理中收到：
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if ([message.name isEqualToString:@"AppModel"]) {
        // 打印所传过来的参数，只支持NSNumber, NSString, NSDate, NSArray,
        // NSDictionary, and NSNull类型
        NSLog(@"%@", message.body);
        NSString * orderId = [message.body objectForKey:@"body"];
        self.orderId = orderId;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requestOrderInformation:orderId];
        });
        
    }
}


#pragma mark- WKUIDelegate
- (void)webViewDidClose:(WKWebView *)webView
{
    NSLog(@"%s", __FUNCTION__);
}
// 在JS端调用alert函数时，会触发此代理方法。
// JS端调用alert时所传的数据可以通过message拿到
// 在原生得到结果后，需要回调JS，是通过completionHandler回调

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"alert" message:@"JS调用alert" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
    NSLog(@"%@", message);
}
// JS端调用confirm函数时，会触发此方法
// 通过message可以拿到JS端所传的数据
// 在iOS端显示原生alert得到YES/NO后
// 通过completionHandler回调给JS端
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"confirm" message:@"JS调用confirm" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:NULL];
    
    NSLog(@"%@", message);
}
// JS端调用prompt函数时，会触发此方法
// 要求输入一段文本
// 在原生输入得到文本内容后，通过completionHandler回调给JS
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    
    NSLog(@"%@", prompt);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"textinput" message:@"JS调用输入框" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor redColor];
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler([[alert.textFields lastObject] text]);
    }]];
    
    [self presentViewController:alert animated:YES completion:NULL];
}

#pragma mark - WKNavigationDelegate
// 如果需要处理web导航操作，比如链接跳转、接收响应、在导航开始、成功、失败等时要做些处理，就可以通过实现相关的代理方法：
// 请求开始前，会先调用此代理方法
// 与UIWebView的
// - (BOOL)webView:(UIWebView *)webView
// shouldStartLoadWithRequest:(NSURLRequest *)request
// navigationType:(UIWebViewNavigationType)navigationType;
// 类型，在请求先判断能不能跳转（请求）
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSURL * url = navigationAction.request.URL;
    NSString *hostname = navigationAction.request.URL.host.lowercaseString;
//    if (navigationAction.navigationType == WKNavigationTypeLinkActivated
//        && ![hostname containsString:@".baidu.com"]) {
//        // 对于跨域，需要手动跳转
//        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
//        
//        // 不允许web内跳转
//        decisionHandler(WKNavigationActionPolicyCancel);
//    } else {
//        self.progressView.alpha = 1.0;
//    }
    
    NSLog( @"hostname = %@", hostname);
    NSLog(@"%@", url.absoluteString);
   
    
    
    NSLog(@"%s", __FUNCTION__);
    decisionHandler(WKNavigationActionPolicyAllow);
}

// 在响应完成时，会回调此方法
// 如果设置为不允许响应，web内容就不会传过来
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    decisionHandler(WKNavigationResponsePolicyAllow);
    
    
    NSLog(@"%s", __FUNCTION__);
}

// 开始导航跳转时会回调
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __FUNCTION__);
}

// 接收到重定向时会回调
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __FUNCTION__);
}

// 导航失败时会回调
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%s", __FUNCTION__);
    [hud hide:YES];
}
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation
{
    [hud hide:YES];
}
// 页面内容到达main frame时回调
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __FUNCTION__);
}

// 导航完成时，会回调（也就是页面载入完成了）
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    NSLog(@"%s", __FUNCTION__);
    
    
//    NSString * string = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
//    NSLog(@"%@", string);
}

// 导航失败时会回调
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    
}

// 对于HTTPS的都会触发此代理，如果不要求验证，传默认就行
// 如果需要证书验证，与使用AFN进行HTTPS证书验证是一样的
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler {
    NSLog(@"%s", __FUNCTION__);
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

// 9.0才能使用，web内容处理中断时会触发
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"%s", __FUNCTION__);
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ __nullable)(__nullable id, NSError * __nullable error))completionHandler
{
    
}


- (void)backAction:(UIButton *)button
{
    [self.navigationController popViewControllerAnimated:YES];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"1px.png"] forBarMetrics:UIBarMetricsDefault];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
//    NSLog(@"****%f", _webView.estimatedProgress);;
    if (object == self.webView && [keyPath isEqualToString:@"estimatedProgress"]) {
        [hud hide:YES];
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }else if ([keyPath isEqualToString:@"loading"]) {
        NSLog(@"loading");
    }
}

- (void)requestOrderInformation:(NSString *)orderId
{
    NSDictionary *requestContents = @{
                                      @"OrderId":orderId
                                      };
    
    __weak StoreViewController * weakSelf = self;
    NSString * url = [NSString stringWithFormat:@"%@userinfo/WeChatPay?token=%@", POST_URL, [UserInfo shareUserInfo].userToken];
    [[HDNetworking sharedHDNetworking]POSTwithToken:url parameters:requestContents progress:^(NSProgress * _Nullable progress) {
        ;
    } success:^(id  _Nonnull responseObject) {
        NSLog(@"responseObject = %@", responseObject);
        int code = [[responseObject objectForKey:@"Code"] intValue];
        if (code == 200) {
            
            PayReq* req             = [[PayReq alloc] init];
            req.openID              = [responseObject objectForKey:@"AppId"];
            req.partnerId           = [responseObject objectForKey:@"PartnerId"];
            req.prepayId            = [responseObject objectForKey:@"PrepayId"];
            req.nonceStr            = [responseObject objectForKey:@"NonceStr"];
            req.timeStamp           = [[responseObject objectForKey:@"TimeStamp"] intValue];
            req.package             = [responseObject objectForKey:@"Package"];
            req.sign                = [responseObject objectForKey:@"Sign"];
            [WXApi sendReq:req];
        }else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@", [responseObject objectForKey:@"Message"]] delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
            [alert show];
            [alert performSelector:@selector(dismiss) withObject:nil afterDelay:1.0];
        }
        
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

#pragma mark - WXApiManagerDelegate
- (void)managerDidPaySuccess:(PayResp *)response
{
    switch (response.errCode) {
        case WXSuccess:
        {
            NSString * urlStr = [NSString stringWithFormat:@"http://www.wap.mstching.com/paycallback/returnurl?out_trade_no=%@&trade_status=%@",self.orderId, @"TRADE_SUCCESS"];
            NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
            [_webView loadRequest:request];
        }
            break;
            
        default:
        {
            NSString * urlStr = [NSString stringWithFormat:@"http://www.wap.mstching.com/paycallback/returnurl?out_trade_no=%@&trade_status=%@",self.orderId, @"TRADE_FAIL"];
            NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
            [_webView loadRequest:request];
        }
            break;
    }
}

- (BOOL)ishaveWechat
{
    if ([WXApi isWXAppInstalled]) {
        return YES;
    }else
    {
        return NO;
    }
}

- (BOOL)isChinaMobile
{
    CTTelephonyNetworkInfo * info = [[CTTelephonyNetworkInfo alloc]init];
    CTCarrier * carrier = [info subscriberCellularProvider];
    NSString * mcc = [carrier mobileCountryCode];
    if ([mcc isEqualToString:@"460"]) {
        return YES;
    }else
    {
        return NO;
    }
}
- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
