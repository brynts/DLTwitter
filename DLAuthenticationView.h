#import <UIKit/UIKit.h>
#import <LocalAuthentication/LocalAuthentication.h>

@interface DLAuthenticationView : UIView

@property(nonatomic, getter=isAuthenticated) BOOL authenticated;
@property(retain, nonatomic) LAContext *context;
@property(retain, nonatomic) UIVisualEffectView *dlBlurView;

- (void)setupBlurView;
- (void)contextAuthenticated:(void (^)(BOOL success))completion;

@end
