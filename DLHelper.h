#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DLHelper : NSObject

+ (BOOL)boolForKey:(id)key;
+ (void)setObject:(id)obj forKey:(id)key;
+ (void)setBool:(BOOL)value forKey:(id)key;
+ (id)cellWithTitle:(id)title detail:(id)detail image:(id)image url:(id)url;
+ (id)cellWithTitle:(id)title key:(id)key defaultValue:(id)defaultValue;
+ (void)vibration:(int)style;
+ (UIWindow *)keyWindow;
+ (UIViewController *)topMostController;
+ (UIViewController *)getViewControllerFromView:(UIView *)view;
+ (UIColor *)colorViewWithName:(id)name;
+ (unsigned long long)themeModeState;
+ (long long)getStatusCodeFromURL:(id)url;
+ (long long)DLMediaSize:(id)path;
+ (id)sendSynchronousRequest:(id)request returningResponse:(id *)response error:(id *)error;
+ (void)showAlertWithTitle:(id)title message:(id)message actions:(id)actions;
+ (void)showConfirmMessageSave:(void (^)(void))save share:(void (^)(void))share;
+ (void)showAlertWithMessage:(id)message;
+ (void)showMessageErrorInViewController:(UIViewController *)vc message:(id)message;
+ (UIImage *)imageTintColor:(UIImage *)image withColor:(UIColor *)color;
+ (UIImage *)imageIcon:(id)name;
+ (void)HUDWithState:(unsigned long long)state;

@end
