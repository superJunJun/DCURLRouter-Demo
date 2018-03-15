//
//  ISGBaseWebViewController.m
//  iShanggang
//
//  Created by  bxf on 2017/6/5.
//  Copyright © 2017年 aishanggang. All rights reserved.
//

#import "WiseWebViewController.h"
#import "NJKWebViewProgress.h"
#import "NJKWebViewProgressView.h"

#import <JavaScriptCore/JavaScriptCore.h>
//#import "BOHUDManager.h"
//#import "ISGShareManager.h"
//#import "ISGShareBottomView.h"
//
//#import "BeeCloudPayManager.h"
//#import <WXApi.h>
//
//#import "ISG_ShareInfo.h"
//#import "BOAssistor.h"
//
//#import "PaymentObject.h"


#define boundsWidth self.view.bounds.size.width
#define boundsHeight self.view.bounds.size.height

@interface WiseWebViewController ()<UIWebViewDelegate,UINavigationControllerDelegate,UINavigationBarDelegate,NJKWebViewProgressDelegate>

@property (nonatomic)UIBarButtonItem *customBackBarItem;
@property (nonatomic)UIBarButtonItem *closeButtonItem;

@property (nonatomic)NJKWebViewProgress *progressProxy;
@property (nonatomic)NJKWebViewProgressView *progressView;

/**
 *  array that hold snapshots
 */
@property (nonatomic)NSMutableArray* snapShotsArray;

/**
 *  current snapshotview displaying on screen when start swiping
 */
@property (nonatomic)UIView* currentSnapShotView;

/**
 *  previous view
 */
@property (nonatomic)UIView* prevSnapShotView;

/**
 *  background alpha black view
 */
@property (nonatomic)UIView* swipingBackgoundView;

/**
 *  left pan ges
 */
@property (nonatomic)UIPanGestureRecognizer* swipePanGesture;

/**
 *  if is swiping now
 */
@property (nonatomic)BOOL isSwipingBack;

@property (nonatomic,assign)NSInteger urlChangeNum;

@property (nonatomic,copy)NSString *shareTitle;
@property (nonatomic,copy)NSString *shareImageUrl;
@property (nonatomic,copy)NSString *shareContent;
@property (nonatomic,copy)NSString *shareUrl;

@property (nonatomic,copy)NSString *resultUrlStr;
@property (nonatomic,copy)NSDictionary *shareStoreMessageDic;
//@property (nonatomic, weak  ) ISGShareBottomView    *bottomGrayView;

@end

@implementation WiseWebViewController

-(UIStatusBarStyle) preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

#pragma mark - init
-(instancetype)initWithUrl:(NSURL *)url{
    self = [super init];
    if (self) {
        self.url = url;
        _progressViewColor = [UIColor colorWithRed:119.0/255 green:228.0/255 blue:115.0/255 alpha:1];
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reviseUserAgent];
    
    //config navigation item
    self.navigationItem.leftItemsSupplementBackButton = NO;
    self.title = @"wise商城";
    self.view.backgroundColor = [UIColor whiteColor];
    
    _urlChangeNum = 0;
    [self ISG_NavigationBarDefaultBackButtonAndNavigationTitle:nil];
    
    self.webView.delegate = self.progressProxy;
    [self.view addSubview:self.webView];
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.url]];
    
    [self.navigationController.navigationBar addSubview:self.progressView];
      
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"分享" style:UIBarButtonItemStylePlain target:self action:@selector(shareBtnClick)];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(payResultChangeUrl) name:@"kPayResult" object:nil];
}

- (void)dealloc {
    [self progressHUDHideImmediately];
    [self cleanCacheAndCookie];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)payResultChangeUrl {
    
    if (self.webView.canGoBack) {
        // MARK: -  返回的时候webView页面部分按钮失效了----------调用了goback方法
        [self.webView goBack];
        [self.webView reload];
//        [self cleanCacheAndCookie];
        NSString *resultUrlStr = [NSString stringWithFormat:@"%@://%@%@",self.url.scheme,self.url.host,self.resultUrlStr];
        [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:resultUrlStr]]];
    }
}

- (void)shareBtnClick {
//    [self shareStoreMessage:self.shareStoreMessageDic];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.progressView removeFromSuperview];
    self.webView.delegate = nil;
}


#pragma mark - public funcs
- (void)reloadWebView{
    [self.webView reload];
}

- (void)startPopSnapshotView {
    if (self.isSwipingBack) {
        return;
    }
    if (!self.webView.canGoBack) {
        return;
    }
    self.isSwipingBack = YES;
    //create a center of scrren
    CGPoint center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    
    self.currentSnapShotView = [self.webView snapshotViewAfterScreenUpdates:YES];
    
    //add shadows just like UINavigationController
    self.currentSnapShotView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.currentSnapShotView.layer.shadowOffset = CGSizeMake(3, 3);
    self.currentSnapShotView.layer.shadowRadius = 5;
    self.currentSnapShotView.layer.shadowOpacity = 0.75;
    
    //move to center of screen
    self.currentSnapShotView.center = center;
    
    self.prevSnapShotView = (UIView*)[[self.snapShotsArray lastObject] objectForKey:@"snapShotView"];
    center.x -= 60;
    self.prevSnapShotView.center = center;
    self.prevSnapShotView.alpha = 1;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.prevSnapShotView];
    [self.view addSubview:self.swipingBackgoundView];
    [self.view addSubview:self.currentSnapShotView];;
}

- (void)popSnapShotViewWithPanGestureDistance:(CGFloat)distance{
    if (!self.isSwipingBack) {
        return;
    }
    
    if (distance <= 0) {
        return;
    }
    
    CGPoint currentSnapshotViewCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    currentSnapshotViewCenter.x += distance;
    CGPoint prevSnapshotViewCenter = CGPointMake(boundsWidth/2, boundsHeight/2);
    prevSnapshotViewCenter.x -= (boundsWidth - distance)*60/boundsWidth;
    
    self.currentSnapShotView.center = currentSnapshotViewCenter;
    self.prevSnapShotView.center = prevSnapshotViewCenter;
    self.swipingBackgoundView.alpha = (boundsWidth - distance)/boundsWidth;
}

-(void)endPopSnapShotView {
    if (!self.isSwipingBack) {
        return;
    }
    
    //prevent the user touch for now
    self.view.userInteractionEnabled = NO;
    
    if (self.currentSnapShotView.center.x >= boundsWidth) {
        // pop success
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.currentSnapShotView.center = CGPointMake(boundsWidth*3/2, boundsHeight/2);
            self.prevSnapShotView.center = CGPointMake(boundsWidth/2, boundsHeight/2);
            self.swipingBackgoundView.alpha = 0;
        }completion:^(BOOL finished) {
            [self.prevSnapShotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            [self.currentSnapShotView removeFromSuperview];
            [self.webView goBack];
            [self.snapShotsArray removeLastObject];
            self.view.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    }else{
        //pop fail
        [UIView animateWithDuration:0.2 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
            
            self.currentSnapShotView.center = CGPointMake(boundsWidth/2, boundsHeight/2);
            self.prevSnapShotView.center = CGPointMake(boundsWidth/2-60, boundsHeight/2);
            self.prevSnapShotView.alpha = 1;
        }completion:^(BOOL finished) {
            [self.prevSnapShotView removeFromSuperview];
            [self.swipingBackgoundView removeFromSuperview];
            [self.currentSnapShotView removeFromSuperview];
            self.view.userInteractionEnabled = YES;
            
            self.isSwipingBack = NO;
        }];
    }
}

#pragma mark - update nav items

-(void)updateNavigationItems{
    if (self.webView.canGoBack) {
        UIBarButtonItem *spaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        spaceButtonItem.width = -6.5;
        
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
        //        [self.navigationItem setLeftBarButtonItems:@[self.closeButtonItem] animated:NO];
        
        //弃用customBackBarItem，使用原生backButtonItem
        [self.navigationItem setLeftBarButtonItems:@[spaceButtonItem,self.customBackBarItem,self.closeButtonItem] animated:NO];
    }else{
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
        self.navigationItem.leftBarButtonItems = nil;
        
        UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"p_backArrow"] style:UIBarButtonItemStylePlain target:self action:@selector(closeItemClicked)];
        backBarButton.tintColor = [UIColor whiteColor];
        self.navigationItem.leftBarButtonItem = backBarButton;
    }
}

#pragma mark - events handler
-(void)swipePanGestureHandler:(UIPanGestureRecognizer*)panGesture{
    CGPoint translation = [panGesture translationInView:self.webView];
    CGPoint location = [panGesture locationInView:self.webView];
    
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        if (location.x <= 50 && translation.x > 0) {  //开始动画
            [self startPopSnapshotView];
        }
    }else if (panGesture.state == UIGestureRecognizerStateCancelled || panGesture.state == UIGestureRecognizerStateEnded){
        [self endPopSnapShotView];
    }else if (panGesture.state == UIGestureRecognizerStateChanged){
        [self popSnapShotViewWithPanGestureDistance:translation.x];
    }
}

- (void)customBackItemClicked {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)closeItemClicked {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - webView delegate
- (void)webViewDidStartLoad:(UIWebView *)webView {
//    [[BOHUDManager defaultManager] progressHUDShowWithText:@"加载中"];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@" 捕捉所有的url %@ n/",request.URL);
    switch (navigationType) {
        case UIWebViewNavigationTypeLinkClicked: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        case UIWebViewNavigationTypeFormSubmitted: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        case UIWebViewNavigationTypeBackForward: {
            break;
        }
        case UIWebViewNavigationTypeReload: {
            break;
        }
        case UIWebViewNavigationTypeFormResubmitted: {
            break;
        }
        case UIWebViewNavigationTypeOther: {
            [self pushCurrentSnapshotViewWithRequest:request];
            break;
        }
        default: {
            break;
        }
    }
    [self updateNavigationItems];
    return YES;
}

#pragma mark - logic of push and pop snap shot views
- (void)pushCurrentSnapshotViewWithRequest:(NSURLRequest*)request {
    
    NSArray * urlArray = [[request.URL absoluteString] componentsSeparatedByString:@"?"];
    
    //当是付款时直接进行付款不在进行其他的东西
    BOOL whethIsPaymentAction = [urlArray.firstObject isEqualToString:@"haleyaction://pay_event"];
    if (whethIsPaymentAction) {
        [self pay:request.URL];
//        [[PaymentObject sharePayMange] paymentStringFormatting:[request.URL absoluteString]];
        return;
    }
    
    NSURLRequest* lastRequest = (NSURLRequest*)[[self.snapShotsArray lastObject] objectForKey:@"request"];
    
    //分享功能
    if ([urlArray.firstObject isEqualToString:@"haleyaction://shareClick"]) {
//        [self shareStoreMessage:self.shareStoreMessageDic];
        return;
    }
    
    //如果url是很奇怪的就不push
    if ([request.URL.absoluteString isEqualToString:@"about:blank"]) {
        NSLog(@"about blank!! return");
        return;
    }
    
    //如果url一样就不进行push
    if ([lastRequest.URL.absoluteString isEqualToString:request.URL.absoluteString]) {
        return;
    }
    
    UIView *currentSnapShotView = [self.webView snapshotViewAfterScreenUpdates:YES];
    [self.snapShotsArray addObject:@{@"request":request,
                                     @"snapShotView":currentSnapShotView}];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
//    [[BOHUDManager defaultManager] progressHUDHideImmediately];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    [self updateNavigationItems];
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (theTitle.length > 10) {
        theTitle = [[theTitle substringToIndex:9] stringByAppendingString:@"…"];
    }
    self.title = theTitle;
    
    [self.progressView setProgress:1 animated:NO];
    
    NSString *jsStr = [NSString stringWithFormat:@"WiseShare.getWxData()"];
    
    NSString *getDataStr = [webView stringByEvaluatingJavaScriptFromString:jsStr];
    
    NSData *jsonData = [getDataStr dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                        error:&err];
    self.shareStoreMessageDic = dic;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
//    [[BOHUDManager defaultManager] progressHUDHideImmediately];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

#pragma mark - NJProgress delegate

-(void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    [self.progressView setProgress:progress animated:NO];
}


#pragma mark - setters and getters
-(void)setUrl:(NSURL *)url{
    _url = url;
}

-(void)setProgressViewColor:(UIColor *)progressViewColor{
    _progressViewColor = progressViewColor;
    self.progressView.progressColor = progressViewColor;
}

-(UIWebView*)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 540, 540-64)];
        _webView.delegate = (id)self;
        _webView.scalesPageToFit = YES;
        _webView.backgroundColor = [UIColor whiteColor];
        [_webView addGestureRecognizer:self.swipePanGesture];
    }
    return _webView;
}

-(UIBarButtonItem*)customBackBarItem {
    if (!_customBackBarItem) {
        UIImage* backItemImage = [[UIImage imageNamed:@"p_backArrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIImage* backItemHlImage = [[UIImage imageNamed:@"p_backArrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        
        UIButton* backButton = [[UIButton alloc] init];
        [backButton setTitle:@"返回" forState:UIControlStateNormal];
        [backButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [backButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
//        [backButton.titleLabel setFont:[BOAssistor defaultTextStringFontWithSize:15.0]];
        [backButton setImage:backItemImage forState:UIControlStateNormal];
        [backButton setImage:backItemHlImage forState:UIControlStateHighlighted];
        [backButton sizeToFit];
        
        [backButton addTarget:self action:@selector(customBackItemClicked) forControlEvents:UIControlEventTouchUpInside];
        _customBackBarItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    }
    return _customBackBarItem;
}

-(UIBarButtonItem*)closeButtonItem {
    if (!_closeButtonItem) {
        
        UIButton* closeButton = [[UIButton alloc] init];
        [closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        [closeButton setTitleColor:self.navigationController.navigationBar.tintColor forState:UIControlStateNormal];
        [closeButton setTitleColor:[self.navigationController.navigationBar.tintColor colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
//        [closeButton.titleLabel setFont:[BOAssistor defaultTextStringFontWithSize:15.0]];
        [closeButton sizeToFit];
        
        [closeButton addTarget:self action:@selector(closeItemClicked) forControlEvents:UIControlEventTouchUpInside];
        _closeButtonItem = [[UIBarButtonItem alloc] initWithCustomView:closeButton];
    }
    return _closeButtonItem;
}

-(UIView*)swipingBackgoundView{
    if (!_swipingBackgoundView) {
        _swipingBackgoundView = [[UIView alloc] initWithFrame:self.view.bounds];
        _swipingBackgoundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    }
    return _swipingBackgoundView;
}

-(NSMutableArray*)snapShotsArray{
    if (!_snapShotsArray) {
        _snapShotsArray = [NSMutableArray array];
    }
    return _snapShotsArray;
}

-(BOOL)isSwipingBack{
    if (!_isSwipingBack) {
        _isSwipingBack = NO;
    }
    return _isSwipingBack;
}

-(UIPanGestureRecognizer*)swipePanGesture{
    if (!_swipePanGesture) {
        _swipePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(swipePanGestureHandler:)];
    }
    return _swipePanGesture;
}

-(NJKWebViewProgress*)progressProxy{
    if (!_progressProxy) {
        _progressProxy = [[NJKWebViewProgress alloc] init];
        _progressProxy.webViewProxyDelegate = (id)self;
        _progressProxy.progressDelegate = (id)self;
    }
    return _progressProxy;
}

-(NJKWebViewProgressView*)progressView{
    if (!_progressView) {
        CGFloat progressBarHeight = 3.0f;
        CGRect navigaitonBarBounds = self.navigationController.navigationBar.bounds;
        CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height, navigaitonBarBounds.size.width, progressBarHeight);
        _progressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        _progressView.progressColor = self.progressViewColor;
        _progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _progressView;
}


-(void)reviseUserAgent{
    
    UIWebView *tempWebView =  [[UIWebView alloc] initWithFrame:CGRectZero];
    NSString *secretAgent = [tempWebView stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    NSString *newUagent;
    if ([secretAgent hasSuffix:@"navigator.userAgent"]) {
        newUagent = secretAgent;
    } else {
        newUagent = [NSString stringWithFormat:@"%@uatwebview",secretAgent];
    }
    NSDictionary *dictionary = [[NSDictionary alloc]
                                initWithObjectsAndKeys:newUagent, @"UserAgent", nil];
    
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - private method

- (void)pay:(NSURL *)URL {
    
    NSArray *params =[URL.query componentsSeparatedByString:@"&"];
    NSMutableDictionary *tempDic = [NSMutableDictionary dictionary];
    for (NSString *paramStr in params) {
        NSArray *dicArray = [paramStr componentsSeparatedByString:@"="];
        if (dicArray.count > 1) {
            NSString *decodeValue = [dicArray[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            [tempDic setObject:decodeValue forKey:dicArray[0]];
        }
    }
    NSString *rurl = [tempDic objectForKey:@"rurl"];
    self.resultUrlStr = rurl;
}

//- (void)shareGoodsMessage {
//    if (!_bottomGrayView) {
//        ISGShareBottomView *shareView = [[ISGShareBottomView alloc]initWithFrame:CGRectMake(0, -50, KSCREEWIDTH, KSCREENHEIGHT)];
//        ISG_ShareInfo *shareUseInfo = [ISG_ShareInfo new];
//        shareUseInfo.title = self.shareTitle;
//        shareUseInfo.shareUrl = self.shareUrl;
//        shareUseInfo.content = self.shareContent;
//        shareUseInfo.shareIcon = self.shareImageUrl;
//        shareView.shareInfo = shareUseInfo;
//        [self.view addSubview:shareView];
//        self.bottomGrayView = shareView;
//    }
//}

//- (void)shareStoreMessage:(NSDictionary *)dic {
//    NSString *shareImageUrl;
//    NSString *shareUrl;
//    NSString *shareTitle;
//    NSString *shareContent;
//    if (!_bottomGrayView) {
//        if (dic.allKeys.count != 0) {
//            shareImageUrl = dic[@"imgUrl"];
//            shareUrl = dic[@"link"];
//            shareTitle = dic[@"title"];
//            shareContent = dic[@"desc"];
//        }
//        ISGShareBottomView *shareView = [[ISGShareBottomView alloc]initWithFrame:CGRectMake(0, -50, KSCREEWIDTH, KSCREENHEIGHT)];
//        ISG_ShareInfo *shareUseInfo = [ISG_ShareInfo new];
//        shareUseInfo.title = shareTitle;
//        shareUseInfo.shareUrl = shareUrl;
//        shareUseInfo.shareIcon = shareImageUrl;
//        shareUseInfo.content = shareContent;
//        shareView.shareInfo = shareUseInfo;
//        [self.view addSubview:shareView];
//        self.bottomGrayView = shareView;
//    }
//}

/**清除缓存和cookie*/
- (void)cleanCacheAndCookie{
    //清除cookies
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    
    for (cookie in [storage cookies]){
        [storage deleteCookie:cookie];
    }
    
    //清除UIWebView的缓存
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    NSURLCache * cache = [NSURLCache sharedURLCache];
    [cache removeAllCachedResponses];
    [cache setDiskCapacity:0];
    [cache setMemoryCapacity:0];
}

@end

