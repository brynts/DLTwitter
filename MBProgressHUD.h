#import <UIKit/UIKit.h>

@class CADisplayLink, MBBackgroundView, NSArray, NSDate, NSProgress, NSTimer, UIButton, UIColor, UILabel;
@protocol MBProgressHUDDelegate;

@interface MBProgressHUD : UIView

@property(nonatomic) BOOL removeFromSuperViewOnHide;
@property(nonatomic) BOOL square;
@property(nonatomic) BOOL defaultMotionEffectsEnabled;
@property(nonatomic) BOOL useAnimation;
@property(nonatomic, getter=hasFinished) BOOL finished;
@property(nonatomic) float progress;
@property(nonatomic, weak) id<MBProgressHUDDelegate> delegate;
@property(copy) void (^completionBlock)(void);
@property(nonatomic) double graceTime;
@property(nonatomic) double minShowTime;
@property(nonatomic) long long mode;
@property(retain, nonatomic) UIColor *contentColor;
@property(nonatomic) long long animationType;
@property(nonatomic) double margin;
@property(nonatomic) CGPoint offset;
@property(nonatomic) CGSize minSize;
@property(retain, nonatomic) NSProgress *progressObject;
@property(readonly, nonatomic) MBBackgroundView *bezelView;
@property(readonly, nonatomic) MBBackgroundView *backgroundView;
@property(retain, nonatomic) UIView *customView;
@property(readonly, nonatomic) UILabel *label;
@property(readonly, nonatomic) UILabel *detailsLabel;
@property(readonly, nonatomic) UIButton *button;
@property(readonly, nonatomic) UIButton *hideButton;
@property(nonatomic, weak) NSTimer *graceTimer;
@property(nonatomic, weak) NSTimer *minShowTimer;
@property(nonatomic, weak) NSTimer *hideDelayTimer;
@property(nonatomic, weak) CADisplayLink *progressObjectDisplayLink;

+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated;
+ (BOOL)hideHUDForView:(UIView *)view animated:(BOOL)animated;
+ (instancetype)HUDForView:(UIView *)view;

- (instancetype)initWithView:(UIView *)view;
- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated afterDelay:(double)delay;

@end
