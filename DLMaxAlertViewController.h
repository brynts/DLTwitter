#import <UIKit/UIKit.h>

@class DLMaxAlertTextView, DLMaxAlertAction;

@interface DLMaxAlertViewController : UIViewController <UIViewControllerTransitioningDelegate>

@property double cornerRadius;
@property(retain) UIView *containerView;
@property(retain) UILabel *titleLabel;
@property(retain) NSString *tweakName;
@property(retain) NSString *message;
@property(retain) DLMaxAlertTextView *bodyText;
@property(retain) NSArray<DLMaxAlertAction *> *actions;
@property(retain) NSLayoutConstraint *containerViewHeightConstraint;
@property(retain) NSLayoutConstraint *containerViewWidthConstraint;

- (instancetype)initWithTweakName:(id)tweakName message:(id)message actions:(id)actions;
- (void)dismissAlertController;
- (void)applyCustomFontForBodyText;

@end
