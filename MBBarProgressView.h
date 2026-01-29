#import <UIKit/UIKit.h>

@interface MBBarProgressView : UIView

@property(nonatomic) float progress;
@property(retain, nonatomic) UIColor *lineColor;
@property(retain, nonatomic) UIColor *progressRemainingColor;
@property(retain, nonatomic) UIColor *progressColor;

@end
