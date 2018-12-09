//
//  ViewController.m
//  RGSFSafariViewController
//
//  Created by yangrui on 2018/12/9.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <SafariServices/SafariServices.h>

/**打开网页的方式
 1. safari openUrl : 自带多功能(进度条, 刷新, 前进, 倒退等), 但是必须要跳出当前的应用
 2. UIWebview :  性能要弱一点,不能实现进度条,已经被废弃
 3. WKWebview :
 */

#import "ViewController.h"
#import "RGWKWebViewController.h"

@interface ViewController ()<SFSafariViewControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
  
    
    
}

#pragma mark- SFSafariVCTest iOS9 才能用

- (IBAction)SFSafariVCTest:(id)sender {
    
    SFSafariViewController *safariVc = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:@"https://www.baidu.com"]];
    safariVc.delegate = self;
    //SFSafariViewController 是建议我们使用present 方式来展示的, 不建议使用push 的方式来展示
    //当我们使用present 来展示SFSafariViewController 时, SFSafariViewController 内部会自动包装成 push的样式
    [self presentViewController:safariVc animated:YES completion:nil];
    
}

#pragma mark- SFSafariViewControllerDelegate
// 当 SFSafariViewController 点击done 时, 就会来带这个代理
- (void)safariViewController:(SFSafariViewController *)controller didCompleteInitialLoad:(BOOL)didLoadSuccessfully{
    
    NSLog(@"didCompleteInitialLoad");
    
}



#pragma mark- SFSafariVCTest
- (IBAction)wkWebViewTest:(id)sender {
    
    [self.navigationController pushViewController:[[RGWKWebViewController alloc] init] animated:YES];
  
}





@end
