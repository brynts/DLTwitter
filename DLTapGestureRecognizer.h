#import <UIKit/UIKit.h>

@interface DLTapGestureRecognizer : UITapGestureRecognizer
- (instancetype)initWithAction:(void (^)(void))action;
- (void)didTabOnView:(id)sender;
@end
