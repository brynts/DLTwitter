#import <UIKit/UIKit.h>

@interface DLButton : UIButton

@property(copy, nonatomic) void (^action)(void);
- (void)actionHandler:(void (^)(void))handler;
- (void)didPressButton:(id)sender;

@end
