#import <UIKit/UIKit.h>

@interface MBBackgroundView : UIView

@property(nonatomic) long long style;
@property(nonatomic) long long blurEffectStyle;
@property(retain, nonatomic) UIColor *color;
@property(retain) UIVisualEffectView *effectView;

- (void)updateViewsForColor:(id)color;
- (void)updateForBackgroundStyle;

@end
