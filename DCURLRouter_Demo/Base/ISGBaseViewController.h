//
//  BaseViewController.h
//

#import <UIKit/UIKit.h>

@interface ISGBaseViewController : UIViewController

@property (assign, nonatomic) UIRectEdge customEdgesForExtendedLayout;
@property (copy, nonatomic) NSString *titleText;
@property (assign, nonatomic) CGPoint noticeBarCenter;
@property (assign, nonatomic) BOOL isNoticeStyleBlack;
@property (assign, nonatomic) NSString *noticeText;

- (void)progressHUDShowWithText:(NSString *)text;
- (void)progressHUDShowWithCompleteText:(NSString *)text isSucceed:(BOOL)isSucceed;
- (void)progressHUDMomentaryShowWithTarget:(id)target action:(SEL)action object:(id)object;
- (void)progressHUDMomentaryShowWithText:(NSString *)text target:(id)target action:(SEL)action object:(id)object;
- (void)progressHUDShowWithCompleteText:(NSString *)text isSucceed:(BOOL)isSucceed additionalTarget:(id)target action:(SEL)action object:(id)object;
- (void)progressHUDHideImmediately;
- (void)loadDataErrorText:(NSString *)errorString;

//- (void)postURLRequestWithURL:(NSString *)url
//                    sessionID:(BOOL )sessionID
//                 HUDLabelText:(NSString *)text
//                       params:(NSDictionary *)params
//                completeBlock:(AMPostHttpRequestCompletionBlock)completeBlock
//                  failedBlock:(AMPostHttpRequestFailedBlock)failedBlock;

#pragma mark - barbuttonItem
- (void)ISG_NavigationBarDefaultBackButtonAndNavigationTitle:(NSString *)title;
- (void)ISG_NavigationBarWithBackButtonTitle:(NSString *)title leftImageNamed:(NSString *)leftImageName andAction:(SEL)action;
- (void)ISG_NavigationBarRightBarWithTitle:(NSString *)title andAction:(nullable SEL)action;


#pragma mark - Refresh
- (void)ISG_update_dataRefreshByScrollview:(nullable UIScrollView *)scroll target:(nullable id)target action:(nullable SEL)action isAutomaticallyRefreshing:(BOOL)isBegining;
- (void)ISG_more_dataRefreshByScrollview:(nullable UIScrollView *)scroll target:(nullable id)target action:(nullable SEL)action;
- (void)ISG_no_dataRefreshByScrollView:(nullable UIScrollView *)scroll;
- (void)ISG_resetRefreshByScrollView:(nullable UIScrollView *)scroll;

- (void)netWorkStateChange:(NSNotification *_Nullable)noti;

@end
