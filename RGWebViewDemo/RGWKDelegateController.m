//
//  RGWKDelegateController.m
//  RGSFSafariViewController
//
//  Created by yangrui on 2018/12/9.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import "RGWKDelegateController.h"

@interface RGWKDelegateController ()

@end

@implementation RGWKDelegateController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark- WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController
      didReceiveScriptMessage:(WKScriptMessage *)message{
    
    if([self.delegate respondsToSelector:@selector(userContentController:  didReceiveScriptMessage:) ]){
       
        [self.delegate userContentController:userContentController
                     didReceiveScriptMessage:message];
    }
 }






@end
