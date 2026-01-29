#import <UIKit/UIKit.h>

@interface DLBarButtonItem : UIBarButtonItem
- (instancetype)initWithTitle:(id)title style:(long long)style action:(void (^)(void))action;
- (instancetype)initWithImage:(id)image style:(long long)style action:(void (^)(void))action;
- (void)didPressBarButton:(id)sender;
@end
