//
//  RGWKWebViewController.m
//  RGSFSafariViewController
//
//  Created by yangrui on 2018/12/9.
//  Copyright © 2018年 yangrui. All rights reserved.
//  http://www.cocoachina.com/ios/20161121/18142.html
//  https://github.com/marcuswestin/WebViewJavascriptBridge

#import "RGWKWebViewController.h"
#import <WebKit/WebKit.h>
#import "RGWKDelegateController.h"

@interface RGWKWebViewController ()<WKNavigationDelegate, WKUIDelegate, RGWKDelegateControllerDelegate>

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, strong) WKUserContentController *userContentCtr;

@property (weak, nonatomic) IBOutlet UIButton *backBtn;
@property (weak, nonatomic) IBOutlet UIButton *forwardBtn;
@property (weak, nonatomic) IBOutlet UIButton *reloadBtn;


@end

@implementation RGWKWebViewController


/** 关于 WKWebView 的说明
1. WKWebView 是UIWebView(iOS8) 的升级版, WKWebView 可以监听网页加载的进度, 默认有做数据缓存(再次访问变快)
 
 */

-(WKWebView *)webView{
    if (!_webView) {
        
        //注册方法
        // 注册一个name 为sayHello 的js 方法
        WKUserContentController *userContentCtr = [[WKUserContentController alloc] init];
        
        //错误的写法
        //这段OC代码经过测试会发现dealloc 并不会执行,这样肯定是不会执行, 会造成内存泄露
        //原因: [userContentCtr addScriptMessageHandler:self name:@"sayHello"] 这句代码造成无法释放内存
        //试用一个weak指针还是不能释放, 不知道原因是什么, 因此需要进一步改进, 正确的写法是用一个新的controller 来处理
        //新的controller 再绕用delegate 绕会来
        //[userContentCtr addScriptMessageHandler:self name:@"sayHello"];
        
        
        // 正确的写法
        RGWKDelegateController *delegateCtr = [[RGWKDelegateController alloc]init];
        delegateCtr.delegate = self;
        [userContentCtr addScriptMessageHandler:delegateCtr name:@"sayHello"];
        /** 注意点:
         addScriptMessageHandler: 和 removeScriptMessageHandlerForName: 配套出现否则会造成内存泄露
         h5 只能传一个参数, 如果需要多个参数就需要使用字典或者json
         
         */
        
        
        //配置环境
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        config.userContentController = userContentCtr;
        
        
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)
                                      configuration:config];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        [self.view insertSubview:_webView atIndex:0];
    }
    return _webView;
}




/**
 WKWebView 提供了API 实现js交互, 不需要借助JavaScriptCore 或者webJavaScriptBridge.
 使用WKUserContentController 实现js native 交互. 简单的说就是先注册约定好的方法, 然后在调用.
 
 JS 调用OC 方法
 OC 代码(有误, 内存不释放)
 */
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupKVO];
   
    [self loadRequest];
    
    self.navigationItem.title = self.webView.title;
}

-(void)loadRequest{
    NSURL *url =  [NSURL URLWithString:@"https://www.baidu.com"];
    NSURLRequest *request =[ NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

-(void)setupKVO{
    [self.webView addObserver:self forKeyPath:@"canGoBack" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"canGoForward" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
    
}


- (IBAction)backBtnClick:(id)sender {
    NSLog(@"后退");
}

- (IBAction)forwardClick:(id)sender {
     NSLog(@"前进");
}
- (IBAction)reloadClick:(id)sender {
    NSLog(@"刷新");
}


#pragma mark- WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message{
    
    NSLog(@"\n name : %@, \n body:%@, \n frameInfo: %@ ",message.name, message.body, message.frameInfo);
}





#pragma mark- WKNavigationDelegate
/** 页面开始加载时调用
 */
- (void)webView:(WKWebView *)webView
didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    
    NSLog(@"页面开始加载");
}

/**  当内容开始返回时调用
 */
- (void)webView:(WKWebView *)webView
didCommitNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"内容开始返回");
}


/**h5代码:
 
 function say(){
     //前端需要用 window.webkit.messageHandlers.注册的方法名.postMessage({body:传输的数据} 来给native发送消息
     window.webkit.messageHandlers.sayhello.postMessage({body: 'hello world!'});
 }
 
 打印出的log
 name:sayhello
 body:{
 body = "hello world!";
 }
 
 frameInfo:<wkframeinfo: 0x7f872060ce20;
 ismainframe = yes;
 request = { url: http: www.test.com=""  } =""></wkframeinfo: 0x7f872060ce20;
 ismainframe = yes;
 request = { url: http:>
 
 */


/** 页面加载完成之后调用
 */
- (void)webView:(WKWebView *)webView
didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    
    NSLog(@"页面加载完成");
    //say() 是JS方法名, completeHandler 是异步回调block
    [webView evaluateJavaScript:@"say()" completionHandler:^(id result, NSError * error) {
        NSLog(@"result : %@, error : %@", result, error.localizedDescription);
    }];
}

/** 页面加载失败时调用
 */
- (void)webView:(WKWebView *)webView
didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation
      withError:(NSError *)error{
    NSLog(@"页面加载失败");
}

/** 接收到服务器跳转请求后调用
 */
- (void)webView:(WKWebView *)webView
didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation{
    NSLog(@"接收到服务器跳转请求后调用");
}

/** 在发送请求前, 决定是否跳转
 */
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction
decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSLog(@"发送请求前, 决定是否跳转 %@",navigationAction.request.URL.absoluteString);
    
    // 允许跳转
    decisionHandler(WKNavigationActionPolicyAllow);
    
    // 不允许跳转
    //decisionHandler(WKNavigationActionPolicyCancel);
    
}

/** 在收到响应后, 决定是否跳转
 */
- (void)webView:(WKWebView *)webView
decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse
decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler{
    
    NSLog(@"在收到响应后, 决定是否跳转 %@",navigationResponse.response.URL.absoluteString);
    // 允许跳转
    decisionHandler(WKNavigationResponsePolicyAllow);
    // 不允许跳转
//    decisionHandler(WKNavigationResponsePolicyCancel);
    
}



#pragma mark- WKUIDelegate

/** 创建一个新的webView
 */
- (nullable WKWebView *)webView:(WKWebView *)webView
 createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration
            forNavigationAction:(WKNavigationAction *)navigationAction
                 windowFeatures:(WKWindowFeatures *)windowFeatures{
    
    NSLog(@"创建一个新的webView");
    return  [[WKWebView alloc] init];
}

/** 输入框
 */
- (void)webView:(WKWebView *)webView
runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt
    defaultText:(nullable NSString *)defaultText
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(NSString * _Nullable result))completionHandler{
    
    NSLog(@"输入框");
    completionHandler(@"http");
}

/** 确认框
 */
- (void)webView:(WKWebView *)webView
runJavaScriptConfirmPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(BOOL result))completionHandler{
    NSLog(@"确认框");
    completionHandler(YES);
}

/** 警告框
 */
- (void)webView:(WKWebView *)webView
runJavaScriptAlertPanelWithMessage:(NSString *)message
initiatedByFrame:(WKFrameInfo *)frame
completionHandler:(void (^)(void))completionHandler{
    NSLog(@"警告框");
    completionHandler();
}

/** webView 关闭
 */
- (void)webViewDidClose:(WKWebView *)webView {
    
    NSLog(@"webViewDidClose");
}









#pragma mark- KVO
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                      context:(void *)context{
    
    if ([keyPath isEqualToString:@"canGoBack"]) {
        
        self.backBtn.enabled = self.webView.canGoBack;
    }
    
    if ([keyPath isEqualToString:@"canGoForward"]) {
        self.forwardBtn.enabled = self.webView.canGoForward;
        
    }
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        NSLog(@"estimatedProgress -----> %f", self.webView.estimatedProgress);
        self.progressView.progress =  self.webView.estimatedProgress;
        self.progressView.hidden = self.webView.estimatedProgress >= 1;
        
    }
    
    if ([keyPath isEqualToString:@"title"]) {
        
        self.navigationItem.title = self.webView.title;
        
    }
    
   
    
}

-(void)dealloc{
    // KVO
    [self.webView removeObserver:self forKeyPath:@"canGoBack"];
    [self.webView removeObserver:self forKeyPath:@"canGoForward"];
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [self.webView removeObserver:self forKeyPath:@"title"];
    
    
    
    
    // 前面增加的方法 , 这里一定要移除
    
    [self.userContentCtr removeScriptMessageHandlerForName:@"sayHello"];
}


@end
