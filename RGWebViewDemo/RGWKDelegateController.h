//
//  RGWKDelegateController.h
//  RGSFSafariViewController
//
//  Created by yangrui on 2018/12/9.
//  Copyright © 2018年 yangrui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@class RGWKDelegateController;

@protocol RGWKDelegateControllerDelegate <NSObject>
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message;

@end 


@interface RGWKDelegateController : UIViewController <WKScriptMessageHandler>


@property(nonatomic, weak) id<RGWKDelegateControllerDelegate> delegate;
@end
