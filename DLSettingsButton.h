#import <UIKit/UIKit.h>

@interface DLSettingsButton : UIButton

@property(copy, nonatomic) void (^action)(void);
- (void)actionHandler:(void (^)(void))handler;
- (void)didPressButton:(id)sender;

@end
