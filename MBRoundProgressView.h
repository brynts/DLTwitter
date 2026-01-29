#import <UIKit/UIKit.h>

@interface MBRoundProgressView : UIView

@property(nonatomic) float progress;
@property(retain, nonatomic) UIColor *progressTintColor;
@property(retain, nonatomic) UIColor *backgroundTintColor;
@property(nonatomic, getter=isAnnular) BOOL annular;

@end
