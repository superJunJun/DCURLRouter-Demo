//
//  ISGBaseWebViewController.h
//  iShanggang
//
//  Created by  bxf on 2017/6/5.
//  Copyright © 2017年 aishanggang. All rights reserved.
//

#import "ISGBaseViewController.h"

@interface ISGWebViewController : ISGBaseViewController

/**
 *  origin url
 */
@property (nonatomic)NSURL* url;

/**
 *  embed webView
 */
@property (nonatomic)UIWebView* webView;

/**
 *  tint color of progress view
 */
@property (nonatomic)UIColor* progressViewColor;

/**
 套件id
 */
//@property (nonatomic, assign)NSInteger brandId;

/**
 *  get instance with url
 *
 *  @param url url
 *
 *  @return instance
 */
-(instancetype)initWithUrl:(NSURL*)url;


-(void)reloadWebView;

@end
